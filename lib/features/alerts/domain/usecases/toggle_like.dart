import 'package:dartz/dartz.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';
import 'package:alert_world/core/error/failures.dart' as core;

class ToggleLike {
  final AlertRepository repository;

  ToggleLike(this.repository);

  Future<Either<core.Failure, AlertEntity>> call({
    required int alertId,
    required String userId,
  }) async {
    return await repository.toggleLike(alertId: alertId, userId: userId);
  }
}
