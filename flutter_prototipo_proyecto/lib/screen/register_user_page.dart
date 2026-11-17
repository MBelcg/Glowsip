import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController = TextEditingController();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  final UserService userService = UserService();

  int tipoUsuario = 2; // 1 = admin, 2 = general

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> registrarUsuario() async {
    final mensaje = authService.validarRegistro(
      nombre: nombreController.text.trim(),

      correo: correoController.text.trim(),

      password: passwordController.text,

      confirmarpassword: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));

      return;
    }

    try {
      await userService.agregarUsuario(
        UserModel(
          id: 0,
          nombre: nombreController.text.trim(),
          correo: correoController.text.trim().toLowerCase(),
          password: passwordController.text,
          tipoUsuario: tipoUsuario,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario ${nombreController.text} registrado')),
      );

      nombreController.clear();
      correoController.clear();
      passwordController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo registrar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ModalRoute.of(context)?.settings.arguments;
    final admin = usuario is Map && usuario['tip_usu'] == 1;

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Image.asset(
                  'assets/images/Logo-gsip.png',
                  width: 230,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8003B),
                  ),
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  controller: nombreController,

                  label: 'Nombre completo',

                  prefixIcon: Icons.person,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: correoController,

                  label: 'Correo electrónico',

                  prefixIcon: Icons.email,

                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: passwordController,

                  label: 'Contraseña',

                  prefixIcon: Icons.lock,

                  obscureText: true,
                ),

                const SizedBox(height: 15),

                if (admin)
                  DropdownButtonFormField<int>(
                    value: tipoUsuario,
                    decoration: InputDecoration(
                      labelText: 'Tipo de usuario',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Administrador')),
                      DropdownMenuItem(value: 2, child: Text('Usuario')),
                    ],
                    onChanged: (valor) {
                      setState(() => tipoUsuario = valor ?? 2);
                    },
                  ),

                const SizedBox(height: 25),

                PrimaryButton(text: 'REGISTRAR', onPressed: registrarUsuario),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
