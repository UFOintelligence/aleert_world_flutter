class AlertEntity {
  final int id;
  final int usuarioId;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String? mediaUrl;
  final List<String>? comentarios;
  final String? usuarioNombre;
  final String? usuarioAvatarUrl;
  final DateTime fecha;
  final int likes;
  final bool likedByUser;

  AlertEntity({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    this.mediaUrl,
    this.comentarios,
    this.usuarioNombre,
    this.usuarioAvatarUrl,
    required this.fecha,
    this.likes = 0,
    this.likedByUser = false,
  });

  factory AlertEntity.fromJson(Map<String, dynamic> json) {
    // Para comentarios, asumiendo que viene una lista de strings o null
    List<String>? comentariosList;
    if (json['comentarios'] != null) {
      comentariosList = List<String>.from(json['comentarios']);
    }

    return AlertEntity(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      mediaUrl: json['media_url'],
      comentarios: comentariosList,
      usuarioNombre: json['usuario_nombre'],
      usuarioAvatarUrl: json['usuario_avatar_url'],
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      likes: json['likes'] ?? 0,
      likedByUser: json['liked_by_user'] ?? false,
    );
  }

  AlertEntity copyWith({
    int? id,
    int? usuarioId,
    String? titulo,
    String? descripcion,
    String? ubicacion,
    String? mediaUrl,
    List<String>? comentarios,
    String? usuarioNombre,
    String? usuarioAvatarUrl,
    DateTime? fecha,
    int? likes,
    bool? likedByUser,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      comentarios: comentarios ?? this.comentarios,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioAvatarUrl: usuarioAvatarUrl ?? this.usuarioAvatarUrl,
      fecha: fecha ?? this.fecha,
      likes: likes ?? this.likes,
      likedByUser: likedByUser ?? this.likedByUser,
    );
  }
}
