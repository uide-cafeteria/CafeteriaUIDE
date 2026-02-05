// lib/services/horario_atencion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HorarioAtencionService {
  static const String baseUrl = "http://localhost:3002";

  /// Obtiene los horarios de atención visibles para el público (clientes / app)
  /// No requiere autenticación
  Future<Map<String, dynamic>> getHorariosPublicos() async {
    final url = Uri.parse("$baseUrl/api/horarios/mostrar");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Asumiendo que el backend responde con { status: true, horarios: [...] }
        final horarios = data['horarios'] as List<dynamic>? ?? [];

        return {
          "success": true,
          "horarios": horarios,
          "message": data['message'] ?? "Horarios obtenidos correctamente",
        };
      } else {
        // Intenta leer mensaje de error del backend
        String errorMessage;
        try {
          errorMessage =
              jsonDecode(response.body)['message'] ??
              'No se pudieron obtener los horarios (${response.statusCode})';
        } catch (_) {
          errorMessage = 'Error del servidor (${response.statusCode})';
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {
        "success": false,
        "message":
            "No se pudo conectar con el servidor. Verifica tu conexión a internet.",
        "error": e.toString(),
      };
    }
  }
}
