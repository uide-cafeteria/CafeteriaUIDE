// lib/services/analytics_service.dart
//
// Plan de Observabilidad – CafeteriaUIDE
// =====================================================
// Eventos de negocio definidos (≥8 requeridos):
//
// 1. menu_viewed          → ¿Cuántos usuarios ven el menú del día?
// 2. menu_item_tapped     → ¿Qué platos generan más interés?
// 3. catering_form_started → ¿Cuántos usuarios inician catering?
// 4. catering_form_submitted → ¿Cuántos completan el formulario?
// 5. promotion_viewed     → ¿Qué promociones se ven más?
// 6. login_success        → Tasa de éxito de login
// 7. session_time_on_home → Tiempo promedio en pantalla principal
// 8. connectivity_restored → Frecuencia de pérdida/recuperación de red
// =====================================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal() {
    _init();
  }

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> _init() async {
    // Asegurar que la colección de analytics está activa
    await _analytics.setAnalyticsCollectionEnabled(true);
    if (kDebugMode) {
      // En debug: envía eventos inmediatamente (visible en DebugView)
      debugPrint(
        '[Analytics] ✅ Inicializado en modo DEBUG – eventos en tiempo real',
      );
    }
  }

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─────────────────────────────────────────────────
  // EVENTO 1: Menú del día visualizado
  // Pregunta: ¿Cuántos usuarios ven el menú del día?
  // ─────────────────────────────────────────────────
  Future<void> logMenuViewed({String? fechaMenu}) async {
    try {
      await _analytics.logEvent(
        name: 'menu_viewed',
        parameters: {
          'fecha_menu':
              fechaMenu ?? DateTime.now().toIso8601String().substring(0, 10),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ menu_viewed logged');
    } catch (e) {
      debugPrint('[Analytics] ❌ menu_viewed error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 2: Producto del menú tocado
  // Pregunta: ¿Qué platos generan más interés?
  // ─────────────────────────────────────────────────
  Future<void> logMenuItemTapped({
    required String nombreProducto,
    required String categoria,
    double? precio,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'menu_item_tapped',
        parameters: {
          'nombre_producto': nombreProducto,
          'categoria': categoria,
          'precio': precio ?? 0.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ menu_item_tapped: $nombreProducto');
    } catch (e) {
      debugPrint('[Analytics] ❌ menu_item_tapped error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 3: Formulario de catering iniciado
  // Pregunta: ¿Cuántos usuarios inician un pedido?
  // ─────────────────────────────────────────────────
  Future<void> logCateringFormStarted() async {
    try {
      await _analytics.logEvent(
        name: 'catering_form_started',
        parameters: {'timestamp': DateTime.now().millisecondsSinceEpoch},
      );
      debugPrint('[Analytics] ✅ catering_form_started logged');
    } catch (e) {
      debugPrint('[Analytics] ❌ catering_form_started error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 4: Formulario de catering enviado
  // Pregunta: ¿Cuántos completan el formulario?
  // ─────────────────────────────────────────────────
  Future<void> logCateringFormSubmitted({
    required String tipoEvento,
    int? cantidadPersonas,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'catering_form_submitted',
        parameters: {
          'tipo_evento': tipoEvento,
          'cantidad_personas': cantidadPersonas ?? 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ catering_form_submitted: $tipoEvento');
    } catch (e) {
      debugPrint('[Analytics] ❌ catering_form_submitted error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 5: Promoción visualizada
  // Pregunta: ¿Qué promociones se ven más?
  // ─────────────────────────────────────────────────
  Future<void> logPromotionViewed({
    required String nombrePromocion,
    String? descuento,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'promotion_viewed',
        parameters: {
          'nombre_promocion': nombrePromocion,
          'descuento': descuento ?? 'N/A',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ promotion_viewed: $nombrePromocion');
    } catch (e) {
      debugPrint('[Analytics] ❌ promotion_viewed error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 6: Login exitoso
  // Pregunta: ¿Cuál es la tasa de éxito de login?
  // ─────────────────────────────────────────────────
  Future<void> logLoginSuccess({required String metodo}) async {
    try {
      await _analytics.logLogin(loginMethod: metodo);
      await _analytics.logEvent(
        name: 'login_success',
        parameters: {
          'metodo': metodo,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ login_success: $metodo');
    } catch (e) {
      debugPrint('[Analytics] ❌ login_success error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 7: Tiempo de sesión en pantalla Home
  // Pregunta: ¿Cuánto tiempo pasa el usuario en home?
  // ─────────────────────────────────────────────────
  Future<void> logSessionTimeOnHome({required int segundos}) async {
    try {
      await _analytics.logEvent(
        name: 'session_time_on_home',
        parameters: {
          'duracion_segundos': segundos,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ session_time_on_home: ${segundos}s');
    } catch (e) {
      debugPrint('[Analytics] ❌ session_time_on_home error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTO 8: Conectividad restaurada
  // Pregunta: ¿Cuántas veces pierden/recuperan conexión?
  // ─────────────────────────────────────────────────
  Future<void> logConnectivityRestored({int? segundosDesconectado}) async {
    try {
      await _analytics.logEvent(
        name: 'connectivity_restored',
        parameters: {
          'segundos_desconectado': segundosDesconectado ?? 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('[Analytics] ✅ connectivity_restored');
    } catch (e) {
      debugPrint('[Analytics] ❌ connectivity_restored error: $e');
    }
  }
}
