// lib/services/error_reporter.dart
//
// Capturador global de errores para CafeteriaUIDE
// Captura:
//   - FlutterError (errores de renderizado y lógica de widgets)
//   - runZonedGuarded (errores async no manejados)
// =====================================================

import 'package:flutter/foundation.dart';

class ErrorReporter {
  static final ErrorReporter _instance = ErrorReporter._internal();
  factory ErrorReporter() => _instance;
  ErrorReporter._internal();

  // Contador de errores en sesión (para telemetría)
  int _errorCount = 0;
  int get errorCount => _errorCount;

  // Inicializar manejadores globales
  void initialize() {
    // Captura errores de renderizado de Flutter (widgets, layout, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      _reportError(
        error: details.exception,
        stack: details.stack,
        context: details.context?.toString() ?? 'FlutterError',
        library: details.library ?? 'Flutter',
      );

      // En debug: mostrar en consola también
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    debugPrint('[ErrorReporter] ✅ Inicializado. Escuchando errores globales.');
  }

  // Registrar error estructurado
  void _reportError({
    required Object error,
    StackTrace? stack,
    String context = 'unknown',
    String library = 'unknown',
  }) {
    _errorCount++;
    final timestamp = DateTime.now().toIso8601String();

    // Log estructurado para telemetría
    debugPrint('''
╔══════════════════════════════════════════════════════
║ [ErrorReporter] Error #$_errorCount capturado
║ Timestamp : $timestamp
║ Contexto  : $context
║ Librería  : $library
║ Error     : $error
║ StackTrace: ${stack?.toString().split('\n').take(5).join('\n║             ')}
╚══════════════════════════════════════════════════════
''');

    // En producción: aquí se enviaría a Firebase Crashlytics o Sentry
    // FirebaseCrashlytics.instance.recordError(error, stack, context: context);
  }

  // Método público para reportar errores desde zonas async
  void reportZoneError(Object error, StackTrace stack) {
    _reportError(
      error: error,
      stack: stack,
      context: 'ZonedGuard',
      library: 'Dart async zone',
    );
  }

  // Método público para reportar errores manejados manualmente
  void reportHandledError({
    required Object error,
    StackTrace? stack,
    String context = 'handled',
  }) {
    _reportError(error: error, stack: stack, context: context);
  }
}
