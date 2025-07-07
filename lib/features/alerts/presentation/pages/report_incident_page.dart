import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportIncidentPage extends StatefulWidget {
  final String userName;
  final int userId;

  const ReportIncidentPage({
    Key? key,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  _ReportIncidentPageState createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _otroTipoController = TextEditingController();

  File? _mediaFile;
  String? _mediaType;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  Position? _position;

  final List<String> _tiposAlerta = ['Robo', 'Incendio', 'Accidente', 'Violencia', 'Otro'];
  String _tipoSeleccionado = 'Robo';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _position = pos;
    });
  }

  Future<void> _pickMedia({required bool isVideo, required ImageSource source}) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = isVideo ? 'video' : 'image';
      });

      if (isVideo) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_mediaFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(true);
            _videoController!.play();
          });
      }
    }
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Esperando ubicación GPS...")),
      );
      return;
    }

    final uri = Uri.parse("http://10.0.2.2:8000/api/auth/alertas");
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = widget.userId.toString();
    request.fields['titulo'] = _tipoSeleccionado;
    request.fields['tipo_alerta'] =
        _tipoSeleccionado == 'Otro' ? _otroTipoController.text : _tipoSeleccionado.toLowerCase();
    request.fields['descripcion'] = _descripcionController.text;
    request.fields['latitud'] = _position!.latitude.toString();
    request.fields['longitud'] = _position!.longitude.toString();

    if (_mediaFile != null && _mediaType != null) {
      final mimeTypeData = lookupMimeType(_mediaFile!.path)?.split('/') ?? ['application', 'octet-stream'];
      request.files.add(await http.MultipartFile.fromPath(
        'archivo',
        _mediaFile!.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Alerta creada exitosamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al crear la alerta: $responseBody")),
      );
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _otroTipoController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🚨 Reportar alerta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("📄 Información de la alerta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: "Tipo de alerta",
                  prefixIcon: Icon(Icons.warning),
                  border: OutlineInputBorder(),
                ),
                items: _tiposAlerta.map((tipo) {
                  return DropdownMenuItem<String>(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoSeleccionado = value);
                  }
                },
              ),

              const SizedBox(height: 12),

              if (_tipoSeleccionado == 'Otro')
                TextFormField(
                  controller: _otroTipoController,
                  decoration: const InputDecoration(
                    labelText: "Especificar otro tipo",
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_tipoSeleccionado == 'Otro' && (value == null || value.isEmpty)) {
                      return "Especifica el tipo de alerta";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
              ),

              const SizedBox(height: 16),
              const Text("📍 Ubicación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (_position != null) ...[
                TextFormField(
                  initialValue: _position!.latitude.toString(),
                  decoration: const InputDecoration(
                    labelText: "Latitud",
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _position!.longitude.toString(),
                  decoration: const InputDecoration(
                    labelText: "Longitud",
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/map_selector');

                    if (result != null && result is LatLng) {
                      setState(() {
                        _position = Position(
                          latitude: result.latitude,
                          longitude: result.longitude,
                          timestamp: DateTime.now(),
                          accuracy: 1.0,
                          altitude: 0.0,
                          heading: 0.0,
                          speed: 0.0,
                          speedAccuracy: 1.0,
                          altitudeAccuracy: 1.0,
                          headingAccuracy: 1.0,
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_location_alt),
                  label: const Text("Elegir otra ubicación"),
                ),
              ] else
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 24),
              const Text("🎥 Adjuntar multimedia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text("Galería"),
                        onPressed: () => _pickMedia(isVideo: false, source: ImageSource.gallery),
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Cámara"),
                        onPressed: () => _pickMedia(isVideo: false, source: ImageSource.camera),
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text("Video galería"),
                        onPressed: () => _pickMedia(isVideo: true, source: ImageSource.gallery),
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.videocam),
                        label: const Text("Video cámara"),
                        onPressed: () => _pickMedia(isVideo: true, source: ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              ),

              if (_mediaFile != null && _mediaType == 'image')
                Image.file(_mediaFile!, height: 200, fit: BoxFit.cover),

              if (_mediaFile != null &&
                  _mediaType == 'video' &&
                  _videoController != null &&
                  _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),

              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Enviar alerta"),
                onPressed: _submitAlert,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
