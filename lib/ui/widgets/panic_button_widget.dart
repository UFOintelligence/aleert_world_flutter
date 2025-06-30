import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- para HapticFeedback
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class PanicButton extends StatelessWidget {
  const PanicButton({super.key});

  Future<void> _handlePanic(BuildContext context) async {
    // ✅ Vibración nativa sin plugin
    HapticFeedback.heavyImpact();

    // ✅ Solicitar permisos
    await [
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.storage,
    ].request();

    // ✅ Sonido de alerta
    final player = AudioPlayer();
    await player.play(AssetSource('audio/alert.mp3'));

    // ✅ Obtener ubicación
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    debugPrint('Ubicación actual: ${position.latitude}, ${position.longitude}');

    // ✅ Grabar audio
    final recorder = FlutterSoundRecorder();
    await recorder.openRecorder();

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/panic_alert.aac';

    await recorder.startRecorder(
      toFile: path,
      codec: Codec.aacMP4,
    );

    // Graba 5 segundos
    await Future.delayed(const Duration(seconds: 5));
    await recorder.stopRecorder();
    await recorder.closeRecorder();

    debugPrint('Audio grabado en: $path');

    // ✅ Simular envío
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Alerta enviada!\nUbicación: ${position.latitude}, ${position.longitude}\nAudio: ${path.split('/').last}',
        ),
      ),
    );
  }

  void _showPanicAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('¡Alerta de Pánico!'),
          content: const Text('¿Deseas enviar una alerta de emergencia?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handlePanic(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.red,
      onPressed: () => _showPanicAlert(context),
      icon: const Icon(Icons.warning),
      label: const Text('¡Pánico!'),
    );
  }
}
