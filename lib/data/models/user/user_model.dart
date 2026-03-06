import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.companyId,
    super.role = UserRole.user,
    super.isOwner = false,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      companyId: data['companyId'],
      role: UserRoleExtension.fromString(data['role'] ?? 'user'),
      isOwner: data['isOwner'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'companyId': companyId,
      'role': role.value,
      'isOwner': isOwner,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'companyId': companyId,
      'role': role.value,
      'isOwner': isOwner,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'],
      companyId: map['companyId'],
      role: UserRoleExtension.fromString(map['role'] ?? 'user'),
      isOwner: map['isOwner'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Cria um usuário vazio para novo registro
  factory UserModel.empty(String id, String email) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      name: '',
      role: UserRole.user,
      isOwner: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? companyId,
    UserRole? role,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      role: role ?? this.role,
      isOwner: isOwner ?? this.isOwner,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, companyId: $companyId, role: ${role.value}, isOwner: $isOwner, isActive: $isActive)';
  }
}

