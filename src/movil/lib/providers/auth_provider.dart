// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _correo;
  String? _codigoUnico;
  String? _loyaltyToken;
  bool _isLoading = true;

  String? get token => _token;
  String? get username => _username;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadSession(); // ← clave: cargar al instanciar
  }

  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    final savedToken = await SecureStorage.getToken();
    final savedUsername = await SecureStorage.getUserName();
    final savedCodigo = await SecureStorage.getCodigoUnico();
    final savedCorreo = await SecureStorage.getEmail();
    final savedLoyalty = await SecureStorage.getLoyaltyToken();

    _token = savedToken;
    _username = savedUsername;
    _codigoUnico = savedCodigo;
    _correo = savedCorreo;
    _loyaltyToken = savedLoyalty;

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await AuthService().login(email, password);

    if (result['success'] == true) {
      final data = result['data'];
      _token = data['token'] ?? data['accessToken'];
      _username = data['usuario']['username'];
      _codigoUnico = data['usuario']['codigoUnico'];
      _correo = data['usuario']['correo'];
      _loyaltyToken = data['usuario']['loyalty_token'];

      // Ya se guardó en SecureStorage dentro de AuthService
      notifyListeners();
    }

    return result;
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _codigoUnico = null;
    _loyaltyToken = null;
    _correo = null;

    await SecureStorage.deleteToken();
    await SecureStorage.deleteUserName();
    await SecureStorage.deleteCodigoUnico();
    await SecureStorage.deleteLoyaltyToken();
    await SecureStorage.deleteEmail();

    notifyListeners();
  }
}
