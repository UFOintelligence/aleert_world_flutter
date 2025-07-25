import 'dart:io';
import 'package:alert_world/ui/page/map_selector_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:alert_world/bloc/alerts/alert_bloc.dart';
import 'package:alert_world/bloc/alerts/alert_event.dart';
import 'package:alert_world/bloc/alerts/alert_state.dart';
import 'package:alert_world/features/alerts/domain/entities/alert_entity.dart';

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
  final _scrollController = ScrollController();

  File? _mediaFile;
  String? _mediaType;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  Position? _position;
  bool _usarUbicacionActual = true;

  final List<String> _tiposAlerta = ['Robo', 'Incendio', 'Accidente', 'Violencia', 'Otro'];
  String _tipoSeleccionado = 'Robo';

  LatLng? _ubicacionManual;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _otroTipoController.dispose();
    _scrollController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    final pos = await Geolocator.getCurrentPosition();
    if (mounted) setState(() => _position = pos);
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
            if (!mounted) return;
            setState(() {});
            _videoController!.setLooping(true);
            _videoController!.play();
          });
      }
    }
  }

  void _submitAlert() {
    if (!_formKey.currentState!.validate()) return;

    double? lat;
    double? lon;

    if (_usarUbicacionActual) {
      if (_position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Esperando ubicación GPS...")),
        );
        return;
      }
      lat = _position!.latitude;
      lon = _position!.longitude;
    } else {
      if (_ubicacionManual == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe seleccionar una ubicación en el mapa")),
        );
        return;
      }
      lat = _ubicacionManual!.latitude;
      lon = _ubicacionManual!.longitude;
    }

    final tipoAlerta = _tipoSeleccionado == 'Otro'
        ? _otroTipoController.text
        : _tipoSeleccionado.toLowerCase();

    final ubicacionStr = "Lat: $lat, Lon: $lon";

    final alert = AlertEntity(
      id: 0,
      usuarioId: widget.userId,
      titulo: tipoAlerta,
      descripcion: _descripcionController.text,
      ubicacion: ubicacionStr,
      mediaUrl: null,
      comentarios: null,
      usuarioNombre: widget.userName,
      usuarioAvatarUrl: null,
      fecha: DateTime.now(),
      likes: 0,
      likedByUser: false,
      tipoAlerta: tipoAlerta,
      latitud: lat,
      longitud: lon,
      archivoPath: _mediaFile?.path,
    );

    context.read<AlertBloc>().add(SubmitAlertEvent(alert));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🚨 Crear alerta")),
      body: SafeArea(
        child: BlocConsumer<AlertBloc, AlertState>(
          listener: (context, state) {
            if (state is AlertSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Alerta creada exitosamente")),
              );
              Navigator.pop(context);
            } else if (state is AlertError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ ${state.message}")),
              );
            }
          },
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state is AlertSubmitting,
              child: Opacity(
                opacity: state is AlertSubmitting ? 0.6 : 1,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📄 Información de la alerta",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Tipo de alerta",
                            border: OutlineInputBorder(),
                          ),
                          value: _tipoSeleccionado,
                          items: _tiposAlerta
                              .map((tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _tipoSeleccionado = value);
                            }
                          },
                        ),

                        if (_tipoSeleccionado == 'Otro')
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextFormField(
                              controller: _otroTipoController,
                              decoration: const InputDecoration(
                                labelText: 'Especifique el tipo',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor especifique el tipo de alerta';
                                }
                                return null;
                              },
                            ),
                          ),

                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una descripción';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: _usarUbicacionActual,
                          onChanged: (val) => setState(() {
                            _usarUbicacionActual = val;
                            if (val) _ubicacionManual = null;
                          }),
                          title: const Text("📍 Usar ubicación actual"),
                        ),

                        if (!_usarUbicacionActual)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.map),
                              label: Text(_ubicacionManual != null
                                  ? "Ubicación seleccionada"
                                  : "Seleccionar ubicación en el mapa"),
                              onPressed: () async {
                                final selected = await Navigator.push<LatLng>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MapSelectorPage()),
                                );
                                if (selected != null) {
                                  setState(() => _ubicacionManual = selected);
                                }
                              },
                            ),
                          ),

                        const SizedBox(height: 12),
                        Text(
                          'Adjuntar media (imagen o video)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        if (_mediaFile != null)
                          _mediaType == 'image'
                              ? Image.file(_mediaFile!, height: 200, fit: BoxFit.cover)
                              : (_videoController != null && _videoController!.value.isInitialized)
                                  ? AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    )
                                  : Container(),

                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.photo),
                              label: const Text('Foto'),
                              onPressed: () => _pickMedia(isVideo: false, source: ImageSource.gallery),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.videocam),
                              label: const Text('Video'),
                              onPressed: () => _pickMedia(isVideo: true, source: ImageSource.gallery),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Cámara'),
                              onPressed: () => _pickMedia(isVideo: false, source: ImageSource.camera),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.videocam_outlined),
                              label: const Text('Grabar video'),
                              onPressed: () => _pickMedia(isVideo: true, source: ImageSource.camera),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        FilledButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Enviar alerta"),
                          onPressed: _submitAlert,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
