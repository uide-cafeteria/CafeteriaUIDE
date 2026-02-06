// lib/services/catering_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catering.dart';

class CateringService {
  static const String baseUrl = "http://localhost:3002";

  // ────────────────────────────────────────────────
  // 1. Crear / enviar solicitud de catering
  // ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> crearSolicitud({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String fechaEvento, // 'YYYY-MM-DD'
    String? horaEvento, // 'HH:mm:ss' o null
    required String tipoEvento,
    int? cantidadPersonas,
    String? descripcion,
  }) async {
    final url = Uri.parse("$baseUrl/api/catering/crear");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre_completo": nombreCompleto,
          "correo": correo,
          "telefono": telefono,
          "fecha_evento": fechaEvento,
          "hora_evento": horaEvento,
          "tipo_evento": tipoEvento,
          "cantidad_personas": cantidadPersonas,
          "descripcion": descripcion,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['status'] == true) {
        return {
          "success": true,
          "message": body['message'] ?? "¡Solicitud enviada con éxito!",
          "solicitud": body['solicitud'], // opcional
        };
      } else {
        return {
          "success": false,
          "message": body['message'] ?? "No se pudo enviar la solicitud",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error de conexión. Verifica tu internet.",
      };
    }
  }

  // ────────────────────────────────────────────────
  // 2. Obtener MIS solicitudes (requiere estar logueado)
  // ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMisSolicitudes(String token) async {
    final url = Uri.parse("$baseUrl/api/catering/mis-solicitudes");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        final solicitudesJson = body['solicitudes'] as List<dynamic>? ?? [];
        final solicitudes = solicitudesJson
            .map((json) => Catering.fromJson(json))
            .toList();

        return {"success": true, "solicitudes": solicitudes};
      } else {
        return {
          "success": false,
          "message": body['message'] ?? "No se pudieron cargar tus solicitudes",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ────────────────────────────────────────────────
  // 3. Cancelar una solicitud (solo si está pendiente)
  // ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> cancelarSolicitud(
    String token,
    int idSolicitud,
  ) async {
    final url = Uri.parse("$baseUrl/api/catering/$idSolicitud/cancelar");

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {
          "success": true,
          "message": body['message'] ?? "Solicitud cancelada correctamente",
        };
      } else {
        return {
          "success": false,
          "message": body['message'] ?? "No se pudo cancelar la solicitud",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}
