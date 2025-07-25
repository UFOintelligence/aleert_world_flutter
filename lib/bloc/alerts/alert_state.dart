import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertState {}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<AlertEntity> alerts;

  AlertLoaded(this.alerts);

  AlertLoaded copyWith({List<AlertEntity>? alerts}) {
    return AlertLoaded(alerts ?? this.alerts);
  }
}

class AlertError extends AlertState {
  final String message;

  AlertError(this.message);
}

class AlertSubmitting extends AlertState {}

class AlertSuccess extends AlertState {}
