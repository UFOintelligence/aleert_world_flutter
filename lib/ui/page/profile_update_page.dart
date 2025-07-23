import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alert_world/bloc/auth/auth_bloc.dart';
import 'package:alert_world/bloc/auth/auth_event.dart';
import 'package:alert_world/bloc/auth/auth_state.dart';
import 'package:alert_world/features/auth/data/models/user_model.dart';

class UserProfileUpdatePage extends StatefulWidget {
  final UserModel user;

  const UserProfileUpdatePage({super.key, required this.user});

  @override
  State<UserProfileUpdatePage> createState() => _UserProfileUpdatePageState();
}

class _UserProfileUpdatePageState extends State<UserProfileUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  File? _avatarFile;
  bool _hasUpdated = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _hasUpdated = false);

      context.read<AuthBloc>().add(UpdateUserRequested(
            userId: widget.user.id,
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
            avatarUrl: _avatarFile?.path,
          ));
    }
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de la galería'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;
    final fullAvatarUrl = widget.user.avatarUrl;
    final hasAvatar = _avatarFile != null || (fullAvatarUrl != null && fullAvatarUrl.isNotEmpty);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is! AuthLoading) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        if (state is AuthLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actualizando usuario...')),
          );
        } else if (state is AuthSuccess && !_hasUpdated) {
          final updatedUser = state.user ??
              widget.user.copyWith(
                name: _nameCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                avatarUrl: _avatarFile?.path ?? widget.user.avatarUrl,
              );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario actualizado correctamente')),
          );

          await Future.delayed(const Duration(milliseconds: 300));

          if (mounted) {
            Navigator.pop(context, updatedUser);
            setState(() => _hasUpdated = true);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Actualizar Usuario')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (fullAvatarUrl != null && fullAvatarUrl.isNotEmpty
                              ? NetworkImage(fullAvatarUrl)
                              : null) as ImageProvider<Object>?,
                      backgroundColor: hasAvatar ? Colors.transparent : Colors.blueAccent,
                      child: !hasAvatar
                          ? Text(
                              _getInitials(widget.user.name),
                              style: const TextStyle(fontSize: 20, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Repetir Contraseña'),
                  validator: (value) {
                    if (_passwordCtrl.text.isNotEmpty && value != _passwordCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
