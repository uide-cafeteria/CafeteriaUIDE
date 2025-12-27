import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería Universitaria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Ahora usamos rutas
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
