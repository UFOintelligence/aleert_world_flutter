abstract class AlertEvent {}

class LoadAlerts extends AlertEvent {}

class CreateAlert extends AlertEvent {
  final String titulo;
  final String descripcion;
  final String? ubicacion;
  final String? mediaUrl;  // cambiado de imagenUrl a mediaUrl

  CreateAlert({
    required this.titulo,
    required this.descripcion,
    this.ubicacion,
    this.mediaUrl,
  });
  
}


class ToggleLikeEvent extends AlertEvent {
  final int alertId;
  final String userId;  // 👈 Add this line

  ToggleLikeEvent({
    required this.alertId,
    required this.userId,  // 👈 Pass the userId in the constructor
  });
}

