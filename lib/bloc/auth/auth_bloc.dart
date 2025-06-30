import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:alert_world/features/auth/domain/usecases/login_user.dart';
import 'package:alert_world/features/auth/domain/usecases/register_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthBloc({required this.loginUser, required this.registerUser}) : super(AuthInitial()) { 
    on<LoginRequested>((event, emit) async {
      print("Intentando iniciar sesión...");
      print("Email: ${event.email}, Password: ${event.password}");

      emit(AuthLoading());
      final result = await loginUser.call(event.email, event.password);
      result.fold(
        (failure) {
          print("Login fallido: ${failure.message}");
          emit(AuthFailure(failure.message));
        },
        (userModel) {
          print("Login exitoso");
          emit(AuthSuccess(userModel));  // Aquí paso el UserModel
        },
      );
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUser.call(event.name, event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (success) => emit(AuthSuccess(success)),  // Considera pasar UserModel si quieres loguear tras registro
      );
    });

    on<LogoutRequested>((event, emit) async {
      print("Cerrando sesión...");
      // Aquí podrías eliminar tokens, limpiar preferencias, etc.
      emit(AuthInitial());
    });
  }
}
