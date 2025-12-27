// lib/services/historial_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class HistorialService {
  static const String baseUrl = "http://localhost:3001";

  static Future<Map<String, dynamic>> obtenerMiHistorial() async {
    final token = await SecureStorage.getToken();

    // Validación temprana del token (similar a lo que harías en otros services)
    if (token == null || token.isEmpty) {
      return {
        "success": false,
        "message": "No se encontró token. Por favor inicia sesión nuevamente.",
      };
    }

    final url = Uri.parse("$baseUrl/api/historial/usuario/mostrar");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Decodificamos el body (casi siempre será JSON en tu API)
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Asumiendo que el backend devuelve algo como { "data": [...] } o directamente la lista
        final data =
            body['data'] ?? body; // flexibilidad por si cambia la estructura

        return {
          "success": true,
          "data": data, // puede ser List o Map según lo que devuelva el backend
        };
      } else {
        // Cualquier error HTTP (401, 404, 500, etc.)
        final errorMsg = body['message'] ?? 'Error al cargar el historial';
        return {"success": false, "message": errorMsg};
      }
    } catch (e) {
      // Errores de red, timeout, JSON mal formado, etc.
      return {
        "success": false,
        "message":
            "Error de conexión. Verifica tu internet o intenta más tarde. $e",
      };
    }
  }
}
