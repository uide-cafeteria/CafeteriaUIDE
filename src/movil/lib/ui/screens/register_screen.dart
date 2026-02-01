// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../../services/register_email_service.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final RegisterEmailService _registerService = RegisterEmailService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _registerService.registerWithEmail(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      telefono: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? '¡Cuenta creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      // Como ya guardamos el token → vamos directo a home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      String errorMsg = result['message'] ?? 'Error al registrar';
      if (result['errors'] != null && (result['errors'] as List).isNotEmpty) {
        errorMsg = (result['errors'] as List).join('\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6D3), Color(0xFFEDE0D4), Color(0xFFE6D5C3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildRegisterCard(),
                  const SizedBox(height: 40),
                  const Text(
                    'Al continuar, aceptas nuestros términos y condiciones',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B7355)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6D3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(painter: CafeteriaLogoPainter()),
        ),
        const SizedBox(height: 8),
        const Text(
          'La Cafetería',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pacifico',
            color: Color(0xFF3D3D3D),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'TU LUGAR FAVORITO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: Color(0xFF3D3D3D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const SizedBox(height: 24),

            // Username
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nombre de usuario',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameCtrl,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Ingresa un nombre de usuario';
                if (value.trim().length < 3) return 'Mínimo 3 caracteres';
                return null;
              },
              decoration: _inputDecoration('usuario123'),
            ),

            const SizedBox(height: 16),

            // Email
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Correo electrónico',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.emailValidator,
              decoration: _inputDecoration('correo@ejemplo.com'),
            ),

            const SizedBox(height: 16),

            // Teléfono (opcional)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Teléfono (opcional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('0987654321'),
            ),

            const SizedBox(height: 16),

            // Contraseña
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contraseña',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Ingresa una contraseña';
                if (value.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confirmar contraseña
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Confirmar contraseña',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Confirma tu contraseña';
                if (value != _passwordCtrl.text)
                  return 'Las contraseñas no coinciden';
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón Registrarse
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A54B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(color: Color(0xFF2196F3)),
                    ),
                    TextSpan(
                      text: 'Inicia sesión',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      prefixIcon: const Icon(
        Icons.person_outline,
        color: Color(0xFF9E9E9E),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}

// ────────────────────────────────────────────────
// Reutiliza tu painter del logo (cópialo aquí o impórtalo)
class CafeteriaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ← pega aquí el mismo código que tienes en login_screen.dart
    final paint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final tablePath = Path();
    tablePath.moveTo(size.width * 0.2, size.height * 0.7);
    tablePath.lineTo(size.width * 0.8, size.height * 0.7);
    tablePath.moveTo(size.width * 0.25, size.height * 0.7);
    tablePath.lineTo(size.width * 0.2, size.height * 0.95);
    tablePath.moveTo(size.width * 0.75, size.height * 0.7);
    tablePath.lineTo(size.width * 0.8, size.height * 0.95);
    canvas.drawPath(tablePath, paint);

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.45, 20, 20),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.4, 22, 22),
      paint,
    );

    final vaporPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final vaporPath = Path();
    vaporPath.moveTo(size.width * 0.55, size.height * 0.35);
    vaporPath.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.25,
      size.width * 0.55,
      size.height * 0.15,
    );
    canvas.drawPath(vaporPath, vaporPaint);

    final plantPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.25),
      plantPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.2),
      5,
      plantPaint..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.22),
      4,
      plantPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
