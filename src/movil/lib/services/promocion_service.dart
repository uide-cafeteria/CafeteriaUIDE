import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promocion.dart';

class PromocionService {
  static const String baseUrl = "http://localhost:3001";

  static Future<Map<String, dynamic>> obtenerPromocionesActivas() async {
    final url = Uri.parse("$baseUrl/api/promocion/mostrar");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        final List<dynamic> promosJson = body['promociones'] ?? [];
        final List<Promotion> promociones = promosJson
            .map((json) => Promotion.fromJson(json))
            .toList();

        return {"success": true, "promociones": promociones};
      } else {
        return {
          "success": false,
          "message":
              body['message'] ?? "No hay promociones activas en este momento",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}
