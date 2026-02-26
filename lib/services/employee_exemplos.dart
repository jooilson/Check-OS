// EXEMPLOS DE USO - Sistema de Funcionários e Auditoria
// Arquivo: lib/services/employee_exemplos.dart

import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeExemplos {
  static final EmployeeRepository _repo = EmployeeRepository();

  /// Exemplo 1: Adicionar um novo funcionário
  static Future<void> exemplo1_adicionarFuncionario() async {
    try {
      final employee = EmployeeModel(
        id: '', // Será gerado pelo Firebase Auth
        name: 'Maria Santos',
        email: 'maria@empresa.com',
        role: 'Técnico',
        phone: '(11) 98888-8888',
        cpf: '123.456.789-00',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Nota: O companyId deve ser passado ao adicionar funcionário
      // Em uso real, obtenha o companyId do contexto do admin logado
      await _repo.addEmployee(employee, password: 'senha_padrao_123', companyId: 'company-id-aqui');
      print('✓ Funcionário adicionado: ${employee.name}');
    } catch (e) {
      print('✗ Erro ao adicionar: $e');
    }
  }

  /// Exemplo 2: Obter lista de funcionários
  static Future<void> exemplo2_obterLista() async {
    try {
      final employees = await _repo.getEmployeesList();
      print('✓ Funcionários encontrados: ${employees.length}');
      for (var emp in employees) {
        print('  - ${emp.name} (${emp.role})');
      }
    } catch (e) {
      print('✗ Erro ao obter lista: $e');
    }
  }

  /// Exemplo 3: Stream em tempo real
  static void exemplo3_streamTempoReal() {
    final stream = _repo.getEmployeesStream();
    
    stream.listen(
      (employees) {
        print('✓ Funcionários atualizados: ${employees.length}');
        for (var emp in employees) {
          print('  - ${emp.name}: ${emp.email}');
        }
      },
      onError: (e) {
        print('✗ Erro no stream: $e');
      },
    );
  }

  /// Exemplo 4: Verificar email duplicado
  static Future<void> exemplo4_verificarEmailDuplicado() async {
    try {
      final exists = await _repo.emailExists('maria@empresa.com');
      if (exists) {
        print('✓ Email já existe no sistema');
      } else {
        print('✓ Email disponível para cadastro');
      }
    } catch (e) {
      print('✗ Erro ao verificar email: $e');
    }
  }

  /// Exemplo 5: Atualizar funcionário
  static Future<void> exemplo5_atualizarFuncionario() async {
    try {
      // Para atualizar, você precisa de um ID de documento real do Firestore.
      // O ideal é buscar o funcionário primeiro para não sobrescrever o createdAt.
      final employee = EmployeeModel(
        id: 'some-firestore-doc-id', // Substitua por um ID real
        name: 'Maria Santos Silva',
        email: 'maria.silva@empresa.com',
        role: 'Técnico Sênior',
        phone: '(11) 99999-9999',
        cpf: '123.456.789-00',
        isActive: true,
        createdAt: DateTime.now(), // Idealmente, você manteria o createdAt original
        updatedAt: DateTime.now(),
      );

      await _repo.updateEmployee(employee);
      print('✓ Funcionário atualizado com sucesso');
    } catch (e) {
      print('✗ Erro ao atualizar: $e');
    }
  }

  /// Exemplo 6: Deletar funcionário (soft delete)
  static Future<void> exemplo6_deletarFuncionario() async {
    try {
      // Substitua por um ID de documento real do Firestore
      await _repo.deleteEmployee('some-firestore-doc-id');
      print('✓ Funcionário deletado (marcado como inativo)');
    } catch (e) {
      print('✗ Erro ao deletar: $e');
    }
  }

  // /// Exemplo 7: Obter um funcionário específico
  // /// O método `getEmployee` não existe no `EmployeeRepository` fornecido.
  // static Future<void> exemplo7_obterFuncionarioEspecifico() async {
  //   try {
  //     // final employee = await _repo.getEmployee('emp-001');
  //     if (employee != null) {
  //       print('✓ Funcionário encontrado:');
  //       print('  Nome: ${employee.name}');
  //       print('  Email: ${employee.email}');
  //       print('  Cargo: ${employee.role}');
  //     } else {
  //       print('✗ Funcionário não encontrado');
  //     }
  //   } catch (e) {
  //     print('✗ Erro ao obter funcionário: $e');
  //   }
  // }

  /// Exemplo 8: Cadastro de múltiplos funcionários
  static Future<void> exemplo8_cadastroMultiplo() async {
    try {
      final funcionarios = [
        EmployeeModel(
          id: '',
          name: 'João Silva',
          email: 'joao@empresa.com',
          role: 'Encanador',
          phone: '(11) 97777-7777',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EmployeeModel(
          id: '',
          name: 'Pedro Costa',
          email: 'pedro@empresa.com',
          role: 'Eletricista',
          phone: '(11) 96666-6666',
          cpf: '987.654.321-00',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EmployeeModel(
          id: '',
          name: 'Ana Oliveira',
          email: 'ana@empresa.com',
          role: 'Supervisor',
          phone: '(11) 95555-5555',
          cpf: '456.789.123-45',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var emp in funcionarios) {
        // Nota: O companyId deve ser passado ao adicionar funcionário
        await _repo.addEmployee(emp, password: 'senha_padrao_123', companyId: 'company-id-aqui');
        print('✓ ${emp.name} adicionado com sucesso');
      }
    } catch (e) {
      print('✗ Erro no cadastro múltiplo: $e');
    }
  }

  // /// Exemplo 9: Copiar funcionário e atualizar
  // /// O método `copyWith` não existe no `EmployeeModel` fornecido.
  // /// Você pode implementá-lo em `employee_model.dart` se precisar dessa funcionalidade.
  // static Future<void> exemplo9_copyWithUpdate() async {
  //   try {
  //     // Obter funcionário
  //     // final original = await _repo.getEmployee('emp-001');
  //     
  //     if (original != null) {
  //       // Criar cópia com atualizações
  //       // final updated = original.copyWith(...);
  //       // await _repo.updateEmployee(updated);
  //       print('✓ Funcionário atualizado via copyWith');
  //     }
  //   } catch (e) {
  //     print('✗ Erro: $e');
  //   }
  // }

  /// Exemplo 10: Listar todos (inclusive inativos)
  static Future<void> exemplo10_listarTodos() async {
    try {
      // O método getEmployeesList() já busca todos, ativos e inativos.
      final allEmployees = await _repo.getEmployeesList();
      print('✓ Total de funcionários (ativo + inativo): ${allEmployees.length}');
      
      final ativos = allEmployees.where((e) => e.isActive).length;
      final inativos = allEmployees.where((e) => !e.isActive).length;
      
      print('  Ativos: $ativos');
      print('  Inativos: $inativos');
    } catch (e) {
      print('✗ Erro: $e');
    }
  }
}

// ==============================================================
// EXEMPLOS DE USO NO CÓDIGO
// ==============================================================

/*

// No seu arquivo de testes ou setup:

void main() async {
  // Teste 1: Adicionar funcionário
  await EmployeeExemplos.exemplo1_adicionarFuncionario();
  
  // Teste 2: Obter lista
  await EmployeeExemplos.exemplo2_obterLista();
  
  // Teste 3: Stream em tempo real
  EmployeeExemplos.exemplo3_streamTempoReal();
  
  // Teste 4: Verificar duplicação
  await EmployeeExemplos.exemplo4_verificarEmailDuplicado();
  
  // Teste 5: Atualizar
  await EmployeeExemplos.exemplo5_atualizarFuncionario();
  
  // Teste 6: Deletar
  await EmployeeExemplos.exemplo6_deletarFuncionario();
  
  // Teste 7: Obter específico
  await EmployeeExemplos.exemplo7_obterFuncionarioEspecifico();
  
  // Teste 8: Cadastro múltiplo
  await EmployeeExemplos.exemplo8_cadastroMultiplo();
}

*/

// ==============================================================
// EXEMPLO DE INTEGRAÇÃO COM AUDITORIA (LogModel)
// ==============================================================

/*

import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/repositories/log_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogComAuditoria {
  static final LogRepository _logRepo = LogRepository();

  /// Criar log de auditoria com funcionário
  static Future<void> criarLogComFuncionario({
    required String osId,
    required String osNumero,
    required String action,
    required String description,
    String? employeeId,
    String? employeeName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final log = LogModel(
        id: '',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        userName: user.displayName,
        employeeId: employeeId,
        employeeName: employeeName, // ✨ Nome do funcionário
        timestamp: DateTime.now(),
        action: action,
        osId: osId,
        osNumero: osNumero,
        description: description,
      );

      await _logRepo.addLog(log);
      print('✓ Log de auditoria registrado');
      print('  Funcionário: $employeeName');
      print('  Ação: $action');
    } catch (e) {
      print('✗ Erro ao registrar log: $e');
    }
  }

  /// Exemplo: Rastrear exclusão de OS
  static Future<void> exemplo_rastrearDelecaoOS({
    required String osId,
    required String osNumero,
    required String employeeId,
    required String employeeName,
  }) async {
    await criarLogComFuncionario(
      osId: osId,
      osNumero: osNumero,
      action: 'DELETE_OS',
      description: 'OS excluída por ${employeeName}',
      employeeId: employeeId,
      employeeName: employeeName,
    );
  }
}

*/
