import 'package:dartz/dartz.dart';
import 'package:alert_world/core/error/failures.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';

class CreateAlert {
  final AlertRepository repository;

  CreateAlert(this.repository);

  Future<Either<Failure, Unit>> call(AlertEntity alert) async {
    return await repository.createAlert(alert);
  }
}
