// features/alerts/data/models/alert_model.dart
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  AlertModel({
    required int id,
    required String titulo,
    required String descripcion,
    required String ubicacion,
    required String imagenUrl,
    List<String>? comentarios,
  }) : super(
          id: id,
          titulo: titulo,
          descripcion: descripcion,
          ubicacion: ubicacion,
          imagenUrl: imagenUrl,
           comentarios: comentarios,
        );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'] ?? '',
      imagenUrl: json['imagen_url'] ?? '',
      comentarios: (json['comentarios'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'comentarios': comentarios,
    };
  }

  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      ubicacion: ubicacion,
      imagenUrl: imagenUrl,
      comentarios: comentarios,
    );
  }
}
