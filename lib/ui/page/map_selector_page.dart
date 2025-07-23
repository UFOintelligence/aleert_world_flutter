import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSelectorPage extends StatefulWidget {
  const MapSelectorPage({Key? key}) : super(key: key);

  @override
  State<MapSelectorPage> createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  LatLng? _selectedLatLng;
  GoogleMapController? _mapController;
  bool _loading = true;

  static const LatLng fallbackLatLng = LatLng(8.9833, -79.5167); // Panamá
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: fallbackLatLng,
    zoom: 3,
  );

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // No location permission
        setState(() => _loading = false);
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _initialCameraPosition = CameraPosition(target: userLatLng, zoom: 16);
        _selectedLatLng = userLatLng;
        _loading = false;
      });
    } catch (e) {
      // Error o permisos negados
      setState(() => _loading = false);
    }
  }

  void _moveToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 16));

      setState(() {
        _selectedLatLng = userLatLng;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ubicación actual')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar ubicación")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (latLng) {
                    setState(() => _selectedLatLng = latLng);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _selectedLatLng != null
                      ? {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: _selectedLatLng!,
                          )
                        }
                      : {},
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: "location_button",
                    onPressed: _moveToCurrentLocation,
                    child: const Icon(Icons.my_location),
                    tooltip: "Usar mi ubicación actual",
                  ),
                ),
              ],
            ),
      floatingActionButton: _selectedLatLng != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context, _selectedLatLng),
              icon: const Icon(Icons.check),
              label: const Text("Confirmar"),
            )
          : null,
    );
  }
}
