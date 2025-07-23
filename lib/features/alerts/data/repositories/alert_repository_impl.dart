import 'package:alert_world/features/auth/data/datasources/auth_remote_data_source.dart'; 
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import 'package:alert_world/core/error/failures.dart';
import 'package:alert_world/features/auth/data/models/alert_model.dart';
import 'package:alert_world/features/alerts/data/datasources/alert_remote_data_source.dart';

class AlertRepositoryImpl implements AlertRepository {
final Dio dio;
final AlertRemoteDataSource remoteDataSource;

AlertRepositoryImpl({
  required this.dio,
  required this.remoteDataSource,
});


  @override
  Future<Either<Failure, AlertEntity>> toggleLike({
    required int alertId,
    required String userId,
  }) async {
    try {
      final response = await dio.post('/api/alerts/$alertId/toggle-like');

      final updatedAlert = AlertModel.fromJson(response.data).toEntity();

      return right(updatedAlert);
    } on DioException catch (e) {
      return left(Failure(e.response?.data['message'] ?? 'Error desconocido'));
    } catch (e) {
      return left(Failure('Excepción: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlertas() async {
    try {
      final entities = await remoteDataSource.obtenerAlertas(); // nombre correcto
      return Right(entities);
    } catch (e) {
      return Left(Failure('Error al obtener alertas: ${e.toString()}'));
    }
  }
}
