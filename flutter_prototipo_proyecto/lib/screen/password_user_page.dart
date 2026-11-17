import 'package:flutter/material.dart';
import 'login_user_page.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController correoController = TextEditingController();

  final TextEditingController newpasswordController = TextEditingController();

  bool ocultarPassword = true;

  @override
  void dispose() {
    correoController.dispose();
    newpasswordController.dispose();
    super.dispose();
  }

  void iniciarSesion() {
    String usuario = correoController.text.trim();

    String password = newpasswordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa correo y nueva contraseña')),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Bienvenido $usuario')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F6FF),
              Color(0xFFBFD9FF),
              Color(0xFFD9D1FF),
              Color(0xFFE8DFFF),
            ],
          ),
        ),

        child: Center(
          child: Card(
            elevation: 10,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: SizedBox(
                width: 340,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(Icons.lock, size: 65, color: Color(0xFFC9A227)),

                    const SizedBox(height: 15),

                    const Text(
                      'CAMBIAR CONTRASEÑA',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08245C),
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: correoController,

                      decoration: InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: newpasswordController,

                      obscureText: ocultarPassword,

                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',

                        prefixIcon: const Icon(Icons.lock_outline),

                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),

                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,

                      child: TextButton(
                        onPressed: () {},

                        child: const Text(''),
                      ),
                    ),

                    const SizedBox(height: 5),

                    ElevatedButton(
                      onPressed: iniciarSesion,

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),

                        backgroundColor: const Color(0xFF2196F3),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),

                      child: const Text(
                        'GUARDAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text(''),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('Registrarse'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
