// lib/services/promocion_service.dart
// Actualizado con caché TTL de 10 minutos + fallback offline
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promocion.dart';
import 'cache_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class PromocionService {
  static final apiUrl = dotenv.env['API_URL'];
  static const _cacheKey = 'promociones_activas';
  static const _cacheTtlMinutes = 10;

  static Future<Map<String, dynamic>> obtenerPromocionesActivas() async {
    final cache = CacheService();

    // 1. Intentar red
    try {
      final url = Uri.parse("$apiUrl/api/promocion/mostrar");
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        final List<dynamic> promosJson = body['promociones'] ?? [];

        // Guardar raw para el caché (antes de deserializar)
        await cache.set(_cacheKey, promosJson, ttlMinutes: _cacheTtlMinutes);
        debugPrint('[PromocionService] ✅ Promociones obtenidas de red y cacheadas');

        final List<Promotion> promociones =
            promosJson.map((json) => Promotion.fromJson(json)).toList();
        return {"success": true, "promociones": promociones, "fromCache": false};
      } else {
        return await _fromCache(cache,
            fallback: body['message'] ?? "No hay promociones activas en este momento");
      }
    } catch (e) {
      debugPrint('[PromocionService] ⚠️ Red fallida: $e');
      return await _fromCache(cache, fallback: "Sin conexión. Mostrando promociones cacheadas.");
    }
  }

  static Future<Map<String, dynamic>> _fromCache(CacheService cache,
      {String fallback = ''}) async {
    dynamic cached = await cache.get(_cacheKey);
    cached ??= await cache.getStale(_cacheKey);

    if (cached != null) {
      debugPrint('[PromocionService] 📦 Promociones desde caché (offline fallback)');
      final List<Promotion> promociones =
          (cached as List<dynamic>).map((json) => Promotion.fromJson(json)).toList();
      return {"success": true, "promociones": promociones, "fromCache": true};
    }

    return {
      "success": false,
      "message": fallback.isEmpty ? "No hay promociones disponibles" : fallback
    };
  }
}
