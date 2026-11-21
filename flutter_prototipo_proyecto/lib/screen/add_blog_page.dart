import 'package:flutter/material.dart';

import '../widgets/admin_drawer.dart';

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/auth_background.dart';

class AddBlogPage extends StatefulWidget {
  final PostModel? post;

  const AddBlogPage({super.key, this.post});
  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _imagen = TextEditingController();
  final _tags = TextEditingController();

  bool _guardando = false;
  Map<String, dynamic> _usuario = {};

  final picker = ImagePicker();
  XFile? foto;
  Uint8List? imagenBytes;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _titulo.text = widget.post!.titulo;
      _descripcion.text = widget.post!.descripcion;
      _tags.text = widget.post!.tags;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _imagen.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> tomarFoto() async {
    final imagen = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (imagen != null) {
      final bytes = await imagen.readAsBytes();

      if (!mounted) return;

      setState(() {
        foto = imagen;
        imagenBytes = bytes;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.post != null) {
      setState(() => _guardando = true);

      try {
        await PostService().actualizarPost(
          id: widget.post!.id,
          titulo: _titulo.text.trim(),
          descripcion: _descripcion.text.trim(),
          tags: _tags.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación actualizada correctamente'),
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
      } finally {
        if (mounted) {
          setState(() => _guardando = false);
        }
      }

      return;
    }

    setState(() => _guardando = true);

    try {
      final uri = Uri.parse('http://127.0.0.1:8000/blog');

      final request = http.MultipartRequest('POST', uri)
        ..fields['titulo'] = _titulo.text.trim()
        ..fields['descripcion'] = _descripcion.text.trim()
        ..fields['tags'] = _tags.text.trim()
        ..fields['id_autor'] = _usuario['id_usr'].toString();
      if (foto != null && imagenBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            imagenBytes!,
            filename: foto!.name,
          ),
        );
      }

      final respuesta = await request.send();

      if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
        throw Exception('Error al guardar la publicación');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación agregada correctamente')),
      );

      _titulo.clear();
      _descripcion.clear();
      _imagen.clear();
      _tags.clear();

      setState(() {
        foto = null;
        imagenBytes = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario['nom_usr']?.toString() ?? 'Administrador';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE76B8B),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/icono-gsip.png',
          height: 45,
          fit: BoxFit.contain,
        ),
      ),
      drawer: AdminDrawer(
        usuario: _usuario,
        rutaActual: widget.post == null ? '/add-blog' : '',
      ),
      body: AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.post == null
                              ? 'Nueva publicación'
                              : 'Editar publicación',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF68152F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Administrador: $nombre'),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _titulo,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingresa el título'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _descripcion,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Ingresa la descripción'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _imagen,
                          decoration: const InputDecoration(
                            labelText: 'URL de imagen (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        ElevatedButton.icon(
                          onPressed: tomarFoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF246A73),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Subir imagen'),
                        ),

                        const SizedBox(height: 14),

                        if (imagenBytes != null)
                          Image.memory(
                            imagenBytes!,
                            height: 180,
                            fit: BoxFit.cover,
                          ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _tags,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            hintText: 'ojos, labios, rostro, cejas',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF246A73),
                            foregroundColor: Colors.white,
                          ),
                          icon: _guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _guardando
                                ? 'Guardando...'
                                : widget.post == null
                                ? 'Guardar publicación'
                                : 'Guardar cambios',
                          ),
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
