import 'package:dartz/dartz.dart';
import 'package:alert_world/core/error/failures.dart';
import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class UpdateUser {
  final AuthRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, UserModel>> call({
    required userId,
    required String name,
    required String email,
    String? password,
    String? avatarUrl,
  }) {
    return repository.updateUser(
      userId: userId,
      name: name,
      email: email,
      password: password,
      avatarUrl: avatarUrl,
    );
  }
}
