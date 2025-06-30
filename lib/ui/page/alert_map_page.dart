// alert_map_page.dart
import 'package:flutter/material.dart';

class AlertMapPage extends StatelessWidget {
  const AlertMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Alertas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: const Center(
        child: Text(
          'Mapa con alertas recientes (placeholder)',
          textAlign: TextAlign.center,
        ),
      ),
    ),);
  }
}
