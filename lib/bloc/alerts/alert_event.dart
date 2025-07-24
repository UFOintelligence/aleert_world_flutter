abstract class AlertEvent {}

// 📥 Cargar alertas
class LoadAlerts extends AlertEvent {}

// ➕ Crear alerta (se usará en una futura implementación)
class CreateAlert extends AlertEvent {
  final String titulo;
  final String descripcion;
  final String? ubicacion;
  final String? mediaUrl;

  CreateAlert({
    required this.titulo,
    required this.descripcion,
    this.ubicacion,
    this.mediaUrl,
  });
}

// ❤️ Alternar Like
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