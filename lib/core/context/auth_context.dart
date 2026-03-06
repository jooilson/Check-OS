import 'package:flutter/foundation.dart';
import 'package:checkos/data/models/user/user_model.dart';
import 'package:checkos/data/models/company/company_model.dart';
import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:checkos/services/permission_service.dart';

/// Contexto de autenticação global que gerencia:
/// - Usuário logado
/// - Empresa atual
/// - Permissões e roles
class AuthContext extends ChangeNotifier {
  UserModel? _currentUser;
  CompanyModel? _currentCompany;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  CompanyModel? get currentCompany => _currentCompany;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  
  // Verificações de role
  bool get isLoggedIn => _currentUser != null;
  bool get hasCompany => _currentCompany != null;
  bool get isOwner => _currentUser?.role == UserRole.owner;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isUser => _currentUser?.role == UserRole.user;
  bool get isActive => _currentUser?.isActive ?? false;
  
  // Getters de convenience
  String? get userId => _currentUser?.id;
  String? get companyId => _currentUser?.companyId ?? _currentCompany?.id;
  UserRole? get userRole => _currentUser?.role;

  // Novas verificações de permissão
  bool get canEditCompany => _currentUser?.canManageCompany ?? false;
  bool get canCreateUsers => _currentUser?.canCreateUsers ?? false;
  bool get canEditUsers => _currentUser?.canEditUsers ?? false;
  bool get canDeleteUsers => _currentUser?.canDeleteUsers ?? false;
  bool get canDeleteData => _currentUser?.canDeleteData ?? false;

  /// Inicializa o contexto (chamado ao iniciar o app)
  void initialize() {
    _isInitialized = true;
    notifyListeners();
  }

  /// Define o usuário atual
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
    
    if (user != null) {
      debugPrint('[AuthContext] Usuário definido: ${user.name} (${user.role.value})');
    } else {
      debugPrint('[AuthContext] Usuário limpo');
    }
  }

  /// Define a empresa atual
  void setCurrentCompany(CompanyModel? company) {
    _currentCompany = company;
    notifyListeners();
    
    if (company != null) {
      debugPrint('[AuthContext] Empresa definida: ${company.name} (${company.id})');
    } else {
      debugPrint('[AuthContext] Empresa limpa');
    }
  }

  /// Define usuário e empresa juntos (após login)
  Future<void> setUserAndCompany(UserModel user, CompanyModel? company) async {
    _currentUser = user;
    _currentCompany = company;
    _errorMessage = null;
    notifyListeners();
    
    debugPrint('[AuthContext] Login realizado: ${user.name} - ${user.role.value} - Empresa: ${company?.name ?? "N/A"}');
  }

  /// Define estado de loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define mensagem de erro
  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa tudo (logout)
  void clearAll() {
    _currentUser = null;
    _currentCompany = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    
    debugPrint('[AuthContext] Logout realizado - contexto limpo');
  }

  /// Atualiza apenas a empresa (sem afetar o usuário)
  void updateCompany(CompanyModel company) {
    _currentCompany = company;
    notifyListeners();
  }

  /// Atualiza o role do usuário em memória
  void updateUserRole(UserRole role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
    }
  }

  /// Atualiza companyId do usuário em memória
  void updateUserCompanyId(String companyId) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(companyId: companyId);
      notifyListeners();
    }
  }

  /// Verifica se tem permissão para algo (genérica)
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    return PermissionService.canAccess(_currentUser!, permission);
  }

  /// Verifica se pode editar empresa
  bool canEditThisCompany() {
    if (_currentUser == null) return false;
    return _currentUser!.canManageCompany;
  }

  /// Verifica se pode criar usuário
  bool canCreateThisUser() {
    if (_currentUser == null) return false;
    return _currentUser!.canCreateUsers;
  }

  /// Verifica se pode editar outro usuário
  bool canEditThisUser(UserModel targetUser) {
    if (_currentUser == null) return false;
    return PermissionService.canEditThisUser(_currentUser!, targetUser);
  }

  /// Verifica se pode excluir outro usuário
  bool canDeleteThisUser(UserModel targetUser) {
    if (_currentUser == null) return false;
    return PermissionService.canDeleteThisUser(_currentUser!, targetUser);
  }

  /// Verifica se pode excluir diários
  bool canDeleteThisDiario() {
    if (_currentUser == null) return false;
    return _currentUser!.canDeleteData;
  }

  /// Verifica se pode excluir OS
  bool canDeleteThisOS() {
    if (_currentUser == null) return false;
    return _currentUser!.canDeleteData;
  }

  /// Mensagem de acesso negado
  String getAccessDeniedMessage(String permission) {
    return PermissionService.getAccessDeniedMessage(permission);
  }

  @override
  String toString() {
    return 'AuthContext(user: ${_currentUser?.name ?? "null"}, company: ${_currentCompany?.name ?? "null"}, role: ${_currentUser?.role.value ?? "null"})';
  }
}
