import '../repositories/alert_repository.dart';
import '../entities/alert_entity.dart';
import 'package:dartz/dartz.dart';

class GetAlertas {
  final AlertRepository repository;

  GetAlertas(this.repository);

  Future<Either<Failure, List<AlertEntity>>> call() {
    return repository.getAlertas();
  }
}
