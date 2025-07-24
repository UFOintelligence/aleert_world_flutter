import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import 'package:alert_world/features/auth/data/models/user_model.dart';
import 'package:alert_world/bloc/alerts/alert_bloc.dart';
import 'package:alert_world/bloc/alerts/alert_state.dart';
import 'package:alert_world/bloc/alerts/alert_event.dart';
import 'package:alert_world/ui/widgets/video_widget.dart';
import 'package:alert_world/core/utils/auth_storage.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  final String token;
  const HomePage({Key? key, required this.user, required this.token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    // Carga inicial de alertas
    context.read<AlertBloc>().add(LoadAlerts());
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "";
  }

  String fixLocalhost(String? url) =>
      url?.replaceFirst('localhost', '10.0.2.2') ?? '';

  Widget _buildMedia(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade300,
        child:
            const Center(child: Icon(Icons.image_not_supported, size: 60)),
      );
    }
    final lower = mediaUrl.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif')) {
      return Image.network(mediaUrl, fit: BoxFit.cover, height: 200);
    } else if (lower.endsWith('.mp4')) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterVideoWidget(videoUrl: mediaUrl),
      );
    }
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullAvatarUrl = widget.user.avatarUrl
        ?.replaceFirst('localhost', '10.0.2.2');
    final hasAvatar = (fullAvatarUrl ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
                radius: 15, backgroundImage: AssetImage('assets/logo.jpeg')),
            const SizedBox(width: 8),
            const Text('Alert World',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
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
                  arguments: {
                    'userName': widget.user.name,
                    'userId': widget.user.id
                  },
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
          }
          if (state is AlertLoaded) {
            if (state.alerts.isEmpty) {
              return const Center(child: Text("No hay alerts disponibles."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.alerts.length,
              itemBuilder: (context, index) {
                final alerta = state.alerts[index];
                final avatarUrl = fixLocalhost(alerta.usuarioAvatarUrl);

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado con avatar y nombre
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              backgroundColor: avatarUrl.isEmpty
                                  ? Colors.blueAccent
                                  : null,
                              child: avatarUrl.isEmpty
                                  ? Text(
                                      _getInitials(
                                          alerta.usuarioNombre ?? ""),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(alerta.usuarioNombre ?? "Anónimo",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Media (imagen/video)
                      // Imagen o video con detección automática
if (alerta.mediaUrl != null)
  SizedBox(
    width: double.infinity,
    height: 200,
    child: _buildMedia(fixLocalhost(alerta.mediaUrl)),
  ),

                      // Contenido
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alerta.titulo ?? 'Sin título',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(_formatoRelativo(alerta.fecha),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(alerta.descripcion ?? '',
                                style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 10),

                            // Fila de acciones: Like, Compartir, Comentarios
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        alerta.likedByUser
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: alerta.likedByUser
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        // Lanza el evento BLoC
                                        context
                                            .read<AlertBloc>()
                                            .add(ToggleLikeEvent(
                                                alertId: alerta.id, token: widget.token, userId: user.id.toString()));
                                      },
                                    ),
                                    Text('${alerta.likes}',
                                        style:
                                            const TextStyle(color: Colors.grey)),
                                    const SizedBox(width: 8),
                                    
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.comment,
                                          size: 20, color: Colors.grey),
                                      onPressed: () {
                                        // Lógica de comentarios
                                      },
                                    ),
                                    Text(
                                        '${alerta.comentarios?.length ?? 0}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                            IconButton(
                                      icon:
                                          const Icon(Icons.share, size: 20),
                                      onPressed: () {
                                        Share.share(
                                          '🚨 Alerta: ${alerta.titulo}\n\n${alerta.descripcion}',
                                          subject:
                                              'Nueva alerta en Alert World',
                                        );
                                      },
                                    ),
                                  ],
                                )
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
          }
          if (state is AlertFailure) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("No hay alerts disponibles."));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            final profileAlerts = <Map<String, dynamic>>[];
            final state = context.read<AlertBloc>().state;
            if (state is AlertLoaded) {
              for (var a in state.alerts) {
                if (a.usuarioId == user.id) {
                  profileAlerts.add({
                    'mediaUrl': a.mediaUrl ?? '',
                    'titulo': a.titulo ?? '',
                    'esVideo': (a.mediaUrl ?? '').toLowerCase().endsWith('.mp4'),
                  });
                }
              }
            }
            Navigator.pushNamed(context, '/profile', arguments: {
              'user': user,
              'alerts': profileAlerts,
            });
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: ""),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage:
                  hasAvatar ? NetworkImage(fullAvatarUrl!) : null,
              backgroundColor:
                  hasAvatar ? Colors.transparent : Colors.blueAccent,
              child: !hasAvatar
                  ? Text(_getInitials(widget.user.name),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))
                  : null,
            ),
            label: "",
          ),
        ],
      ),
    );
  }

  String _formatoRelativo(DateTime? fecha) {
    if (fecha == null) return 'Fecha desconocida';
    final diff = DateTime.now().difference(fecha);
    if (diff.inSeconds < 60) return 'hace unos segundos';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'hace ${(diff.inDays / 7).floor()} sem.';
    if (diff.inDays < 365) return 'hace ${(diff.inDays / 30).floor()} mes.';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
