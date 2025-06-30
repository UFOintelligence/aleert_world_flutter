import 'package:flutter/material.dart';

class PanicPage extends StatelessWidget {
  const PanicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botón de Pánico')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Estás seguro que deseas activar el botón de pánico?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text('Activar alerta'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Alerta enviada!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
