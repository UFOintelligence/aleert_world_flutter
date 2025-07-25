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
  final bool likedByUser;
  final int likes;
  final String? token; 
  final String? tipoAlerta;
  final double? latitud;
  final double? longitud;
  final String? archivoPath;

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
    this.likedByUser = false,
    this.likes = 0,
    this.token,
    this.tipoAlerta,
    this.latitud,
    this.longitud,
    this.archivoPath,
  });

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
    bool? likedByUser,
    int? likes,
    String? tipoAlerta,
    double? latitud,
    double? longitud,
    String? archivoPath,
    String? token,
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
      likedByUser: likedByUser ?? this.likedByUser,
      likes: likes ?? this.likes,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      archivoPath: archivoPath ?? this.archivoPath,
      token: token ?? this.token,
    );
  }
}