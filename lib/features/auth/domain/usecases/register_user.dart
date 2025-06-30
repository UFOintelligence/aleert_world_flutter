import 'package:alert_world/features/auth/data/models/user_model.dart';

import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class RegisterUser {
  final AuthRepository repository;


  RegisterUser(this.repository);

  Future<Either<Failure, UserModel>> call(String name, String email, String password) async {
    return await repository.register(name, email, password);
  }
}