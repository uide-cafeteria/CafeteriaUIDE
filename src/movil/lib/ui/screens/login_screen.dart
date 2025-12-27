import 'package:cafeteria_uide/services/auth_service.dart';
import 'package:flutter/material.dart';
import '/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // AÑADIDO
  bool _loading = false;
  bool _obscurePassword = true; // AÑADIDO

  final AuthService authService = AuthService();

  void _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);

    final result = await authService.login(email, password);

    setState(() => _loading = false);

    if (result['success']) {
      // Login exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Error del servidor o credenciales
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Credenciales incorrectas'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login con Google próximamente')),
    );
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
                  _buildLoginCard(),
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

  Widget _buildLoginCard() {
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
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),

            const SizedBox(height: 24),

            OutlinedButton(
              onPressed: _loginWithGoogle,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Campo de correo electrónico
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
              decoration: InputDecoration(
                hintText: 'correo@correo.com',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: Color(0xFF9E9E9E),
                  size: 20,
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

            // CAMPO DE CONTRASEÑA AÑADIDO AQUÍ
            const SizedBox(height: 16),
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
                  return 'Ingresa tu contraseña';
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

            // Botón "Continuar con correo"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loginWithEmail,
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
                        'Continuar con correo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: TextStyle(color: Color(0xFF2196F3)),
                    ),
                    TextSpan(
                      text: 'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
            ),

            //Powered by
            const SizedBox(height: 20), // un poco de separación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered by ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset('assets/images/q_powered.png', height: 20),
                const SizedBox(width: 4),
                Text(
                  'YaQbit', // Cambia esto por lo que quieras
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(
                      232,
                      165,
                      75,
                      1,
                    ), // mismo dorado que el botón principal
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// El painter del logo queda exactamente igual
class CafeteriaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
