import 'package:flutter/material.dart';

class AlertList extends StatelessWidget {
  const AlertList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text('Alerta #$index'),
            subtitle: const Text('Ubicación: Ciudad de Panamá'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navegar a detalle de la alerta
            },
          ),
        );
      },
    );
  }
}
