import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
         centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthSuccess || current is AuthFailure,
        listener: (context, state) {
          if (state is AuthFailure) {
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is AuthSuccess) {
               final user = state.user; 
           Navigator.pushNamed(
                context,
                '/home',
                arguments: {'user': user},
              );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              
              key: _formKey,
              child: ListView(
                children: [
                 Center(
  child: ClipOval(
    child: Image.asset(
      'assets/logo.jpeg',
      width: 120,
      height: 120,
      fit: BoxFit.cover, // Para que llene el círculo correctamente
    ),
  ),
),

          
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: 'Nombre completo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El correo es obligatorio';
                      }
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es obligatoria';
                      }
                      if (value.length < 8) {
                        return 'Debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassCtrl,
                    decoration: InputDecoration(labelText: 'Confirmar contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value != passCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              RegisterRequested(
                                name: nameCtrl.text,
                                email: emailCtrl.text,
                                password: passCtrl.text,
                              ),
                            );
                      }
                    },
                    child: Text('Registrarse'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
