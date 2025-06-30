import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:alert_world/core/error/failures.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);

      if (result.containsKey('token') && result.containsKey('user')) {
        final user = UserModel.fromJson(result); // 👈 Pasamos el JSON completo
        return Right(user);
      } else {
        return Left(ServerFailure(result['message'] ?? 'Error en login'));
      }
    } catch (e) {
      return Left(ServerFailure('Error en login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(String name, String email, String password) async {
    try {
      final result = await remoteDataSource.register(name, email, password);

      if (result.containsKey('token') && result.containsKey('user')) {
        final userModel = UserModel.fromJson(result); // 👈 También pasamos el JSON completo aquí
        return Right(userModel);
      } else {
        return Left(ServerFailure(result['message'] ?? 'Error en registro'));
      }
    } catch (e) {
      return Left(ServerFailure("Error en registro: ${e.toString()}"));
    }
  }
}
