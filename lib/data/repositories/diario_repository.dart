import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkos/data/models/diario_model.dart';

class DiarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método para adicionar companyId ao diário
  /// Este método deve ser chamado passando o companyId do contexto
  Future<String> addDiario(DiarioModel diario, String companyId) async {
    try {
      // Usa agregação COUNT do Firestore para contar sem buscar todos os documentos
      final countSnapshot = await _firestore
          .collection('diarios')
          .where('companyId', isEqualTo: companyId)
          .where('osId', isEqualTo: diario.osId)
          .count()
          .get();

      // Calcula o número do novo diário (ex: 1.1, 1.2, 1.3, etc)
      final proximoNumeroDiario = (countSnapshot.count ?? 0) + 1;
      
      // Extrai o número da OS (ex: "OS-001" vira 1)
      final numeroOsInt = int.parse(diario.numeroOs.replaceAll(RegExp(r'[^0-9]'), ''));
      
      // Cria o número completo (ex: 1.1)
      final numeroDiario = double.parse('$numeroOsInt.$proximoNumeroDiario');

      // Adiciona o número ao diário e o companyId
      final diarioComNumero = diario.copyWith(
        numeroDiario: numeroDiario,
        companyId: companyId,
      );

      final docRef = await _firestore
          .collection('diarios')
          .add(diarioComNumero.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar diário: $e');
    }
  }

  Future<void> updateDiario(DiarioModel diario) async {
    try {
      await _firestore
          .collection('diarios')
          .doc(diario.id)
          .update(diario.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar diário: $e');
    }
  }

  Future<void> deleteDiario(String diarioId) async {
    try {
      await _firestore.collection('diarios').doc(diarioId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar diário: $e');
    }
  }

  Future<DiarioModel?> getDiario(String diarioId) async {
    try {
      final doc =
          await _firestore.collection('diarios').doc(diarioId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return DiarioModel.fromMap(doc.id, data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar diário: $e');
    }
  }

  /// Stream de diários filtrado por companyId e osId
  Stream<List<DiarioModel>> getDiariosStream(String companyId, String osId) {
    return _firestore
        .collection('diarios')
        .where('companyId', isEqualTo: companyId)
        .where('osId', isEqualTo: osId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DiarioModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  /// Lista de diários filtrado por companyId e osId
  Future<List<DiarioModel>> getDiarios(String companyId, String osId) async {
    try {
      final snapshot = await _firestore
          .collection('diarios')
          .where('companyId', isEqualTo: companyId)
          .where('osId', isEqualTo: osId)
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DiarioModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar diários: $e');
    }
  }

  /// Método com paginação para carregar diários de uma OS em lotes.
  /// [companyId] - ID da empresa (obrigatório para multiempresa)
  /// [osId] - ID da Ordem de Serviço
  /// [limit] - número de documentos por página (padrão: 20)
  /// [lastDocument] - documento cursor para carregar a próxima página (opcional)
  /// Retorna uma tupla com (lista de diários, último documento da consulta)
  Future<(List<DiarioModel>, DocumentSnapshot?)> getDiariosPaginated(
    String companyId,
    String osId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('diarios')
          .where('companyId', isEqualTo: companyId)
          .where('osId', isEqualTo: osId)
          .orderBy('data', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final diariosList = snapshot.docs
          .map((doc) => DiarioModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return (diariosList, lastDoc);
    } catch (e) {
      throw Exception('Erro ao buscar diários paginados: $e');
    }
  }

  /// Lista todos os diários de uma empresa
  Future<List<DiarioModel>> getAllDiarios(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('diarios')
          .where('companyId', isEqualTo: companyId)
          .get();
      return snapshot.docs
          .map((doc) => DiarioModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar todos os diários: $e');
    }
  }

  /// Método com paginação para carregar todos os diários de uma empresa em lotes.
  /// [companyId] - ID da empresa (obrigatório para multiempresa)
  /// [limit] - número de documentos por página (padrão: 20)
  /// [lastDocument] - documento cursor para carregar a próxima página (opcional)
  /// Retorna uma tupla com (lista de diários, último documento da consulta)
  Future<(List<DiarioModel>, DocumentSnapshot?)> getAllDiariosPaginated(
    String companyId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('diarios')
          .where('companyId', isEqualTo: companyId)
          .orderBy('data', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final diariosList = snapshot.docs
          .map((doc) => DiarioModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return (diariosList, lastDoc);
    } catch (e) {
      throw Exception('Erro ao buscar diários paginados: $e');
    }
  }

  /// Deleta todos os diários de uma empresa específica
  Future<void> deleteAllDiarios(String companyId) async {
    final snapshot = await _firestore
        .collection('diarios')
        .where('companyId', isEqualTo: companyId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Deleta todos os diários de uma OS específica (dentro de uma empresa)
  Future<void> deleteDiariosByOsId(String companyId, String osId) async {
    final snapshot = await _firestore
        .collection('diarios')
        .where('companyId', isEqualTo: companyId)
        .where('osId', isEqualTo: osId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

