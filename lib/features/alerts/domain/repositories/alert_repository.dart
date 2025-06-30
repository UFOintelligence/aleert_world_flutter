
import '../entities/alert_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<AlertEntity>>> getAlertas();
}

class Failure {
  final String message;
  Failure(this.message);
}
