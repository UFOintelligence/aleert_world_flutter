import 'package:dartz/dartz.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'package:alert_world/core/error/failures.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<AlertEntity>>> getAlertas();

  Future<Either<Failure, AlertEntity>> toggleLike({
    required int alertId,
    required String userId,
    required String token, 
  });
}
