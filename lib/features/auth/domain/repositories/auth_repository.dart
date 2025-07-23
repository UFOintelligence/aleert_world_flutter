import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(String name, String email, String password);
  
  Future<Either<Failure, UserModel>> updateUser({
    required int userId, 
    required String name,
    required String email,
    String? password,
    String? avatarUrl,
  });
}
