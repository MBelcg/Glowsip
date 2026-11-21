import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/admin_drawer.dart';
import '../widgets/user_drawer.dart';
import '../widgets/auth_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  Map<String, dynamic> _usuario = {};
  bool _cargando = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }
    _nombre.text = _usuario['nom_usr']?.toString() ?? '';
    _correo.text = _usuario['mail']?.toString() ?? '';
    _inicializado = true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _usuario['id_usr'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se recibió el identificador del usuario. Vuelve a iniciar sesión.',
          ),
        ),
      );
      return;
    }
    setState(() => _cargando = true);
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/usuarios/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nom_usr': _nombre.text.trim(),
              'mail': _correo.text.trim().toLowerCase(),
              'tip_usu': (_usuario['tip_usu'] as num?)?.toInt() ?? 1,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final dynamic data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
      if (response.statusCode != 200) {
        final detail = data is Map ? data['detail'] : null;
        throw Exception(
          detail?.toString() ?? 'Error HTTP ${response.statusCode}',
        );
      }
      if (data is Map<String, dynamic>)
        _usuario = Map<String, dynamic>.from(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarPassword() async {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    final confirmarController = TextEditingController();

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                ),
              ),
              TextField(
                controller: nuevaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
              ),
              TextField(
                controller: confirmarController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (actualController.text.isEmpty ||
                  nuevaController.text.length < 8 ||
                  nuevaController.text != confirmarController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Revisa las contraseñas. La nueva debe tener al menos 8 caracteres y coincidir con la confirmación.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, true);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    final passwordActual = actualController.text;
    final passwordNueva = nuevaController.text;

    actualController.dispose();
    nuevaController.dispose();
    confirmarController.dispose();

    if (guardar != true || !mounted) return;

    final id = _usuario['id_usr'];
    if (id == null) return;

    try {
      final respuesta = await http.put(
        Uri.parse('$baseUrl/usuarios/$id/password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password_actual': passwordActual,
          'password_nueva': passwordNueva,
        }),
      );

      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        final datos = jsonDecode(respuesta.body);
        throw Exception(datos['detail'] ?? 'No se pudo cambiar la contraseña');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE76B8B),
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        title: const Text('Mi perfil'),
        flexibleSpace: Center(
          child: Image.asset(
            'assets/images/icono-gsip.png',
            height: 45,
            fit: BoxFit.contain,
          ),
        ),
      ),
      drawer: (_usuario['tip_usu'] as num? ?? 2).toInt() == 1
          ? AdminDrawer(usuario: _usuario, rutaActual: '/profile')
          : UserDrawer(usuario: _usuario, rutaActual: '/profile'),
      body: AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: const Color(0xFFFFF9FB),
                elevation: 3,
                shadowColor: const Color(0xFFF4BFD0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF4BFD0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: Color(0xFFF4BFD0),
                          child: Icon(
                            Icons.person,
                            size: 42,
                            color: Color(0xFF68152F),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nombre,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().length < 2
                              ? 'Ingresa un nombre válido'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Ingresa un correo válido'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _cargando ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF246A73),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: const Icon(Icons.save),
                          label: Text(
                            _cargando ? 'Guardando...' : 'Guardar cambios',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _cambiarPassword,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF68152F),
                            side: const BorderSide(color: Color(0xFF68152F)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Cambiar contraseña'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
