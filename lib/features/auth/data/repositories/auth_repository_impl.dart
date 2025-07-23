import 'dart:convert';
import 'package:http/http.dart' as http;
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
      final token = result['token'] ?? '';
      final userJson = result['user'];
      print('Login result: $result'); // 👈 Aquí imprimes la respuesta cruda del backend

      if (userJson != null && userJson is Map<String, dynamic>) {
      final user = UserModel.fromJson(userJson).copyWith(token: token);

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
      final token = result['token'] ?? '';
      final userJson = result['user'];

      if (userJson != null && userJson is Map<String, dynamic>) {
        final user = UserModel.fromJson(userJson).copyWith(token: token);

        return Right(user);
      } else {
        return Left(ServerFailure(result['message'] ?? 'Error en registro'));
      }
    } catch (e) {
      return Left(ServerFailure("Error en registro: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUser({
    required int userId,
    required String name,
    required String email,
    String? password,
    String? avatarUrl,
  }) async {
    try {
      final result = await remoteDataSource.updateUser(
        userId: userId,
        name: name,
        email: email,
        password: password,
        avatarUrl: avatarUrl,
      );

      final token = result['token'] ?? '';
      final userJson = result['usuario']; // Laravel devuelve 'usuario' aquí

      if (userJson != null && userJson is Map<String, dynamic>) {
     final user = UserModel.fromJson(userJson).copyWith(token: token);
        return Right(user);
      } else {
        return Left(ServerFailure(result['message'] ?? 'Usuario inválido'));
      }
    } catch (e) {
      return Left(ServerFailure('Error actualizando usuario: ${e.toString()}'));
    }
  }
 
}
