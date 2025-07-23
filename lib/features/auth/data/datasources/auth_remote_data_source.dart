import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String name,
    required String email,
    String? password,
    String? avatarUrl,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await client.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      print('🔍 Login response: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en login: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await client.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en registro: ${response.body}');
    }
  }

  @override
Future<Map<String, dynamic>> updateUser({
  required int userId,
  required String name,
  required String email,
  String? password,
  String? avatarUrl,
}) async {
  final url = Uri.parse('$baseUrl/auth/users/$userId');
  final request = http.MultipartRequest('POST', url);

  request.headers.addAll({
    'Accept': 'application/json',
  });

  request.fields['_method'] = 'PUT'; // 👈 Emulación del método PUT
  request.fields['name'] = name;
  request.fields['email'] = email;

  if (password != null && password.isNotEmpty) {
    request.fields['password'] = password;
  }

  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    final avatarFile = await http.MultipartFile.fromPath('avatar', avatarUrl);
    request.files.add(avatarFile);
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  print("📦 Body recibido: ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error actualizando usuario: ${response.body}');
  }

}

}
