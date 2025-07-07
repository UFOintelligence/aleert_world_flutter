// features/alerts/data/repositories/alert_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import 'package:alert_world/features/alerts/data/datasources/alert_remote_data_source.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  AlertRepositoryImpl(this.remoteDataSource);

 @override
Future<Either<Failure, List<AlertEntity>>> getAlertas() async {
  try {
    final entities = await remoteDataSource.obtenerAlertas(); // ✅ ya devuelve entidades
    return Right(entities);
  } catch (e) {
    return Left(Failure('Error al obtener alertas: ${e.toString()}'));
  }
}


}
