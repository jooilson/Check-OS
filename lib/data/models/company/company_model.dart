import 'package:checkos/domain/entities/company/company_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.name,
    super.cnpj,
    super.phone,
    super.address,
    super.email,
    super.logoUrl,
    super.plan,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.subscriptionExpiresAt,
    super.ownerId, // NOVO: ID do dono da empresa
  });

  factory CompanyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CompanyModel(
      id: doc.id,
      name: data['name'] ?? '',
      cnpj: data['cnpj'],
      phone: data['phone'],
      address: data['address'],
      email: data['email'],
      logoUrl: data['logoUrl'],
      plan: data['plan'] ?? 'free',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      subscriptionExpiresAt: data['subscriptionExpiresAt'] != null
          ? (data['subscriptionExpiresAt'] as Timestamp).toDate()
          : null,
      ownerId: data['ownerId'], // NOVO
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cnpj': cnpj,
      'phone': phone,
      'address': address,
      'email': email,
      'logoUrl': logoUrl,
      'plan': plan,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'subscriptionExpiresAt': subscriptionExpiresAt != null
          ? Timestamp.fromDate(subscriptionExpiresAt!)
          : null,
      'ownerId': ownerId, // NOVO
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cnpj': cnpj,
      'phone': phone,
      'address': address,
      'email': email,
      'logoUrl': logoUrl,
      'plan': plan,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'ownerId': ownerId, // NOVO
    };
  }

  factory CompanyModel.fromMap(String id, Map<String, dynamic> map) {
    return CompanyModel(
      id: id,
      name: map['name'] ?? '',
      cnpj: map['cnpj'],
      phone: map['phone'],
      address: map['address'],
      email: map['email'],
      logoUrl: map['logoUrl'],
      plan: map['plan'] ?? 'free',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      subscriptionExpiresAt: map['subscriptionExpiresAt'] != null
          ? DateTime.parse(map['subscriptionExpiresAt'])
          : null,
      ownerId: map['ownerId'], // NOVO
    );
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? phone,
    String? address,
    String? email,
    String? logoUrl,
    String? plan,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? subscriptionExpiresAt,
    String? ownerId,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      plan: plan ?? this.plan,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  String toString() {
    return 'CompanyModel(id: $id, name: $name, cnpj: $cnpj, plan: $plan, isActive: $isActive, ownerId: $ownerId)';
  }
}

