import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({super.key, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: true, // Muestra botón "atrás"
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenido, ${widget.userName}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu perfil aún está en construcción.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
