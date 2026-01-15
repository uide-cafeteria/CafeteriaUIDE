// lib/ui/screens/login_screen.dart
import 'package:cafeteria_uide/services/auth_service.dart';
import 'package:flutter/material.dart';
import '/utils/validators.dart'; // ← este import ya está bien
import '../../../config/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  final AuthService authService = AuthService();

  void _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);

    final result = await authService.login(email, password);

    setState(() => _loading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
              AppTheme.surfaceColor.withOpacity(0.92),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogoSection(),
                const SizedBox(height: 60),
                _buildFormCard(),
                const SizedBox(height: 48),
                Text(
                  'Al continuar, aceptas nuestros términos y condiciones',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomPaint(
            painter: CafeteriaLogoPainter(),
          ), // ← mantengo tu painter original
        ),
        const SizedBox(height: 20),
        Text(
          'La Cafetería',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'TU LUGAR FAVORITO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar Sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 36),

            OutlinedButton.icon(
              onPressed: _loginWithGoogle,
              icon: Icon(
                Icons.g_translate_rounded,
                color: AppTheme.primaryColor,
                size: 26,
              ),
              label: const Text(
                'Continuar con Google',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.6),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 32),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2.2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor.withOpacity(0.4),
              ),
              validator: Validators
                  .emailValidator, // ← corregido: nombre real del método
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppTheme.primaryColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2.2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor.withOpacity(0.4),
              ),
              validator:
                  Validators.passwordValidator, // ← corregido: nombre real
            ),

            const SizedBox(height: 36),

            ElevatedButton(
              onPressed: _loading ? null : _loginWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                shadowColor: AppTheme.accentColor.withOpacity(0.4),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  children: [
                    const TextSpan(text: '¿No tienes cuenta? '),
                    TextSpan(
                      text: 'Regístrate aquí',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered by ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 6),
                Image.asset('assets/images/q_powered.png', height: 24),
                const SizedBox(width: 6),
                Text(
                  'YaQbit',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromRGBO(232, 165, 75, 1),
                    fontWeight: FontWeight.w700,
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

// Mantengo tu CustomPainter original sin cambios
class CafeteriaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ... tu código original del painter ...
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
