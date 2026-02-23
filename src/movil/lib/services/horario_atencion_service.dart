// lib/services/horario_atencion_service.dart
// Actualizado con caché TTL de 30 minutos + fallback offline
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cache_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class HorarioAtencionService {
  static final apiUrl = dotenv.env['API_URL'];
  static const _cacheKey = 'horarios_publicos';
  static const _cacheTtlMinutes = 30;

  /// Obtiene los horarios de atención visibles para el público (clientes / app)
  /// No requiere autenticación. TTL: 30 minutos.
  static Future<Map<String, dynamic>> getHorariosPublicos() async {
    final cache = CacheService();

    // 1. Intentar obtener de red
    try {
      final url = Uri.parse("$apiUrl/api/horarios/mostrar");
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final horarios = data['horarios'] as List<dynamic>? ?? [];

        // Guardar en caché con TTL
        await cache.set(_cacheKey, horarios, ttlMinutes: _cacheTtlMinutes);
        debugPrint('[HorarioService] ✅ Horarios obtenidos de red y cacheados');

        return {
          "success": true,
          "horarios": horarios,
          "fromCache": false,
          "message": data['message'] ?? "Horarios obtenidos correctamente",
        };
      } else {
        return await _fromCache(cache, statusCode: response.statusCode);
      }
    } catch (e) {
      debugPrint('[HorarioService] ⚠️ Red fallida: $e');
      return await _fromCache(cache);
    }
  }

  static Future<Map<String, dynamic>> _fromCache(CacheService cache, {int? statusCode}) async {
    dynamic cached = await cache.get(_cacheKey);
    cached ??= await cache.getStale(_cacheKey);

    if (cached != null) {
      debugPrint('[HorarioService] 📦 Horarios desde caché (offline fallback)');
      return {
        "success": true,
        "horarios": cached as List<dynamic>,
        "fromCache": true,
        "message": "Datos sin conexión",
      };
    }

    final msg = statusCode != null
        ? 'Error del servidor ($statusCode)'
        : 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
    return {"success": false, "message": msg};
  }
}
