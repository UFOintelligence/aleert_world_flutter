// features/alerts/data/datasources/alert_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alert_world/features/auth/data/models/alert_model.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertEntity>> obtenerAlertas();
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AlertRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<AlertEntity>> obtenerAlertas() async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/alertas'),
      headers: {
        'Accept': 'application/json',
      },
    );

    print("RESPONSE STATUS: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final models = jsonData.map((e) => AlertModel.fromJson(e)).toList();
      return models.map((m) => m.toEntity()).toList();
    } else {
      throw Exception('Error al obtener alertas: ${response.statusCode}');
    }
  }
  
  
}
