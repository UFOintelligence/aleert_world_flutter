import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectorPage extends StatefulWidget {
  const MapSelectorPage({Key? key}) : super(key: key);

  @override
  State<MapSelectorPage> createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar ubicación")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(8.9833, -79.5167), // Panamá por defecto
          zoom: 14,
        ),
        onTap: (latLng) {
          setState(() {
            _selectedLatLng = latLng;
          });
        },
        markers: _selectedLatLng != null
            ? {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: _selectedLatLng!,
                )
              }
            : {},
      ),
      floatingActionButton: _selectedLatLng != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, _selectedLatLng); // ✅ Devolver LatLng
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirmar"),
            )
          : null,
    );
  }
}
