import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkos/data/models/company/company_model.dart';

class CompanyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'companies';

  /// Cria uma nova empresa
  Future<String> createCompany(CompanyModel company) async {
    final docRef = await _firestore.collection(_collection).add(company.toFirestore());
    return docRef.id;
  }

  /// Busca empresa pelo ID
  Future<CompanyModel?> getCompanyById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return CompanyModel.fromFirestore(doc);
  }

  /// Busca empresa pelo email do admin (para verificar se já existe)
  Future<CompanyModel?> getCompanyByAdminEmail(String email) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('adminEmail', isEqualTo: email)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return CompanyModel.fromFirestore(snapshot.docs.first);
  }

  /// Atualiza empresa
  Future<void> updateCompany(CompanyModel company) async {
    await _firestore.collection(_collection).doc(company.id).update(company.toFirestore());
  }

  /// Desativa empresa (soft delete)
  Future<void> deactivateCompany(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ativa empresa
  Future<void> activateCompany(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza plano da assinatura
  Future<void> updateSubscriptionPlan(String companyId, String plan, DateTime? expiresAt) async {
    await _firestore.collection(_collection).doc(companyId).update({
      'plan': plan,
      'subscriptionExpiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza logo da empresa
  Future<void> updateLogo(String companyId, String logoUrl) async {
    await _firestore.collection(_collection).doc(companyId).update({
      'logoUrl': logoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Lista todas as empresas (apenas para super admin)
  Stream<List<CompanyModel>> getCompanies() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CompanyModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Verifica se empresa existe pelo CNPJ
  Future<bool> companyExistsByCNPJ(String cnpj) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('cnpj', isEqualTo: cnpj)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}

