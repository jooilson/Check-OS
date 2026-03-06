import 'package:checkos/core/constants/app_route_names.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:checkos/presentation/pages/auth/auth_page.dart';
import 'package:checkos/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndSetContext();
  }

  Future<void> _checkAuthAndSetContext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Usuário já autenticado - define o contexto do funcionário
      await _setEmployeeContext(user.uid);
    }
  }

  Future<void> _setEmployeeContext(String uid) async {
    try {
      final employeeRepo = EmployeeRepository();
      var employee = await employeeRepo.getEmployeeById(uid);
      
      // Fallback: se não encontrar em employees, busca em users
      if (employee == null) {
        debugPrint('[AuthWrapper] Funcionário não encontrado em employees, buscando em users...');
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          employee = EmployeeModel(
            id: uid,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            role: data['role'] ?? 'employee',
            phone: '',
            companyId: data['companyId'],
            isActive: data['isActive'] ?? true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          debugPrint('[AuthWrapper] Funcionário encontrado em users: ${employee?.name}');
        }
      }
      
      if (employee != null && mounted) {
        // Verifica se o usuário tem companyId
        if (employee.companyId == null || employee.companyId!.isEmpty) {
          // Usuário sem empresa - redirecionar para onboarding
          context.read<EmployeeContext>().setCurrentEmployee(employee);
          Navigator.pushReplacementNamed(context, AppRouteNames.cadastroEmpresa);
          return;
        }
        
        context.read<EmployeeContext>().setCurrentEmployee(employee);
      }
    } catch (e) {
      debugPrint('[AuthWrapper] Erro ao buscar funcionário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          // Define o contexto do funcionário quando autenticado
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final employeeRepo = EmployeeRepository();
            var employee = await employeeRepo.getEmployeeById(snapshot.data!.uid);
            
            // Fallback: se não encontrar em employees, busca em users
            if (employee == null) {
              debugPrint('[AuthWrapper] Funcionário não encontrado em employees (StreamBuilder), buscando em users...');
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get();
              
              if (userDoc.exists && userDoc.data() != null) {
                final data = userDoc.data() as Map<String, dynamic>;
                employee = EmployeeModel(
                  id: snapshot.data!.uid,
                  name: data['name'] ?? '',
                  email: data['email'] ?? '',
                  role: data['role'] ?? 'employee',
                  phone: '',
                  companyId: data['companyId'],
                  isActive: data['isActive'] ?? true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                debugPrint('[AuthWrapper] Funcionário encontrado em users (StreamBuilder): ${employee?.name}');
              }
            }
            
            if (employee != null && mounted) {
              // Verifica se o usuário tem companyId - ONBOARDING OBRIGATÓRIO
              if (employee.companyId == null || employee.companyId!.isEmpty) {
                context.read<EmployeeContext>().setCurrentEmployee(employee);
                Navigator.pushReplacementNamed(context, AppRouteNames.cadastroEmpresa);
                return;
              }
              
              context.read<EmployeeContext>().setCurrentEmployee(employee);
              Navigator.pushReplacementNamed(context, AppRouteNames.home);
            } else {
              // Funcionário não encontrado - vai para login
              Navigator.pushReplacementNamed(context, AppRouteNames.login);
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const AuthPage();
      },
    );
  }
}

