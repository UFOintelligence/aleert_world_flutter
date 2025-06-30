// bloc/alerts/alert_event.dart
abstract class AlertEvent {}

class LoadAlerts extends AlertEvent {}

class CreateAlert extends AlertEvent {
  final String titulo;
  final String descripcion;
  final String? ubicacion;
  final String? imagenUrl;

  CreateAlert({
    required this.titulo,
    required this.descripcion,
    this.ubicacion,
    this.imagenUrl,
  });
}
