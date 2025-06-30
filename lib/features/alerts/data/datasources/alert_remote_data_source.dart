// features/alerts/data/datasources/alert_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alert_world/features/auth/data/models/alert_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertModel>> obtenerAlertas();
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AlertRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<AlertModel>> obtenerAlertas() async {
    final response = await client.get(Uri.parse('$baseUrl/alertas'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => AlertModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener alertas');
    }
  }
}
