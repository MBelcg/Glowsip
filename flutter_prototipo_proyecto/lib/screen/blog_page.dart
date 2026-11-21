import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/user_drawer.dart';
import 'add_blog_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': 2,
  };
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': 2};
      }

      argumentoLeido = true;
    }
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE76B8B),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 80,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icono-gsip.png',
              height: 45,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recargarPosts,
          ),
        ],
      ),

      drawer: (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/blog')
          : UserDrawer(usuario: usuarioActual, rutaActual: '/blog'),

      body: AuthBackground(
        child: FutureBuilder<List<PostModel>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 45),
                      const SizedBox(height: 12),
                      const Text(
                        'No fue posible cargar el blog.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: recargarPosts,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final posts = snapshot.data ?? <PostModel>[];

            if (posts.isEmpty) {
              return const Center(
                child: Text('No hay publicaciones registradas.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8003B),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Descubre nuevas ideas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                ...posts.map(
                  (post) => PostCard(
                    post: post,
                    admin: (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1,
                    onEditar: () async {
                      final actualizado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBlogPage(post: post),
                          settings: RouteSettings(arguments: usuarioActual),
                        ),
                      );

                      if (actualizado == true) {
                        recargarPosts();
                      }
                    },
                    onEliminar: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar publicación'),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar esta publicación?',
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

                      if (confirmar == true) {
                        try {
                          await postService.eliminarPost(post.id);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Publicación eliminada correctamente',
                              ),
                            ),
                          );

                          recargarPosts();
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No se pudo eliminar: $e')),
                          );
                        }
                      }
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => PostDetailPage(
                            post: post,
                            usuario: usuarioActual,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
