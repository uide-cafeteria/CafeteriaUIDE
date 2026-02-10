// lib/screens/verify_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/secure_storage.dart';
import '../pages/home_page.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String userId;
  final String email;

  const VerifyOtpScreen({super.key, required this.userId, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _pinController = TextEditingController();
  bool _loading = false;
  bool _canResend = true;
  int _resendCountdown = 60;

  void _verifyCode(String code) async {
    if (code.length != 6) return;

    setState(() => _loading = true);

    try {
      final String? apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      final response = await http.post(
        Uri.parse("$apiUrl/api/usuario/verificar-codigo"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.userId, 'codigo': code}),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        await SecureStorage.saveToken(data['token']);
        await SecureStorage.saveUserName(data['usuario']['username'] ?? '');
        await SecureStorage.saveCodigoUnico(
          data['usuario']['codigoUnico'] ?? '',
        );
        await SecureStorage.saveEmail(data['usuario']['correo'] ?? '');
        await SecureStorage.saveLoyaltyToken(
          data['usuario']['loyalty_token'] ?? '',
        );

        // Notificar al provider (esto actualiza el estado global)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshSession();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Verificación exitosa! Bienvenido'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegación limpiando el stack para que no puedan volver atrás
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Código incorrecto o expirado'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendCountdown = i);
    }
    if (mounted) setState(() => _canResend = true);

    try {
      final String? apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) return;

      final response = await http.post(
        Uri.parse("$apiUrl/api/usuario/registro/correo"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'reenvio',
          'correo': widget.email,
          'telefono': null,
          'contrasenia': 'dummy',
        }),
      );

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Código reenviado. Revisa tu correo.',
          ),
          backgroundColor: data['status'] == true
              ? Colors.green
              : Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reenviar código'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Código')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa el código de 6 dígitos enviado a',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFFE8A54B)),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: const Color(0xFFE8A54B).withOpacity(0.1),
                ),
              ),
              onCompleted: _verifyCode,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => _verifyCode(_pinController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A54B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Verificar Código',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _canResend ? _resendCode : null,
              child: Text(
                _canResend
                    ? 'Reenviar código'
                    : 'Reenviar en $_resendCountdown s',
                style: TextStyle(
                  color: _canResend ? const Color(0xFF2196F3) : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
