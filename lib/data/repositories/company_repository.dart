import 'package:checkos/data/models/company/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _companiesCollection => _firestore.collection('companies');

  /// Busca empresa por ID
  Future<CompanyModel?> getCompanyById(String id) async {
    try {
      final doc = await _companiesCollection.doc(id).get();
      if (doc.exists) {
        return CompanyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching company: $e');
      return null;
    }
  }

  /// Busca empresa por CNPJ
  Future<CompanyModel?> getCompanyByCNPJ(String cnpj) async {
    try {
      final snapshot = await _companiesCollection
          .where('cnpj', isEqualTo: cnpj)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return CompanyModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching company by CNPJ: $e');
      return null;
    }
  }

  /// Cria nova empresa
  Future<String> createCompany({
    required String name,
    required String ownerId,
    String? cnpj,
    String? phone,
    String? address,
    String? email,
    String plan = 'free',
  }) async {
    try {
      final docRef = await _companiesCollection.add({
        'name': name,
        'ownerId': ownerId,
        'cnpj': cnpj,
        'phone': phone,
        'address': address,
        'email': email,
        'plan': plan,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating company: $e');
      rethrow;
    }
  }

  /// Atualiza empresa
  Future<void> updateCompany(String companyId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _companiesCollection.doc(companyId).update(data);
    } catch (e) {
      print('Error updating company: $e');
      rethrow;
    }
  }

  /// Ativa/desativa empresa
  Future<void> setCompanyActive(String companyId, bool isActive) async {
    await _companiesCollection.doc(companyId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza plano da empresa
  Future<void> updateCompanyPlan(String companyId, String plan) async {
    await _companiesCollection.doc(companyId).update({
      'plan': plan,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza data de expiração da assinatura
  Future<void> updateSubscriptionExpiry(String companyId, DateTime? expiryDate) async {
    await _companiesCollection.doc(companyId).update({
      'subscriptionExpiresAt': expiryDate != null 
          ? Timestamp.fromDate(expiryDate) 
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deleta empresa (soft delete)
  Future<void> deleteCompany(String companyId) async {
    await setCompanyActive(companyId, false);
  }

  /// Verifica se CNPJ já existe
  Future<bool> cnpjExists(String cnpj) async {
    final snapshot = await _companiesCollection
        .where('cnpj', isEqualTo: cnpj)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }
}

