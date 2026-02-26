import 'package:flutter/foundation.dart';
import 'package:checkos/data/models/employee/employee_model.dart';

/// Contexto global para gerenciar o funcionário atual logado no sistema.
/// 
/// Este contexto é usado para rastrear qual funcionário realizou cada ação,
/// permitindo a auditoria completa das operações no sistema.
/// 
/// ### Uso:
/// 
/// 1. **No App (app.dart):**
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => EmployeeContext()),
///     // ... outros providers
///   ],
///   child: ...
/// )
/// ```
/// 
/// 2. **Definir funcionário atual (após login/seleção):**
/// ```dart
/// context.read<EmployeeContext>().setCurrentEmployee(employee);
/// ```
/// 
/// 3. **Obter funcionário atual em qualquer lugar:**
/// ```dart
/// // No widget
/// final employeeId = context.read<EmployeeContext>().currentEmployeeId;
/// final employeeName = context.read<EmployeeContext>().currentEmployeeName;
/// 
/// // Em classes não-widget (usando Provider.of)
/// final employeeId = Provider.of<EmployeeContext>(context, listen: false).currentEmployeeId;
/// ```
/// 
/// 4. **Verificar se há funcionário logado:**
/// ```dart
/// final hasEmployee = context.read<EmployeeContext>().hasCurrentEmployee;
/// ```
class EmployeeContext extends ChangeNotifier {
  EmployeeModel? _currentEmployee;
  String? _currentCompanyId; // ID da empresa/assinatura do funcionário atual
  bool _isLoading = false;
  String? _errorMessage;

  /// Obtém o funcionário atualmente selecionado/logado.
  EmployeeModel? get currentEmployee => _currentEmployee;

  /// Obtém o ID do funcionário atual.
  /// Retorna null se nenhum funcionário estiver selecionado.
  String? get currentEmployeeId => _currentEmployee?.id;

  /// Obtém o nome do funcionário atual.
  /// Retorna null se nenhum funcionário estiver selecionado.
  String? get currentEmployeeName => _currentEmployee?.name;

  /// Obtém o role (cargo) do funcionário atual.
  /// Retorna null se nenhum funcionário estiver selecionado.
  String? get currentEmployeeRole => _currentEmployee?.role;

  /// Obtém o ID da empresa/assinatura atual.
  /// Retorna null se nenhum funcionário estiver selecionado.
  String? get currentCompanyId => _currentCompanyId;

  /// Verifica se há um funcionário atual selecionado.
  bool get hasCurrentEmployee => _currentEmployee != null;

  /// Verifica se o contexto está em processo de loading.
  bool get isLoading => _isLoading;

  /// Obtém a mensagem de erro atual, se houver.
  String? get errorMessage => _errorMessage;

  /// Define o funcionário atual como o funcionário logado/selecionado.
  /// 
  /// Este método deve ser chamado:
  /// - Após o login bem-sucedido
  /// - Quando o usuário selecionar qual funcionário está usando o sistema
  /// - Ao alternar entre funcionários (se aplicável)
  /// 
  /// [employee] - O funcionário que está usando o sistema
  void setCurrentEmployee(EmployeeModel? employee) {
    if (_currentEmployee?.id != employee?.id) {
      _currentEmployee = employee;
      _currentCompanyId = employee?.companyId; // Define o companyId do funcionário
      _errorMessage = null;
      notifyListeners();
      
      // Log de debug
      if (employee != null) {
        debugPrint('[EmployeeContext] Funcionário definido: ${employee.name} (${employee.id}, companyId: ${employee.companyId})');
      } else {
        debugPrint('[EmployeeContext] Funcionário limpo');
      }
    }
  }

  /// Define o funcionário atual pelo ID e dados.
  /// 
  /// [id] - ID do funcionário
  /// [name] - Nome do funcionário
  /// [role] - Cargo do funcionário
  void setCurrentEmployeeByData({
    required String id,
    required String name,
    String? role,
  }) {
    _currentEmployee = EmployeeModel(
      id: id,
      name: name,
      email: '', // Não necessário para contexto
      role: role ?? 'employee',
      phone: '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _errorMessage = null;
    notifyListeners();
    
    debugPrint('[EmployeeContext] Funcionário definido por dados: $name ($id)');
  }

  /// Limpa o funcionário atual (logout).
  /// 
  /// Deve ser chamado quando o usuário fazer logout do sistema.
  void clearCurrentEmployee() {
    if (_currentEmployee != null) {
      debugPrint('[EmployeeContext] Limpando funcionário: ${_currentEmployee!.name}');
      _currentEmployee = null;
      _currentCompanyId = null; // Limpa também o companyId
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Define estado de loading.
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define mensagem de erro.
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpa mensagem de erro.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  String toString() {
    if (_currentEmployee == null) {
      return 'EmployeeContext(currentEmployee: null)';
    }
    return 'EmployeeContext(currentEmployee: ${_currentEmployee!.name} (${_currentEmployee!.id}, role: ${_currentEmployee!.role}))';
  }
}

