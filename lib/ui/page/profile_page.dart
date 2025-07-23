import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alert_world/bloc/auth/auth_bloc.dart';
import 'package:alert_world/bloc/auth/auth_event.dart';
import 'package:alert_world/features/auth/data/models/user_model.dart';
import 'package:alert_world/ui/widgets/video_thumbnail.dart';
import 'package:alert_world/ui/page/profile_update_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  final UserModel user;
  final List<Map<String, dynamic>> alerts;

  const UserProfilePage({
    Key? key,
    required this.user,
    required this.alerts,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late UserModel currentUser;
  late List<Map<String, dynamic>> alertsDelUsuario;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    alertsDelUsuario = widget.alerts;
    cargarUsuario();
  }

  // Método para obtener el usuario desde backend
  Future<UserModel> getUserById(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/auth/users/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Error al cargar usuario');
    }
  }

  void cargarUsuario() async {
    try {
      final user = await getUserById(currentUser.id);
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print('Error cargando usuario: $e');
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  Future<void> _navigateToEditProfile() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileUpdatePage(user: currentUser),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        currentUser = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

  void _handleMenuOption(String value) {
    switch (value) {
      case 'edit':
        _navigateToEditProfile();
        break;
      case 'logout':
        context.read<AuthBloc>().add(LogoutRequested());
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(DeleteAccountRequested(userId: currentUser.id));
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullAvatarUrl = currentUser.avatarUrl != null
        ? currentUser.avatarUrl!.replaceFirst('localhost', '10.0.2.2')
        : null;

    final hasAvatar = fullAvatarUrl != null && fullAvatarUrl.isNotEmpty;
    print('FULL AVATAR URL: $fullAvatarUrl'); // Debug consola

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuOption,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar perfil')),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar cuenta', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: hasAvatar ? NetworkImage(fullAvatarUrl!) : null,
                  backgroundColor: hasAvatar ? Colors.transparent : Colors.blueAccent,
                  child: !hasAvatar
                      ? Text(
                          _getInitials(currentUser.name),
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Mis Alertas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: alertsDelUsuario.isEmpty
                  ? const Center(child: Text('No tienes alertas publicadas.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: alertsDelUsuario.length,
                      itemBuilder: (context, index) {
                        final alert = alertsDelUsuario[index];
                        final isVideo = alert['esVideo'] ?? false;

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (alert['mediaUrl'] != null && alert['mediaUrl'] != '')
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: isVideo
                                        ? VideoThumbnail(url: alert['mediaUrl'])
                                        : Image.network(
                                            alert['mediaUrl'],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  alert['titulo'] ?? 'Sin título',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
