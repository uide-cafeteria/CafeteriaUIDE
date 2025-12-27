import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ProductoService {
  static const String _baseUrl = "http://localhost:3001";

  Future<List<Producto>> obtenerProductos() async {
    final url = Uri.parse("$_baseUrl/api/producto/mostrar");

    try {
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));

      print("Status: ${response.statusCode}");
      print("Respuesta: ${response.body}"); // Para Depuración

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // buscamos la lista dentro del objeto
        List<dynamic> listaProductos = [];

        if (jsonResponse['data'] is List) {
          listaProductos = jsonResponse['data'];
        } else if (jsonResponse['productos'] is List) {
          listaProductos = jsonResponse['productos'];
        } else if (jsonResponse['result'] is List) {
          listaProductos = jsonResponse['result'];
        } else {
          if (jsonResponse is List) {
            listaProductos = jsonResponse as List;
          }
        }

        return listaProductos
            .map((json) => Producto.fromJson(json))
            .where((p) => p.activo)
            .toList();
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } catch (e) {
      print("Error en ProductoService: $e");
      throw Exception("No se pudieron cargar los productos");
    }
  }
}
