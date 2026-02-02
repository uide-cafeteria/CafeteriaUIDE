// lib/services/register_email_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class RegisterEmailService {
  static const String baseUrl =
      "http://api-cafeteria.uidehub.tech"; // ← cámbialo a tu URL real en producción

  /// Registra un nuevo usuario con correo
  /// Campos obligatorios: username, correo, contraseña
  /// telefono es opcional
  Future<Map<String, dynamic>> registerWithEmail({
    required String username,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final url = Uri.parse("$baseUrl/api/usuario/registro/correo");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "correo": email.trim().toLowerCase(),
          "contrasenia": password,
          if (telefono != null && telefono.trim().isNotEmpty)
            "telefono": telefono.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Éxito - el backend devuelve token y usuario
        final token = responseData['token'];
        final usuario = responseData['usuario'];

        if (token == null || usuario == null) {
          return {
            "success": false,
            "message":
                "Respuesta inválida del servidor (falta token o usuario)",
          };
        }

        // Guardamos todo en secure storage (igual que en login)
        await SecureStorage.saveToken(token);
        await SecureStorage.saveUserName(usuario['username'] ?? '');
        await SecureStorage.saveEmail(usuario['correo'] ?? email);
        await SecureStorage.saveCodigoUnico(usuario['codigoUnico'] ?? '');

        // loyalty_token puede ser null en teoría, pero tu backend siempre lo genera
        final loyaltyToken = usuario['loyalty_token']?.toString();
        if (loyaltyToken != null && loyaltyToken.isNotEmpty) {
          await SecureStorage.saveLoyaltyToken(loyaltyToken);
        }

        return {
          "success": true,
          "message": responseData['message'] ?? "Cuenta creada con éxito",
          "token": token,
          "usuario": usuario,
        };
      }

      // ── Errores esperados ────────────────────────────────────────
      if (response.statusCode == 400) {
        // Errores de validación (express-validator)
        final errores =
            (responseData['errores'] as List?)?.cast<String>() ?? [];
        return {
          "success": false,
          "message": errores.isNotEmpty
              ? errores.join("\n")
              : "Datos inválidos",
          "errors": errores,
        };
      }

      if (response.statusCode == 409) {
        // Conflicto: correo o teléfono ya existe
        return {
          "success": false,
          "message":
              responseData['message'] ??
              "El correo o teléfono ya está registrado",
        };
      }

      if (response.statusCode == 500) {
        return {
          "success": false,
          "message": responseData['message'] ?? "Error interno del servidor",
        };
      }

      // Cualquier otro código de error
      return {
        "success": false,
        "message":
            responseData['message'] ??
            "Error inesperado (${response.statusCode})",
      };
    } catch (e) {
      return {
        "success": false,
        "message":
            "No se pudo conectar con el servidor.\nVerifica tu conexión.",
        "error": e.toString(),
      };
    }
  }
}
