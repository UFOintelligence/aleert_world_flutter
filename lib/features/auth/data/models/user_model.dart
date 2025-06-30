class UserModel {
  final int id;
  final String name;
  final String email;
  final String token;
  final String rol;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.rol,
  });
factory UserModel.fromJson(Map<String, dynamic> json) {
  final user = json['user'];
  return UserModel(
    id: user['id'],
    name: user['name'],
    email: user['email'],
    token: json['token'],
    rol: user['rol'] ?? 'usuario',
  );
}

}

