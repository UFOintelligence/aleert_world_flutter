import 'package:equatable/equatable.dart';
import '../../features/auth/data/models/user_model.dart';
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;

  const AuthSuccess(this.user);

  @override
List<Object?> get props => [
  user.id,
  user.name,
  user.email,
  user.token,
  user.rol,
  user.avatarUrl,
];

}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
