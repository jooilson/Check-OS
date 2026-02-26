import 'package:checkos/domain/entities/user/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
}
