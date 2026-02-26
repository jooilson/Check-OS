import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:checkos/domain/repositories/user/user_repository.dart';

class GetUserDetails {
  final UserRepository repository;

  GetUserDetails(this.repository);

  Future<UserEntity?> call(String id) {
    return repository.getUserById(id);
  }
}
