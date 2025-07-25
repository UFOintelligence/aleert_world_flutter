import 'package:dartz/dartz.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import 'package:alert_world/core/error/failures.dart';
import 'package:alert_world/features/auth/data/models/alert_model.dart';
import 'package:alert_world/features/alerts/data/datasources/alert_remote_data_source.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  AlertRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AlertEntity>> toggleLike({
    required int alertId,
    required String token,
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.toggleLike(alertId, token, userId);
      final updatedAlert = AlertModel.fromJson(response).toEntity();
      return Right(updatedAlert);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlertas() async {
    try {
      final entities = await remoteDataSource.obtenerAlertas();
      return Right(entities);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createAlert(AlertEntity alert) async {
    
    try {
      await remoteDataSource.createAlertRemote({
        'user_id': alert.usuarioId,
        'titulo': alert.titulo,
        'tipo_alerta': alert.tipoAlerta,
        'descripcion': alert.descripcion,
        'latitud': alert.latitud.toString(),
        'longitud': alert.longitud.toString(),
        'archivoPath': alert.archivoPath,
        'token': alert.token, 
      });
      return Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
