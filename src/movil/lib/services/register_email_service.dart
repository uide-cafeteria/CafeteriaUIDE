// lib/services/register_email_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterEmailService {
  final String? apiUrl = dotenv.env['API_URL'];

  Future<Map<String, dynamic>> registerWithEmail({
    required String username,
    required String email,
    required String password,
    String? telefono,
  }) async {
    if (apiUrl == null) {
      return {"success": false, "message": "API_URL no configurado en .env"};
    }

    final url = Uri.parse("$apiUrl/api/usuario/registro/correo");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "correo": email.trim(),
          "telefono": telefono?.trim(),
          "contrasenia": password,
        }),
      );

      // Siempre intentamos parsear la respuesta
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          "success": false,
          "message": "Respuesta inválida del servidor (no es JSON válido)",
        };
      }

      // Caso de éxito: status 201 + status true
      if (response.statusCode == 201 && data['status'] == true) {
        // Solo esperamos userId (no token ni usuario completo)
        if (data['userId'] == null) {
          return {
            "success": false,
            "message": "Respuesta del servidor incompleta: falta userId",
          };
        }

        return {
          "success": true,
          "message":
              data['message'] ??
              'Revisa tu correo para el código de verificación.',
          "userId": data['userId'].toString(), // aseguramos que sea String
        };
      }

      // Caso de error del backend
      return {
        "success": false,
        "message":
            data['message'] ?? 'Error al registrar (${response.statusCode})',
        "errors": data['errores'] ?? null,
      };
    } catch (e) {
      print('Error en registerWithEmail: $e'); // para debug
      return {
        "success": false,
        "message":
            "Error de conexión. Verifica tu internet o intenta más tarde.",
      };
    }
  }
}
