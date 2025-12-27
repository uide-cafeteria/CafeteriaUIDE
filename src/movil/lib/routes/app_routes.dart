import 'package:flutter/material.dart';

// Pantallas
import '../ui/screens/login_screen.dart';
import '../ui/screens/main_screen.dart'; // Esta será el home después del login

class AppRoutes {
  static const initialRoute = '/home';

  static final Map<String, WidgetBuilder> routes = {
    '/main': (_) => const MainScreen(),
    '/home': (_) => const MainScreen(),
    '/login': (_) => const LoginScreen(),
    '/promotions': (_) => Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: const Center(child: Text('Promotions')),
    ),
  };
}
