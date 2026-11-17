import 'package:flutter/material.dart';
import 'screen/add_blog_page.dart';
import 'screen/blog_page.dart';
import 'screen/login_user_page.dart';
import 'screen/profile_page.dart';
import 'screen/register_user_page.dart';
import 'screen/users_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlowSip',
      initialRoute: '/login',
      routes: {
        '/blog': (context) => 
        const BlogPage(),
        '/login': (context) => 
        const LoginPage(),
        '/register': (context) => 
        const RegisterPage(),
        '/users':(context) => 
        const UsersPage(),
        '/add-blog':(context) => 
        const AddBlogPage(),
        '/profile':(context) => 
        const ProfilePage(),
      }
    );
  }
}
