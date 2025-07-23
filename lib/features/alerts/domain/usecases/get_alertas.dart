import 'package:dartz/dartz.dart';
import '../repositories/alert_repository.dart';
import '../entities/alert_entity.dart';
import 'package:alert_world/core/error/failures.dart' as core;

class GetAlertas {
  final AlertRepository repository;

  GetAlertas(this.repository);

  Future<Either<core.Failure, List<AlertEntity>>> call() {
    return repository.getAlertas();
  }
}
