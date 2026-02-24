// lib/main.dart
// =====================================================
// AUDITORÍA FASE 1:
//   ✅ runZonedGuarded – captura errores async globales
//   ✅ ErrorWidget.builder – renders elegantes en producción
//   ✅ Firebase inicializado antes de runApp
//   ✅ AnalyticsService inicializado
//   ✅ ErrorReporter configurado
// =====================================================

import 'dart:async';
import 'package:cafeteria_uide/providers/auth_provider.dart';
import 'package:cafeteria_uide/services/analytics_service.dart';
import 'package:cafeteria_uide/services/error_reporter.dart';
import 'package:cafeteria_uide/ui/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  // ── 1. ErrorWidget.builder: render elegante en producción
  //    (se puede configurar antes de cualquier init)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) return ErrorWidget(details.exception);
    return Material(
      child: Container(
        color: const Color(0xFFFAFAFA),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF7043)),
            const SizedBox(height: 16),
            const Text(
              'Ocurrió un problema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor reinicia la aplicación.\n${kDebugMode ? details.exception.toString() : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  };

  // ── 2. runZonedGuarded: TODOS los inits deben estar aquí
  //    para que ensureInitialized y runApp corran en la misma zona
  await runZonedGuarded(
    () async {
      // ── 3. Inicializar bindings DENTRO de la zona ────────
      WidgetsFlutterBinding.ensureInitialized();

      // ── 4. Inicializar manejador global de errores ───────
      ErrorReporter().initialize();

      await initializeDateFormatting('es', null);
      await dotenv.load(fileName: ".env");

      // ── 5. Inicializar Firebase ──────────────────────────
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // ── 6. Inicializar servicio de Analytics ─────────────
      AnalyticsService();

      runApp(const CafeteriaApp());
    },
    (error, stack) {
      ErrorReporter().reportZoneError(error, stack);
    },
  );
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          if (authProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ?? 'Cafeteria UIDE',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Pasar observer de Analytics a Navigator
            navigatorObservers: [AnalyticsService().observer],
            home: const HomePage(),
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
