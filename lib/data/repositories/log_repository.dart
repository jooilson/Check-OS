import 'package:checkos/data/models/log_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'logs';

  Future<void> addLog(LogModel log) async {
    await _firestore.collection(_collection).add(log.toMap());
  }

  Stream<List<LogModel>> getLogs() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<LogModel>> getLogsByOs(String osId) {
    return _firestore
        .collection(_collection)
        .where('osId', isEqualTo: osId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<LogModel>> getLogsByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<LogModel>> getLogsByPeriod(DateTime start, DateTime end) {
    return _firestore
        .collection(_collection)
        .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<LogModel>> getLogsList() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LogModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteAllLogs() async {
    final snapshot = await _firestore.collection(_collection).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}