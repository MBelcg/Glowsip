import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFFFF3F2),
            Color(0xFFFFE4E8),
            Color(0xFFFFD1DC),
            Color(0xFFFFE8ED),
          ],
        ),
      ),

      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/nubes.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
