import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
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
    print('🔄 Enviando solicitud a: $url');
    print('📨 Cuerpo: ${jsonEncode({'email': email, 'password': password})}');

    final response = await client.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('✅ Código de respuesta: ${response.statusCode}');
    print('📦 Respuesta: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error en login: ${response.body}');
    }
  }

@override
Future<Map<String, dynamic>> register(String name, String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/register');
  print('🔄 Enviando solicitud a: $url');
  print('📨 Cuerpo: ${jsonEncode({
    'name': name,
    'email': email,
    'password': password,
    'password_confirmation': password,
  })}');

  final response = await client.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    }),
  );

  print('✅ Código de respuesta: ${response.statusCode}');
  print('📦 Respuesta: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error en registro: ${response.body}');
  }
}
}

