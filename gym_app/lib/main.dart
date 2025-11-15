import 'package:flutter/material.dart';
import 'Home/login_home.dart';
import 'Home/register_home.dart';

void main() {
  runApp(GymApp());
}

class GymApp extends StatelessWidget {
  GymApp({Key? key}) : super(key: key); // ← Sin const aquí

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Gym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0F3460), // ← Sin const
        scaffoldBackgroundColor: Color(0xFF1A1A2E), // ← Sin const
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}