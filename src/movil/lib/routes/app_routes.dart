import 'package:flutter/material.dart';

// Pantallas
import '../ui/screens/login_screen.dart';
import '../ui/screens/main_screen.dart'; // Esta será el home después del login
import '../ui/screens/register_screen.dart';

class AppRoutes {
  static const initialRoute = '/home';

  static final Map<String, WidgetBuilder> routes = {
    '/main': (_) => const MainScreen(),
    '/register': (_) => const RegisterScreen(),
    '/home': (_) => const MainScreen(),
    '/login': (_) => const LoginScreen(),
    '/profile': (_) => Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    ),
    '/promotions': (_) => Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: const Center(child: Text('Promotions')),
    ),
  };
}
