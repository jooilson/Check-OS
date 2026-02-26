import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String? cpf;
  final String? companyId; // ID da empresa/assinatura
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.cpf,
    this.companyId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, role, phone, cpf, companyId, isActive, createdAt, updatedAt];
}
