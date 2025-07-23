import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String token;
  final String rol;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.rol,
    required this.avatarUrl,
  });

  /// ✅ Construcción desde respuesta JSON tipo `{ "user": {…}, "token": "…" }`
  factory UserModel.fromResponse(Map<String, dynamic> json) {
    final user = json['user'];
    if (user == null || user['id'] == null || user['id'] == 0) {
      throw Exception("⚠️ JSON inválido: falta 'user' o 'id'");
    }

    String? avatar;
    if (user.containsKey('avatar_url') && user['avatar_url'] != null) {
      avatar = user['avatar_url'] as String?;
    } else if (user.containsKey('image') && user['image'] != null) {
      final imageObj = user['image'];
      if (imageObj is Map<String, dynamic> && imageObj.containsKey('url')) {
        avatar = imageObj['url'] as String?;
      }
    }

    return UserModel(
      id: user['id'],
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      token: json['token'] ?? '',
      rol: user['rol'] ?? 'usuario',
      avatarUrl: avatar,
    );
  }

  /// ✅ Construcción desde JSON plano (sin anidar)
  factory UserModel.fromJson(Map<String, dynamic> json, {String token = ''}) {
    if (json['id'] == null || json['id'] == 0) {
      throw Exception("⚠️ ID de usuario inválido en el JSON: $json");
    }

    String? avatar;
    if (json.containsKey('avatar_url') && json['avatar_url'] != null) {
      avatar = json['avatar_url'] as String?;
    } else if (json.containsKey('image') && json['image'] != null) {
      final imageObj = json['image'];
      if (imageObj is Map<String, dynamic> && imageObj.containsKey('url')) {
        avatar = imageObj['url'] as String?;
      }
    }

    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: token,
      rol: json['rol'] ?? 'usuario',
      avatarUrl: avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'rol': rol,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? token,
    String? rol,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      rol: rol ?? this.rol,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, token, rol, avatarUrl];
}
