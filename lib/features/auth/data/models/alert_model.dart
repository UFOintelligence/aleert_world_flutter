import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
class AlertModel extends AlertEntity {
  AlertModel({
    required int id,
    required int usuarioId,
    required String titulo,
    required String descripcion,
    required String ubicacion,
    String? mediaUrl,
    List<String>? comentarios,
    String? usuarioNombre,
    String? usuarioAvatarUrl,
    required DateTime fecha,
    bool likedByUser = false,
    int likes = 0,

    // Nuevos parámetros
    String? tipoAlerta,
    double? latitud,
    double? longitud,
    String? archivoPath,
  }) : super(
          id: id,
          usuarioId: usuarioId,
          titulo: titulo,
          descripcion: descripcion,
          ubicacion: ubicacion,
          mediaUrl: mediaUrl,
          comentarios: comentarios,
          usuarioNombre: usuarioNombre,
          usuarioAvatarUrl: usuarioAvatarUrl,
          fecha: fecha,
          likedByUser: likedByUser,
          likes: likes,
          tipoAlerta: tipoAlerta,
          latitud: latitud,
          longitud: longitud,
          archivoPath: archivoPath,
        );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      usuarioId: json['user_id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? 'Ubicación desconocida',
      mediaUrl: json['mediaUrl'],
      comentarios: (json['comentarios'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      usuarioNombre: json['usuario_nombre'],
      usuarioAvatarUrl: json['usuario_avatar'],
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      likedByUser: json['likedByUser'] ?? false,
      likes: json['likes'] ?? 0,

      // Nuevos campos
      tipoAlerta: json['tipo_alerta'],
      latitud: (json['latitud'] != null) ? double.tryParse(json['latitud'].toString()) : null,
      longitud: (json['longitud'] != null) ? double.tryParse(json['longitud'].toString()) : null,
      archivoPath: json['archivo_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': usuarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'mediaUrl': mediaUrl,
      'comentarios': comentarios,
      'usuario_nombre': usuarioNombre,
      'usuario_avatar': usuarioAvatarUrl,
      'fecha': fecha.toIso8601String(),
      'likedByUser': likedByUser,
      'likes': likes,

      // Nuevos campos
      'tipo_alerta': tipoAlerta,
      'latitud': latitud,
      'longitud': longitud,
      'archivo_path': archivoPath,
    };
  }

  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo,
      descripcion: descripcion,
      ubicacion: ubicacion,
      mediaUrl: mediaUrl,
      comentarios: comentarios,
      usuarioNombre: usuarioNombre,
      usuarioAvatarUrl: usuarioAvatarUrl,
      fecha: fecha,
      likedByUser: likedByUser,
      likes: likes,
      tipoAlerta: tipoAlerta,
      latitud: latitud,
      longitud: longitud,
      archivoPath: archivoPath,
    );
  }
}
