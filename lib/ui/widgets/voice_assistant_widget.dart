import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantWidget extends StatefulWidget {
  final VoidCallback? onOpenCamera;
  final VoidCallback? onShowLastAlert;

  const VoiceAssistantWidget({
    super.key,
    this.onOpenCamera,
    this.onShowLastAlert,
  });

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _activated = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    if (!_isListening) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords.toLowerCase();

            if (!_activated) {
              if (_lastWords.contains('brito actívate') || _lastWords.contains('brito activate')) {
                _activated = true;
                _speak('Modo activado. Dime un comando');
              }
            } else {
              if (_lastWords.contains('mostrar última alerta')) {
                _speak('Mostrando la última alerta');
                widget.onShowLastAlert?.call();
                _activated = false;
              } else if (_lastWords.contains('abrir cámara')) {
                _speak('Abriendo cámara');
                widget.onOpenCamera?.call();
                _activated = false;
              } else if (result.finalResult) {
                _speak('No entendí el comando');
                _activated = false;
              }
            }
          });
        },
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _activated = false;
    });
  }

  void _speak(String text) async {
    await _tts.setLanguage("es-ES"); // Idioma español
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isListening ? _stopListening : _startListening,
          icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
          label: Text(_isListening ? 'Detener Asistente' : 'Activar Asistente Brito'),
        ),
        const SizedBox(height: 10),
        Text(
          _activated
              ? 'Modo activado... esperando comando'
              : 'Di "Brito, actívate" para comenzar',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
