// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/secure_storage.dart';

class AuthService {
  final String? apiUrl = dotenv.env['API_URL'];

  // ────────────────────────────────────────────────
  //  Login normal con correo + contraseña
  // ────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (apiUrl == null) {
      return {"success": false, "message": "API_URL no configurado en .env"};
    }

    final url = Uri.parse("$apiUrl/api/usuario/auth/cliente");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": email.trim(), "contrasenia": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final token = data['token'];
          final user = data['usuario'];

          if (token != null && user != null) {
            await SecureStorage.saveToken(token);
            await SecureStorage.saveUserName(user['username'] ?? '');
            await SecureStorage.saveCodigoUnico(user['codigoUnico'] ?? '');
            await SecureStorage.saveEmail(user['correo'] ?? '');
            await SecureStorage.saveLoyaltyToken(user['loyalty_token'] ?? '');

            return {"success": true, "data": data};
          }
        }
      }

      // Intentamos leer el mensaje de error del backend
      String errorMsg;
      try {
        errorMsg =
            jsonDecode(response.body)['message'] ??
            'Credenciales inválidas o error del servidor';
      } catch (_) {
        errorMsg = 'Error del servidor (${response.statusCode})';
      }

      return {"success": false, "message": errorMsg};
    } catch (e) {
      return {
        "success": false,
        "message": "Error de conexión. Verifica tu internet.",
      };
    }
  }

  // Opcional: método de cerrar sesión (solo limpia el storage local)
  Future<void> signOut() async {
    try {
      await SecureStorage.deleteAll(); // o borra solo las keys necesarias
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}
