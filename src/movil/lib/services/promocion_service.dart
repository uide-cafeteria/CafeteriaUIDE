import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promocion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PromocionService {
  static final apiUrl = dotenv.env['API_URL'];

  static Future<Map<String, dynamic>> obtenerPromocionesActivas() async {
    final url = Uri.parse("$apiUrl/api/promocion/mostrar");

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
