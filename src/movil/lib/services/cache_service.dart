// lib/services/cache_service.dart
//
// Servicio de Caché con TTL (Time To Live)
// =====================================================
// Persiste datos JSON en SharedPreferences con metadata
// de expiración. Si el dato expiró → retorna null.
// Si el servidor falla → fallback al caché aunque esté expirado.
// =====================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _keyPrefix = 'cache_ttl_';
  static const String _expirySuffix = '_expiry';

  // ─────────────────────────────────────────────────
  // Guardar dato con TTL
  // ─────────────────────────────────────────────────
  Future<void> set(String key, dynamic data, {int ttlMinutes = 5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      final expiryKey = '$fullKey$_expirySuffix';

      final expiryTime = DateTime.now()
          .add(Duration(minutes: ttlMinutes))
          .millisecondsSinceEpoch;

      await prefs.setString(fullKey, jsonEncode(data));
      await prefs.setInt(expiryKey, expiryTime);

      debugPrint('[Cache] ✅ Guardado "$key" (TTL: $ttlMinutes min)');
    } catch (e) {
      debugPrint('[Cache] ❌ Error guardando "$key": $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Obtener dato si no ha expirado
  // Retorna null si expirado o no existe
  // ─────────────────────────────────────────────────
  Future<dynamic> get(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      final expiryKey = '$fullKey$_expirySuffix';

      final expiryTime = prefs.getInt(expiryKey);
      if (expiryTime == null) return null;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiryTime) {
        debugPrint('[Cache] ⏰ Expirado "$key"');
        return null; // TTL expirado
      }

      final raw = prefs.getString(fullKey);
      if (raw == null) return null;

      debugPrint('[Cache] 🎯 Hit "$key"');
      return jsonDecode(raw);
    } catch (e) {
      debugPrint('[Cache] ❌ Error leyendo "$key": $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  // Obtener dato aunque haya expirado (fallback offline)
  // Retorna null solo si NO EXISTE ningún dato
  // ─────────────────────────────────────────────────
  Future<dynamic> getStale(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      final raw = prefs.getString(fullKey);

      if (raw == null) return null;
      debugPrint('[Cache] 🔄 Stale fallback "$key"');
      return jsonDecode(raw);
    } catch (e) {
      debugPrint('[Cache] ❌ Error en stale fallback "$key": $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  // Verificar si una clave tiene datos (aunque expirados)
  // ─────────────────────────────────────────────────
  Future<bool> hasStale(String key) async {
    final data = await getStale(key);
    return data != null;
  }

  // ─────────────────────────────────────────────────
  // Eliminar un dato del caché
  // ─────────────────────────────────────────────────
  Future<void> delete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      await prefs.remove(fullKey);
      await prefs.remove('$fullKey$_expirySuffix');
      debugPrint('[Cache] 🗑️ Eliminado "$key"');
    } catch (e) {
      debugPrint('[Cache] ❌ Error eliminando "$key": $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Limpiar todo el caché de la app
  // ─────────────────────────────────────────────────
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      debugPrint('[Cache] 🧹 Caché limpiado completamente');
    } catch (e) {
      debugPrint('[Cache] ❌ Error limpiando caché: $e');
    }
  }
}
