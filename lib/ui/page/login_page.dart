import 'package:alert_world/ui/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print("📦 Listener recibido: ${state is AuthSuccess ? (state as AuthSuccess).user.rol : 'otro'}");

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is AuthSuccess) {
            final user = state.user;

            if (user.rol != 'usuario') {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Acceso restringido"),
                  content: const Text("Por favor inicie sesión desde la web."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else {
               WidgetsBinding.instance.addPostFrameCallback((_) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => HomePage(user: user)),
  );
});
              // Mostrar mensaje y redirigir fuera del listener
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login exitoso. Bienvenido ${user.name}'),
                  backgroundColor: Colors.green,
                ),
              );

              // Redirección segura fuera del ciclo del listener
            
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpeg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El email es obligatorio';
                          }
                          if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                            return 'Formato de email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            email: emailCtrl.text.trim(),
                                            password: passCtrl.text.trim(),
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AuthBloc>(),
                                child: RegisterPage(),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "¿No tienes cuenta? Regístrate aquí",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
