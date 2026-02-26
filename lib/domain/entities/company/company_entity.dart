import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String name;
  final String? cnpj;
  final String? phone;
  final String? address;
  final String? email;
  final String? logoUrl;
  final String plan; // free, basic, premium
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? subscriptionExpiresAt;

  const CompanyEntity({
    required this.id,
    required this.name,
    this.cnpj,
    this.phone,
    this.address,
    this.email,
    this.logoUrl,
    this.plan = 'free',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.subscriptionExpiresAt,
  });

  bool get isSubscriptionActive {
    if (plan == 'free') return true; // Planos free não expiram
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        name,
        cnpj,
        phone,
        address,
        email,
        logoUrl,
        plan,
        isActive,
        createdAt,
        updatedAt,
        subscriptionExpiresAt,
      ];
}

