import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../models/comentario_model.dart';
import '../services/comentario_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  final Map<String, dynamic> usuario;

  const PostDetailPage({super.key, required this.post, required this.usuario});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService comentarioService = ComentarioService();
  final TextEditingController comentarioController = TextEditingController();
  late Future<List<ComentarioModel>> futuroComentarios;
  @override
  void initState() {
    super.initState();
    futuroComentarios = comentarioService.obtenerComentarios();
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  Future<void> guardarComentario() async {
    final texto = comentarioController.text.trim();
    final idUsuario = widget.usuario['id_usr'];

    if (texto.isEmpty || idUsuario == null) return;

    final nuevo = ComentarioModel(
      id: 0,
      comentario: texto,
      fecha: '',
      usuarioId: (idUsuario as num).toInt(),
      blogId: widget.post.id,
    );

    try {
      await comentarioService.agregarComentario(nuevo);

      if (!mounted) return;

      comentarioController.clear();

      setState(() {
        futuroComentarios = comentarioService.obtenerComentarios();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario publicado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo publicar: $e')));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de publicación')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.imagen.isNotEmpty)
              Image.network(
                widget.post.imagen.startsWith('http')
                    ? widget.post.imagen
                    : 'http://localhost/blog_web/uploads/${widget.post.imagen.split('/').last}',
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.tags.isNotEmpty) ...[
                    Text(
                      widget.post.tags,
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    widget.post.titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.post.descripcion.isNotEmpty
                        ? widget.post.descripcion
                        : 'Esta publicación no tiene descripción.',
                    style: const TextStyle(fontSize: 17, height: 1.6),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  FutureBuilder<List<ComentarioModel>>(
                    future: futuroComentarios,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'No se pudieron cargar los comentarios.',
                        );
                      }

                      final comentarios = (snapshot.data ?? [])
                          .where(
                            (comentario) => comentario.blogId == widget.post.id,
                          )
                          .toList();

                      if (comentarios.isEmpty) {
                        return const Text('Todavía no hay comentarios.');
                      }

                      return Column(
                        children: comentarios.map((comentario) {
                          return ListTile(
                            leading: const Icon(Icons.comment),
                            title: Text(comentario.comentario),
                            subtitle: Text(comentario.fecha),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Escribe un comentario',
                      hintText: '¿Qué opinas de esta publicación?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: guardarComentario,
                    icon: const Icon(Icons.send),
                    label: const Text('Publicar comentario'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
