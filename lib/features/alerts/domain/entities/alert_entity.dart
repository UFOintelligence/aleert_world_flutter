class AlertEntity {
  final int id;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String imagenUrl;
  final List<String>? comentarios;

  AlertEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.imagenUrl,
    required this.comentarios,
  });
}
