import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../models/comentario_model.dart';
import '../services/comentario_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_text_field.dart';

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

  Future<void> editarComentario(ComentarioModel comentario) async {
    final controller = TextEditingController(text: comentario.comentario);

    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Comentario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (nuevoTexto == null || nuevoTexto.isEmpty) return;

    try {
      await comentarioService.actualizarComentario(
        id: comentario.id,
        comentario: nuevoTexto,
      );

      if (!mounted) return;

      setState(() {
        futuroComentarios = comentarioService.obtenerComentarios();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
    }
  }

  Future<void> eliminarComentario(ComentarioModel comentario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este comentario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await comentarioService.eliminarComentario(comentario.id);

      if (!mounted) return;

      setState(() {
        futuroComentarios = comentarioService.obtenerComentarios();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario eliminado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFE76B8B),
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        title: const Text('Detalle de publicación'),
        flexibleSpace: Center(
          child: Image.asset(
            'assets/images/icono-gsip.png',
            height: 45,
            fit: BoxFit.contain,
          ),
        ),
      ),

      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.post.imagen.isNotEmpty)
                Image.network(
                  widget.post.imagen.startsWith('http')
                      ? widget.post.imagen
                      : 'http://localhost/blog_web/uploads/${widget.post.imagen.split('/').last}',

                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
                        color: Color(0xFF68152F),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF246A73),
                      ),
                    ),

                    const SizedBox(height: 15),

                    FutureBuilder<List<ComentarioModel>>(
                      future: futuroComentarios,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            'No se pudieron cargar los comentarios.',
                          );
                        }

                        final comentarios = (snapshot.data ?? [])
                            .where(
                              (comentario) =>
                                  comentario.blogId == widget.post.id,
                            )
                            .toList();

                        if (comentarios.isEmpty) {
                          return const Text('Todavía no hay comentarios.');
                        }

                        return Column(
                          children: comentarios.map((comentario) {
                            final esPropio =
                                comentario.usuarioId ==
                                widget.usuario['id_usr'];

                            final esAdmin = widget.usuario['tip_usu'] == 1;

                            return ListTile(
                              leading: const Icon(Icons.comment),
                              title: Text(comentario.comentario),
                              subtitle: Text(comentario.fecha),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (esPropio)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF246A73),
                                      ),
                                      onPressed: () =>
                                          editarComentario(comentario),
                                    ),
                                  if (esPropio || esAdmin)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xFF68152F),
                                      ),
                                      onPressed: () =>
                                          eliminarComentario(comentario),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: comentarioController,
                      label: 'Escribe un comentario',
                      prefixIcon: Icons.comment_outlined,
                      hintText: '¿Qué opinas de esta publicación?',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: guardarComentario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246A73),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Publicar comentario'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
