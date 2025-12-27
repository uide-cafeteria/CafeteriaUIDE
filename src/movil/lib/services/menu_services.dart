import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_del_dia.dart';

class MenuService {
  static const String baseUrl = "http://localhost:3001";

  static Future<Map<String, dynamic>> obtenerMenuDelDia() async {
    final url = Uri.parse("$baseUrl/api/menu/mostrar");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {"success": true, "menu": MenuDelDia.fromJson(body['menu'])};
      } else {
        return {
          "success": false,
          "message": body['message'] ?? "No hay menú disponible hoy",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}
