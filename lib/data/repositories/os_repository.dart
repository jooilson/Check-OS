import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/os_model.dart';
import '../../core/utils/logger.dart';

class OsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addOs(OsModel os) async {
    final docRef = await _firestore.collection('os').add(os.toMap());
    return docRef.id;
  }

  Future<void> updateOs(OsModel os) async {
    await _firestore.collection('os').doc(os.id).update(os.toMap());
  }
  
  Future<void> updateOsStatus(String osId,
      {required bool osfinalizado, required bool pendente}) async {
    await _firestore.collection('os').doc(osId).update({
      'osfinalizado': osfinalizado,
      'pendente': pendente,
    });
  }

  Future<OsModel?> getOsById(String id) async {
    final doc = await _firestore.collection('os').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return OsModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> deleteOs(String id) async {
    await _firestore.collection('os').doc(id).delete();
  }

  /// Stream de OS filtrado por companyId
  Stream<List<OsModel>> getOs({String? companyId}) {
    Query query = _firestore.collection('os');
    
    // Filtrar por companyId se fornecido
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  /// Método com paginação para carregar OS em lotes de 20 documentos.
  /// [limit] - número de documentos por página (padrão: 20)
  /// [lastDocument] - documento cursor para carregar a próxima página (opcional)
  /// [companyId] - filtra por empresa (opcional)
  /// Retorna uma tupla com (lista de OS, último documento da consulta)
  Future<(List<OsModel>, DocumentSnapshot?)> getOsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? companyId,
  }) async {
    Query query = _firestore.collection('os')
        .orderBy('updatedAt', descending: true)
        .limit(limit);
    
    // Filtrar por companyId se fornecido
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    // Se tem cursor, começa após o último documento
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    
    final snapshot = await query.get();
    
    final osList = snapshot.docs
        .map((doc) => OsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    // Retorna a lista e o último documento (se houver)
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (osList, lastDoc);
  }

  /// Lista de OS filtrada por companyId
  Future<List<OsModel>> getOsList({String? companyId}) async {
    Query query = _firestore.collection('os');
    
    // Filtrar por companyId se fornecido
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => OsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> deleteAllOs({String? companyId}) async {
    Query query = _firestore.collection('os');
    
    // Filtrar por companyId se fornecido
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    final snapshot = await query.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Calcula o KM total (OS + Diários) e atualiza o campo 'totalKm' na OS.
  Future<void> calcularAtualizarTotalKm(String osId) async {
    try {
      // 1. Busca dados da OS para pegar KM Inicial e Final
      final osDoc = await _firestore.collection('os').doc(osId).get();
      if (!osDoc.exists) return;
      final osData = osDoc.data()!;
      
      double totalKm = 0;
      if (osData['kmInicial'] != null && osData['kmFinal'] != null) {
        final diff = (osData['kmFinal'] as num).toDouble() - (osData['kmInicial'] as num).toDouble();
        if (diff > 0) totalKm += diff;
      }

      // 2. Busca todos os diários dessa OS
      final diariosSnapshot = await _firestore.collection('diarios').where('osId', isEqualTo: osId).get();
      for (var doc in diariosSnapshot.docs) {
        final dData = doc.data();
        if (dData['kmInicial'] != null && dData['kmFinal'] != null) {
          final diff = (dData['kmFinal'] as num).toDouble() - (dData['kmInicial'] as num).toDouble();
          if (diff > 0) totalKm += diff;
        }
      }

      // 3. Atualiza o campo na OS
      await _firestore.collection('os').doc(osId).update({'totalKm': totalKm});
    } catch (e) {
      AppLogger.error('Erro ao calcular total KM', e);
    }
  }
}

