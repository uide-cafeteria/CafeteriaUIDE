// utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // NUEVAS FUNCIONES PARA EL NOMBRE o username
  static Future<void> saveUserName(String name) async {
    await _storage.write(key: 'user_name', value: name);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  // nuevas funciones para el token de la Loyalty o QR
  static Future<void> saveLoyaltyToken(String token) async {
    await _storage.write(key: 'loyalty_token', value: token);
  }

  static Future<String?> getLoyaltyToken() async {
    return await _storage.read(key: 'loyalty_token');
  }

  // nuevas funciones para el codigoUnico
  static Future<void> saveCodigoUnico(String codigoUnico) async {
    await _storage.write(key: 'codigo_unico', value: codigoUnico);
  }

  static Future<String?> getCodigoUnico() async {
    return await _storage.read(key: 'codigo_unico');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
