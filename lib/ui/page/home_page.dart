import 'package:alert_world/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alert_world/bloc/alerts/alert_bloc.dart';
import 'package:alert_world/bloc/alerts/alert_state.dart';
import 'package:alert_world/bloc/alerts/alert_event.dart';
import 'package:alert_world/ui/widgets/video_widget.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  String _formatoRelativo(DateTime? fecha) {
    if (fecha == null) return 'Fecha desconocida';

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inSeconds < 60) return 'hace unos segundos';
    if (diferencia.inMinutes < 60) return 'hace ${diferencia.inMinutes} ${diferencia.inMinutes == 1 ? 'minuto' : 'minutos'}';
    if (diferencia.inHours < 24) return 'hace ${diferencia.inHours} ${diferencia.inHours == 1 ? 'hora' : 'horas'}';
    if (diferencia.inDays == 1) return 'ayer';
    if (diferencia.inDays < 7) return 'hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    }
    if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    }

    final anios = (diferencia.inDays / 365).floor();
    if (anios >= 1 && anios < 5) {
      return 'hace $anios ${anios == 1 ? 'año' : 'años'}';
    }

    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  void initState() {
    super.initState();
    context.read<AlertBloc>().add(LoadAlerts());
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile', arguments: widget.user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/logo.jpeg')),
            const SizedBox(width: 8),
            const Text('Alert World', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/report',
                  arguments: {'userName': user.name, 'userId': user.id},
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AlertLoaded) {
            if (state.alertas.isEmpty) {
              return const Center(child: Text("No hay alertas disponibles."));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: state.alertas.length,
              itemBuilder: (context, index) {
                final alerta = state.alertas[index];
                final hasAvatar = alerta.usuarioAvatarUrl != null && alerta.usuarioAvatarUrl!.isNotEmpty;
                final hasName = alerta.usuarioNombre != null && alerta.usuarioNombre!.isNotEmpty;

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: hasAvatar ? NetworkImage(alerta.usuarioAvatarUrl!) : null,
                              child: (!hasAvatar && hasName)
                                  ? Text(
                                      alerta.usuarioNombre![0].toUpperCase(),
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              alerta.usuarioNombre ?? "Anónimo",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (alerta.imagenUrl != null && alerta.imagenUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                          child: Image.network(
                            alerta.imagenUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        )
                      else if (alerta.videoUrl != null && alerta.videoUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: VideoWidget(videoUrl: alerta.videoUrl!),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                          ),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerta.titulo,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatoRelativo(alerta.fecha),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                                  onPressed: () {},
                                  icon: const Icon(Icons.comment, size: 20, color: Colors.grey),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            _showProfileOptions(context); // ahora está conectada aquí
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: ""),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
              child: !hasAvatar
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
