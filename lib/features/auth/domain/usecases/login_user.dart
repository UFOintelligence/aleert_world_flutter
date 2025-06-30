import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';



class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, UserModel>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}


