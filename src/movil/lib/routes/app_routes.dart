import 'package:cafeteria_uide/ui/pages/menu_completo_page.dart';
import 'package:cafeteria_uide/ui/pages/promotions_page.dart';
import 'package:cafeteria_uide/ui/pages/menu_completo_page.dart';
import 'package:flutter/material.dart';

// Pantallas
import '../ui/screens/login_screen.dart';
import '../ui/screens/main_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/pages/historial_page.dart'; // Añadido

class AppRoutes {
  static const initialRoute = '/main';

  static final Map<String, WidgetBuilder> routes = {
    '/main': (context) => const MainScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/menu': (context) => const MenuCompletoPage(menuProductos: []),
    '/home': (context) => const MainScreen(),
    '/profile': (context) => Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    ),
    '/promotions': (context) =>
        const PromotionsPage(), // Si tienes la página real
    '/historial': (context) => const HistorialPage(),
  };
}
