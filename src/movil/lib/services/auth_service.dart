// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://localhost:3001";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/usuario/auth/cliente");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": email, // el backend espera "correo", no "email"
          "contrasenia":
              password, // el backend espera "contrasenia", no "password"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'];
        final username = data['usuario']['username'];
        final codigoUnico = data['usuario']['codigoUnico'];
        final loyaltyToken = data['usuario']['loyalty_token'];

        if (token != null) {
          await SecureStorage.saveToken(token);
          await SecureStorage.saveUserName(username);
          await SecureStorage.saveCodigoUnico(codigoUnico);
          await SecureStorage.saveLoyaltyToken(loyaltyToken);
          return {"success": true, "data": data};
        }
      }

      final errorMsg =
          jsonDecode(response.body)['message'] ?? 'Error al iniciar sesión';
      return {"success": false, "message": errorMsg};
    } catch (e) {
      return {
        "success": false,
        "message": "Error de conexión. Verifica tu internet o el servidor.",
      };
    }
  }
}
