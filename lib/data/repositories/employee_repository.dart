import 'package:flutter/foundation.dart';
import 'package:checkos/core/utils/logger.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/services/firebase/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeRepository {
  final CollectionReference _employeeCollection =
      FirebaseFirestore.instance.collection('employees');
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final AuthService _authService = AuthService();

  // Get a stream of all employees, ordered by name
  Stream<List<EmployeeModel>> getEmployeesStream({String? companyId}) {
    Query query = _employeeCollection.orderBy('name');
    
    // Filtrar por companyId se fornecido
    if (companyId != null) {
      query = _employeeCollection.where('companyId', isEqualTo: companyId).orderBy('name');
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmployeeModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Get a list of all employees once, ordered by name
  Future<List<EmployeeModel>> getEmployeesList({String? companyId}) async {
    try {
      Query query = _employeeCollection.orderBy('name');
      
      // Filtrar por companyId se fornecido
      if (companyId != null) {
        query = _employeeCollection.where('companyId', isEqualTo: companyId).orderBy('name');
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => EmployeeModel.fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error("Error fetching employees", e);
      return [];
    }
  }

  // Get a list of only active employees, ordered by name
  Future<List<EmployeeModel>> getActiveEmployeesList({String? companyId}) async {
    try {
      Query query = _employeeCollection.where('isActive', isEqualTo: true).orderBy('name');
      
      // Filtrar por companyId se fornecido
      if (companyId != null) {
        query = _employeeCollection
            .where('companyId', isEqualTo: companyId)
            .where('isActive', isEqualTo: true)
            .orderBy('name');
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => EmployeeModel.fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error("Error fetching active employees", e);
      return [];
    }
  }

  // Buscar funcionário pelo ID
  Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      final doc = await _employeeCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return EmployeeModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error("Error fetching employee by id", e);
      return null;
    }
  }

  // Buscar companyId do usuário logado - FONTE OFICIAL
  Future<String?> getCompanyIdByUid(String uid) async {
    try {
      debugPrint('[EmployeeRepository] Buscando companyId para UID: $uid');
      
      // Primeiro: busca na coleção 'employees' (fonte principal)
      final employeeDoc = await _employeeCollection.doc(uid).get();
      if (employeeDoc.exists && employeeDoc.data() != null) {
        final data = employeeDoc.data() as Map<String, dynamic>;
        final companyId = data['companyId'] as String?;
        debugPrint('[EmployeeRepository] CompanyId encontrado na coleção employees: $companyId');
        return companyId;
      }
      
      // Segundo: busca na coleção 'users' (fallback)
      final userDoc = await _userCollection.doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        final companyId = data['companyId'] as String?;
        debugPrint('[EmployeeRepository] CompanyId encontrado na coleção users: $companyId');
        return companyId;
      }
      
      debugPrint('[EmployeeRepository] CompanyId não encontrado para UID: $uid');
      return null;
    } catch (e) {
      debugPrint('[EmployeeRepository] Erro ao buscar companyId: $e');
      return null;
    }
  }

  // Soft delete employee (set isActive to false)
  Future<void> deleteEmployee(String id) async {
    // Atualiza na coleção employees
    await _employeeCollection.doc(id).update({'isActive': false});
    // Atualiza também na coleção users para manter sincronização
    await _userCollection.doc(id).update({'isActive': false});
  }

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    final snapshot = await _employeeCollection.where('email', isEqualTo: email).get();
    return snapshot.docs.isNotEmpty;
  }

  // Add new employee - versão corrigida com validação completa
  Future<void> addEmployee(EmployeeModel employee, {required String password, required String companyId}) async {
    // Validação de segurança
    if (companyId.isEmpty) {
      throw Exception('companyId é obrigatório. Faça login novamente.');
    }
    
    // Validar que a empresa existe antes de salvar
    final companyDoc = await FirebaseFirestore.instance.collection('companies').doc(companyId).get();
    if (!companyDoc.exists) {
      throw Exception('Empresa não encontrada. Faça login novamente.');
    }
    
    debugPrint('[EmployeeRepository] Cadastrando funcionário na empresa: $companyId');

    // 1. Create Auth user and initial Firestore docs via AuthService
    String uid = await _authService.registerEmployee(
      email: employee.email,
      password: password,
      name: employee.name,
      role: employee.role,
      companyId: companyId,
    );

    // 2. Update the employee document with additional fields (phone, cpf, companyId)
    // We use merge to not overwrite what registerEmployee created
    await _employeeCollection.doc(uid).set({
      'phone': employee.phone,
      'cpf': employee.cpf,
      'companyId': companyId,
    }, SetOptions(merge: true));
    
    debugPrint('[EmployeeRepository] Funcionário cadastrado com sucesso: $uid na empresa: $companyId');
  }

  // Update existing employee - mantém sincronização com coleção 'users'
  Future<void> updateEmployee(EmployeeModel employee) async {
    final employeeData = employee.toFirestore();
    final userData = {
      'name': employee.name,
      'email': employee.email,
      'role': employee.role,
      'isActive': employee.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // Atualiza ambas as coleções para manter sincronização
    await Future.wait([
      _employeeCollection.doc(employee.id).update(employeeData),
      _userCollection.doc(employee.id).update(userData),
    ]);
  }
}
