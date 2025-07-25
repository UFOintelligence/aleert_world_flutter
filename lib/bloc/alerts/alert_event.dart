import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertEvent {}

// Evento para cargar alertas
class LoadAlerts extends AlertEvent {}

// Evento para enviar nueva alerta con entidad AlertEntity
class SubmitAlertEvent extends AlertEvent {
  final AlertEntity alert;

  SubmitAlertEvent(this.alert);
}

// Evento para toggle like
class ToggleLikeEvent extends AlertEvent {
  final int alertId;
  final String userId;
  final String token;

  ToggleLikeEvent({
    required this.alertId,
    required this.userId,
    required this.token,
  });
}
