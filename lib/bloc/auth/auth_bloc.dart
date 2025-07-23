import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:alert_world/features/auth/data/models/user_model.dart';
import 'package:alert_world/features/auth/domain/usecases/login_user.dart';
import 'package:alert_world/features/auth/domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:alert_world/core/utils/auth_storage.dart';

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
          print("🧑 Usuario recibido: ${userModel.toJson()}");

          print("Login exitoso");
           print('User model: ${userModel.toJson()}');
          emit(AuthSuccess(userModel));
          
          AuthStorage.setToken(userModel.token); //guardo el token 

          
          
        },
      );
    });

    on<RegisterRequested>((event, emit) async {
      print("Intentando registrar...");
      emit(AuthLoading());
      final result = await registerUser.call(event.name, event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (success) => emit(AuthSuccess(success)),
      );
    });

    // 🚪 LOGOUT
    on<LogoutRequested>((event, emit) async {
      AuthStorage.clear();
      emit(const AuthInitial());
    });

    // 🔁 ACTUALIZAR USUARIO
    on<UpdateUserRequested>((event, emit) async {
      emit(const AuthLoading());
      print("🛠️ Actualizando usuario ID ${event.userId}");

      try {
        final uri = Uri.parse('http://10.0.2.2:8000/api/auth/users/${event.userId}');
        final request = http.MultipartRequest('POST', uri)
          ..headers['Accept'] = 'application/json'
          ..fields['_method'] = 'PUT'
          ..fields['name'] = event.name
          ..fields['email'] = event.email;

        if (event.password != null && event.password!.isNotEmpty) {
          request.fields['password'] = event.password!;
        }

        if (event.avatarUrl != null && event.avatarUrl!.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath('avatar', event.avatarUrl!));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print("📦 Body recibido: $responseBody");
        print("📶 Código de estado: ${response.statusCode}");

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        if (response.statusCode == 200 || response.statusCode == 201) {
          String token = '';
          if (state is AuthSuccess) {
            token = (state as AuthSuccess).user.token;
          }

          final updatedUser = UserModel.fromJson(jsonResponse['usuario'], token: token);
           AuthStorage.setToken(updatedUser.token);
          emit(AuthSuccess(updatedUser));
        } else {
          emit(AuthFailure('Error al actualizar usuario: ${jsonResponse['message'] ?? 'Desconocido'}'));
        }
      } catch (e) {
        emit(AuthFailure('Excepción al actualizar usuario: ${e.toString()}'));
      }
    });
  }
}
