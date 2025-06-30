import 'package:flutter/material.dart';

class ReportIncidentPage extends StatefulWidget {
  final String userName;

  const ReportIncidentPage({Key? key, required this.userName}) : super(key: key);

  @override
  _ReportIncidentPageState createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedIncidentType;
  final List<String> _incidentTypes = ['Robo', 'Accidente', 'Incendio', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportar incidente - Usuario: ${widget.userName}'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Tipo de incidente
            Text('Tipo de incidente'),
            DropdownButtonFormField<String>(
              value: _selectedIncidentType,
              hint: Text('Selecciona un tipo'),
              onChanged: (value) {
                setState(() {
                  _selectedIncidentType = value;
                });
              },
              items: _incidentTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Descripción
            Text('Descripción'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe una descripción...',
              ),
            ),
            SizedBox(height: 16),

            // Añadir foto
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidad pendiente: añadir foto')),
                );
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 32, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Añadir foto'),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Ubicación
            Text('Ubicación'),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ubicación',
              ),
            ),
            SizedBox(height: 24),

            // Botón enviar
            ElevatedButton(
              onPressed: () {
                final tipo = _selectedIncidentType;
                final descripcion = _descriptionController.text;
                final ubicacion = _locationController.text;

                if (tipo == null || descripcion.isEmpty || ubicacion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Incidente enviado')),
                );
              },
              child: Text('Enviar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
