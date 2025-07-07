import '../../features/auth/data/models/user_model.dart';
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
   final UserModel user;

  AuthSuccess(this.user);
}
// auth_state.dart
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

