import 'package:alert_world/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alert_world/bloc/auth/auth_bloc.dart';
import 'package:alert_world/bloc/auth/auth_event.dart';
import 'package:alert_world/ui/page/login_page.dart';
import 'package:alert_world/ui/page/alert_map_page.dart';
import 'package:alert_world/ui/page/alert_list_page.dart';
import '../widgets/panic_button_widget.dart';
import 'package:alert_world/bloc/alerts/alert_bloc.dart';
import 'package:alert_world/bloc/alerts/alert_state.dart';
import 'package:alert_world/bloc/alerts/alert_event.dart';
import 'package:alert_world/features/alerts/domain/usecases/get_alertas.dart';
class HomePage extends StatelessWidget {
   final UserModel user;
   const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Alert World"),
        backgroundColor: Colors.deepPurple.shade600,
        elevation: 4,
        centerTitle: true,
      ),
      body: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AlertLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.alertas.length,
              itemBuilder: (context, index) {
                final alerta = state.alertas[index];
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (alerta.imagenUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            alerta.imagenUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerta.titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alerta.descripcion,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.place, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  alerta.ubicacion ?? "Ubicación desconocida",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // lógica para comentar
                                  },
                                  icon: const Icon(Icons.comment, size: 20, color: Colors.deepPurple),
                                ),
                                Text(
                                  '${alerta.comentarios?.length ?? 0}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is AlertError) {
            return Center(child: Text("Error: ${state.mensaje}"));
          } else {
            return const Center(child: Text("No hay alertas disponibles."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => Navigator.pushNamed(context, '/crear-alerta'),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: "Alertas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Mapa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}