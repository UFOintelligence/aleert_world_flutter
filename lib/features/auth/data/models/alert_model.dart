import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  AlertModel({
    required int id,
    required String titulo,
    required String descripcion,
    required String ubicacion,
    required String imagenUrl,
    required String? videoUrl,
    List<String>? comentarios,
    String? usuarioNombre,
    String? usuarioAvatarUrl,
    required DateTime fecha, 
    bool likedByUser = false,  // <-- aquí con coma
    int likes = 0,             // <-- aquí con coma
  }) : super(
          id: id,
          titulo: titulo,
          descripcion: descripcion,
          ubicacion: ubicacion,
          imagenUrl: imagenUrl,
          videoUrl: videoUrl,
          comentarios: comentarios,
          usuarioNombre: usuarioNombre,
          usuarioAvatarUrl: usuarioAvatarUrl,
          likedByUser: likedByUser,   // <-- pasa a padre si está declarado allá
          likes: likes,  
           fecha: fecha, 
                       // <-- pasa a padre si está declarado allá
        );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final archivo = json['archivo'] as String?;
    const baseUrl = 'http://10.0.2.2:8000/storage/alertas/';

    String imagenUrl = '';
    String? videoUrl;

    if (archivo != null) {
      if (archivo.endsWith('.jpg') || archivo.endsWith('.jpeg') || archivo.endsWith('.png')) {
        imagenUrl = baseUrl + archivo;
      } else if (archivo.endsWith('.mp4')) {
        videoUrl = baseUrl + archivo;
      }
    }

    return AlertModel(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'] ?? '',
      imagenUrl: imagenUrl,
      videoUrl: videoUrl,
      comentarios: (json['comentarios'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      usuarioNombre: json['usuario_nombre'],
      usuarioAvatarUrl: json['usuario_avatar'],
      fecha: json['created_at'] != null
        ? DateTime.tryParse(json['fecha']) ?? DateTime.now()
        : DateTime.now(),
    likedByUser: json.containsKey('likedByUser') ? json['likedByUser'] : false,
    likes: json.containsKey('likes') ? json['likes'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'video_url': videoUrl,
      'comentarios': comentarios,
      'usuario_nombre': usuarioNombre,
      'usuario_avatar': usuarioAvatarUrl,
      'likedByUser': likedByUser,
      'likes': likes,
    };
  }

  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      ubicacion: ubicacion,
      imagenUrl: imagenUrl,
      videoUrl: videoUrl,
      comentarios: comentarios,
      usuarioNombre: usuarioNombre,
      usuarioAvatarUrl: usuarioAvatarUrl,
      fecha: fecha,
      likedByUser: likedByUser,
      likes: likes,
    );
  }
}
