import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:alert_world/features/auth/data/models/alert_model.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';
import 'alert_remote_data_source.dart';

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

  @override
  Future<void> createAlertRemote(Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/auth/alertas");
    final request = http.MultipartRequest('POST', uri);
     final token = data['token']; // debes incluir el token en tu mapa 'data'
 if(token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  request.headers['Accept'] = 'application/json';

    data.forEach((key, value) {
      if (value != null && key != 'archivoPath') {
        request.fields[key] = value.toString();
      }
    });

    if (data['archivoPath'] != null) {
      final file = File(data['archivoPath']);
      final mimeType = lookupMimeType(file.path)?.split('/') ?? ['application', 'octet-stream'];

      request.files.add(await http.MultipartFile.fromPath(
        'archivo',
        file.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 201) {
      final respStr = await streamedResponse.stream.bytesToString();
      
      throw Exception("Error al crear alerta: $respStr");
      
    }
  }
}
