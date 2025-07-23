import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  AlertModel({
    required int id,
    required int usuarioId,
    required String titulo,
    required String descripcion,
    required String ubicacion,
    String? mediaUrl, // URL multimedia genérica (imagen o video)
    List<String>? comentarios,
    String? usuarioNombre,
    String? usuarioAvatarUrl,
    required DateTime fecha,
    bool likedByUser = false,
    int likes = 0,
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
        );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final mediaUrl = json['mediaUrl'] as String?;

    return AlertModel(
      id: json['id'] ?? 0,
      usuarioId: json['user_id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? 'Ubicación desconocida',
      mediaUrl: mediaUrl,
      comentarios: (json['comentarios'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      usuarioNombre: json['usuario_nombre'],
      usuarioAvatarUrl: json['usuario_avatar'],
      fecha: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      likedByUser: json['likedByUser'] ?? false,
      likes: json['likes'] ?? 0,
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
    );
  }
}
