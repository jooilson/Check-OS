import 'package:checkos/domain/entities/user/user_entity.dart';

/// Serviço centralizado de controle de permissões
/// 
/// Este serviço gerencia todas as regras de acesso do sistema,
/// definindo o que cada tipo de usuário pode ou não fazer.
class PermissionService {
  
  /// Verifica se o usuário pode acessar determinada funcionalidade
  static bool canAccess(UserEntity user, String permission) {
    if (!user.isActive) return false;
    
    switch (permission) {
      // Permissões de gerenciamento de empresa
      case Permission.editCompany:
        return user.canManageCompany; // Owner e Admin
        
      case Permission.viewCompany:
        return user.companyId != null;
        
      // Permissões de gerenciamento de usuários
      case Permission.createUser:
        return user.canCreateUsers; // Owner e Admin
        
      case Permission.editUser:
        return user.canEditUsers; // Owner e Admin
        
      case Permission.deleteUser:
        return user.canDeleteUsers; // Owner e Admin
        
      case Permission.manageUserRoles:
        return user.role == UserRole.owner;
        
      // Permissões de dados
      case Permission.viewAllData:
        return user.isAdmin;
        
      case Permission.editOwnData:
        return user.companyId != null;
        
      // Permissões administrativas
      case Permission.accessSettings:
        return user.isAdmin;
        
      case Permission.viewLogs:
        return user.isAdmin;
        
      case Permission.exportData:
        return user.isAdmin;
        
      // Permissões de exclusão de dados
      case Permission.deleteDiario:
        return user.canDeleteData; // Owner e Admin
        
      case Permission.deleteOS:
        return user.canDeleteData; // Owner e Admin
        
      default:
        return false;
    }
  }

  /// Verifica se o usuário pode editar outro usuário específico
  static bool canEditThisUser(UserEntity currentUser, UserEntity targetUser) {
    // Usuário inativo não pode editar ninguém
    if (!currentUser.isActive) return false;
    
    // Owner pode editar qualquer um (exceto outros owners)
    if (currentUser.role == UserRole.owner) {
      return true;
    }
    
    // Admin pode editar usuários comuns e outros admins
    if (currentUser.role == UserRole.admin) {
      // Não pode editar owner
      if (targetUser.role == UserRole.owner) return false;
      return true;
    }
    
    // Usuário comum não pode editar ninguém
    return false;
  }

  /// Verifica se o usuário pode excluir outro usuário específico
  static bool canDeleteThisUser(UserEntity currentUser, UserEntity targetUser) {
    // Owner e Admin podem excluir
    if (!currentUser.canDeleteUsers) return false;
    
    // Não pode excluir a si mesmo
    if (currentUser.id == targetUser.id) return false;
    
    // Não pode excluir owners
    if (targetUser.role == UserRole.owner) return false;
    
    return true;
  }

  /// Verifica se o usuário pode alterar o role de outro usuário
  static bool canChangeRole(UserEntity currentUser, UserEntity targetUser, UserRole newRole) {
    // Apenas owner pode alterar roles
    if (currentUser.role != UserRole.owner) return false;
    
    // Não pode alterar role de outro owner
    if (targetUser.role == UserRole.owner && targetUser.id != currentUser.id) {
      return false;
    }
    
    // Não pode tornar alguém owner (apenas via criação)
    if (newRole == UserRole.owner) return false;
    
    return true;
  }

  /// Retorna lista de permissões do usuário
  static List<String> getUserPermissions(UserEntity user) {
    if (!user.isActive) return [];
    
    List<String> permissions = [];
    
    // Permissões base (todos os usuários ativos)
    permissions.addAll([
      Permission.editOwnData,
      Permission.viewCompany,
    ]);
    
    // Permissões de admin e owner
    if (user.isAdmin) {
      permissions.addAll([
        Permission.viewAllData,
        Permission.accessSettings,
        Permission.viewLogs,
        Permission.exportData,
        Permission.createUser,
        Permission.editUser,
        Permission.deleteUser,
        Permission.editCompany,
        Permission.deleteDiario,
        Permission.deleteOS,
      ]);
    }
    
    // Permissões exclusivas de owner
    if (user.role == UserRole.owner) {
      permissions.addAll([
        Permission.manageUserRoles,
      ]);
    }
    
    return permissions;
  }

  /// Mensagem de erro quando acesso é negado
  static String getAccessDeniedMessage(String permission) {
    switch (permission) {
      case Permission.createUser:
        return 'Apenas administradores podem criar novos usuários.';
      case Permission.editUser:
        return 'Você não tem permissão para editar este usuário.';
      case Permission.deleteUser:
        return 'Apenas administradores podem excluir usuários.';
      case Permission.manageUserRoles:
        return 'Apenas o dono da empresa pode gerenciar permissões.';
      case Permission.editCompany:
        return 'Apenas administradores podem editar as informações da empresa.';
      case Permission.accessSettings:
        return 'Apenas administradores podem acessar as configurações.';
      case Permission.viewLogs:
        return 'Apenas administradores podem ver os logs.';
      case Permission.exportData:
        return 'Apenas administradores podem exportar dados.';
      case Permission.deleteDiario:
      case Permission.deleteOS:
        return 'Apenas administradores podem excluir dados.';
      default:
        return 'Você não tem permissão para realizar esta ação.';
    }
  }
}

/// Constantes de permissões do sistema
class Permission {
  // Empresa
  static const String editCompany = 'edit_company';
  static const String viewCompany = 'view_company';
  
  // Usuários
  static const String createUser = 'create_user';
  static const String editUser = 'edit_user';
  static const String deleteUser = 'delete_user';
  static const String manageUserRoles = 'manage_user_roles';
  
  // Dados
  static const String viewAllData = 'view_all_data';
  static const String editOwnData = 'edit_own_data';
  
  // Exclusão de dados
  static const String deleteDiario = 'delete_diario';
  static const String deleteOS = 'delete_os';
  
  // Administrativo
  static const String accessSettings = 'access_settings';
  static const String viewLogs = 'view_logs';
  static const String exportData = 'export_data';
}
