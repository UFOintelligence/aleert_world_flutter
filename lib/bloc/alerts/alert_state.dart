// bloc/alerts/alert_state.dart
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertState {}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<AlertEntity> alertas;
  AlertLoaded(this.alertas);
}

class AlertError extends AlertState {
  final String mensaje;
  AlertError(this.mensaje);
}
