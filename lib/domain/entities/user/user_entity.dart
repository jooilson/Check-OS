import 'package:equatable/equatable.dart';

/// Roles disponíveis no sistema
enum UserRole {
  owner,   // Dono da empresa (criador)
  admin,   // Administrador
  user,    // Usuário comum
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.owner:
        return 'owner';
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Dono';
      case UserRole.admin:
        return 'Administrador';
      case UserRole.user:
        return 'Usuário';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? companyId;
  final UserRole role;
  final bool isOwner;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.companyId,
    this.role = UserRole.user,
    this.isOwner = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica se o usuário é admin ou owner
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;

  /// Verifica se pode gerenciar usuários
  bool get canManageUsers => isAdmin;

  /// Verifica se pode gerenciar empresa
  /// Owner e Admin podem editar empresa
  bool get canManageCompany => isAdmin;

  /// Verifica se pode editar outros usuários
  /// Owner e Admin podem editar usuários
  bool get canEditUsers => isAdmin;

  /// Verifica se pode excluir usuários
  /// Owner e Admin podem excluir usuários
  bool get canDeleteUsers => isAdmin;

  /// Verifica se pode excluir dados (diários, OS, etc)
  /// Owner e Admin podem excluir dados
  bool get canDeleteData => isAdmin;

  /// Verifica se pode criar usuários
  /// Owner e Admin podem criar usuários
  bool get canCreateUsers => isAdmin;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        companyId,
        role,
        isOwner,
        isActive,
        createdAt,
        updatedAt,
      ];
}
