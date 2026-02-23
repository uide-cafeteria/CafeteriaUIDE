// lib/services/menu_services.dart
// Actualizado con caché TTL de 5 minutos + fallback offline
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_del_dia.dart';
import 'cache_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class MenuService {
  static final apiUrl = dotenv.env['API_URL'];
  static const _cacheKey = 'menu_del_dia';
  static const _cacheTtlMinutes = 5;

  static Future<Map<String, dynamic>> obtenerMenuDelDia() async {
    final cache = CacheService();

    // 1. Intentar red
    try {
      final url = Uri.parse("$apiUrl/api/menu/mostrar");
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        // Guardar en caché con TTL
        await cache.set(_cacheKey, body['menu'], ttlMinutes: _cacheTtlMinutes);
        debugPrint('[MenuService] ✅ Menú obtenido de red y cacheado');
        return {"success": true, "menu": MenuDelDia.fromJson(body['menu']), "fromCache": false};
      } else {
        // Server respondió pero con error → buscar caché
        return await _fromCache(cache, fallback: body['message'] ?? "No hay menú disponible hoy");
      }
    } catch (e) {
      debugPrint('[MenuService] ⚠️ Red fallida: $e');
      // Red caída → intentar caché (incluso stale)
      return await _fromCache(cache, fallback: "Sin conexión. Mostrando datos cacheados.");
    }
  }

  static Future<Map<String, dynamic>> _fromCache(CacheService cache, {String fallback = ''}) async {
    // Intentar caché fresco primero
    dynamic cached = await cache.get(_cacheKey);
    cached ??= await cache.getStale(_cacheKey); // fallback stale

    if (cached != null) {
      debugPrint('[MenuService] 📦 Menú desde caché (offline fallback)');
      return {
        "success": true,
        "menu": MenuDelDia.fromJson(cached as Map<String, dynamic>),
        "fromCache": true,
        "message": "Datos sin conexión",
      };
    }

    return {"success": false, "message": fallback.isEmpty ? "No hay menú disponible" : fallback};
  }
}
