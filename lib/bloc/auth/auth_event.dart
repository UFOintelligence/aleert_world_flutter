// auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// 🔐 Iniciar sesión
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// 📝 Registro de usuario
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// 🔓 Cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// 🔄 Actualización de perfil de usuario
class UpdateUserRequested extends AuthEvent {
  final int userId; // <-- añadido para usar en la URL
  final String name;
  final String email;
  final String? password;
  final String? avatarUrl;

  const UpdateUserRequested({
    required this.userId,
    required this.name,
    required this.email,
    this.password,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, name, email, password, avatarUrl];
}
class DeleteAccountRequested extends AuthEvent {
  final int userId;
  DeleteAccountRequested({required this.userId});
}
