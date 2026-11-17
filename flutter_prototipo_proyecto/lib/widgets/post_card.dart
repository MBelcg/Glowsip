import 'package:flutter/material.dart';

import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final bool admin;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.admin = false,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagen.isNotEmpty)
              Image.network(
                post.imagen.startsWith('http')
                    ? post.imagen
                    : 'http://localhost/blog_web/uploads/${post.imagen.split('/').last}',
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 110,
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      post.tags,
                      style: const TextStyle(
                        color: Color(0xFFF04472),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  Text(
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF68152F),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    post.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: Color(0xFF246A73),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Leer publicación',
                        style: TextStyle(color: Color(0xFF246A73)),
                      ),
                    ],
                  ),

                  if (admin) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Editar publicación',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF246A73),
                          ),
                          onPressed: onEditar,
                        ),
                        IconButton(
                          tooltip: 'Eliminar publicación',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: onEliminar,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
