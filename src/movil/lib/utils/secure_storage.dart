// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ────────────────────────────────────────────────
  // Token JWT
  // ────────────────────────────────────────────────
  static Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async =>
      await _storage.read(key: 'jwt_token');

  static Future<void> deleteToken() async =>
      await _storage.delete(key: 'jwt_token');

  // ────────────────────────────────────────────────
  // Username
  // ────────────────────────────────────────────────
  static Future<void> saveUserName(String? username) async {
    if (username == null || username.isEmpty) return;
    await _storage.write(key: 'user_name', value: username);
  }

  static Future<String?> getUserName() async =>
      await _storage.read(key: 'user_name');

  static Future<void> deleteUserName() async =>
      await _storage.delete(key: 'user_name');

  // ────────────────────────────────────────────────
  // Email
  // ────────────────────────────────────────────────
  static Future<void> saveEmail(String? correo) async {
    if (correo == null || correo.isEmpty) return;
    await _storage.write(key: 'correo', value: correo);
  }

  static Future<String?> getEmail() async => await _storage.read(key: 'correo');

  static Future<void> deleteEmail() async =>
      await _storage.delete(key: 'correo');

  // ────────────────────────────────────────────────
  // Loyalty Token
  // ────────────────────────────────────────────────
  static Future<void> saveLoyaltyToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _storage.write(key: 'loyalty_token', value: token);
  }

  static Future<String?> getLoyaltyToken() async =>
      await _storage.read(key: 'loyalty_token');

  static Future<void> deleteLoyaltyToken() async =>
      await _storage.delete(key: 'loyalty_token');

  // ────────────────────────────────────────────────
  // Código único
  // ────────────────────────────────────────────────
  static Future<void> saveCodigoUnico(String? codigo) async {
    if (codigo == null || codigo.isEmpty) return;
    await _storage.write(key: 'codigo_unico', value: codigo);
  }

  static Future<String?> getCodigoUnico() async =>
      await _storage.read(key: 'codigo_unico');

  static Future<void> deleteCodigoUnico() async =>
      await _storage.delete(key: 'codigo_unico');

  // ────────────────────────────────────────────────
  // Métodos de utilidad
  // ────────────────────────────────────────────────
  static Future<void> logout() async {
    await deleteToken();
    await deleteUserName();
    await deleteLoyaltyToken();
    await deleteCodigoUnico();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
