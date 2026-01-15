import 'package:cafeteria_uide/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (context) =>
          AuthProvider(), // Se instancia aquí y carga la sesión automáticamente
      child: MaterialApp(
        title: 'Cafetería Universitaria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        initialRoute: AppRoutes.initialRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}
