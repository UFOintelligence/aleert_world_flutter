class AlertEntity {
  final int id;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String imagenUrl;
  final String? videoUrl;
  final List<String>? comentarios;
  final String? usuarioNombre;
  final String? usuarioAvatarUrl;
  final DateTime fecha; // fecha de creación de la alerta
  int likes;   
   bool likedByUser;   // contador de "me gusta"


  AlertEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.imagenUrl,
    required this.videoUrl,
    required this.comentarios,
    required this.usuarioNombre,
    required this.usuarioAvatarUrl,
    required this.fecha,
    required this.likes,
    required this.likedByUser,
  });
}
