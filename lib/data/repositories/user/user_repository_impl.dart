import 'package:checkos/data/models/user/user_model.dart';
import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:checkos/domain/repositories/user/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> getUserById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> createUser(UserEntity user) async {
    final userModel = UserModel(id: user.id, email: user.email, name: user.name);
    await _firestore.collection('users').doc(user.id).set(userModel.toFirestore());
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(id: user.id, email: user.email, name: user.name);
    await _firestore.collection('users').doc(user.id).update(userModel.toFirestore());
  }
}
