import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alert_world/features/auth/data/models/alert_model.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertEntity>> obtenerAlertas();
  Future<Map<String, dynamic>> toggleLike(int alertId, String token, String userId);
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AlertRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<AlertEntity>> obtenerAlertas() async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/alertas'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final models = jsonData.map((e) => AlertModel.fromJson(e)).toList();
      return models.map((m) => m.toEntity()).toList();
    } else {
      throw Exception('Error al obtener alertas: ${response.statusCode}');
    }
  }
  @override
  Future<Map<String, dynamic>> toggleLike(int alertId, String token, String userId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/alertas/$alertId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al dar like: ${response.statusCode} ${response.body}');
    }
  }
}
