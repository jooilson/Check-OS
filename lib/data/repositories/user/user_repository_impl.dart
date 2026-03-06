import 'package:checkos/data/models/user/user_model.dart';
import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:checkos/domain/repositories/user/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<UserEntity?> getUserById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Busca usuário por email
  Future<UserEntity?> getUserByEmail(String email) async {
    final snapshot = await _usersCollection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Busca todos os usuários de uma empresa
  Future<List<UserEntity>> getUsersByCompany(String companyId) async {
    final snapshot = await _usersCollection
        .where('companyId', isEqualTo: companyId)
        .get();
    
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> createUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      companyId: user.companyId,
      role: user.role,
      isOwner: user.isOwner,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    await _usersCollection.doc(user.id).set(userModel.toFirestore());
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      companyId: user.companyId,
      role: user.role,
      isOwner: user.isOwner,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    await _usersCollection.doc(user.id).update(userModel.toFirestore());
  }

  /// Atualiza empresa do usuário
  Future<void> updateUserCompany(String userId, String companyId) async {
    await _usersCollection.doc(userId).update({
      'companyId': companyId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza role do usuário
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _usersCollection.doc(userId).update({
      'role': role.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ativa/desativa usuário
  Future<void> setUserActive(String userId, bool isActive) async {
    await _usersCollection.doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deleta usuário (soft delete - apenas desativa)
  Future<void> deleteUser(String userId) async {
    await setUserActive(userId, false);
  }

  /// Verifica se existe owner para uma empresa
  Future<bool> hasOwner(String companyId) async {
    final snapshot = await _usersCollection
        .where('companyId', isEqualTo: companyId)
        .where('isOwner', isEqualTo: true)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  /// Busca owner de uma empresa
  Future<UserEntity?> getOwner(String companyId) async {
    final snapshot = await _usersCollection
        .where('companyId', isEqualTo: companyId)
        .where('isOwner', isEqualTo: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }
}

