// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../layout/widgets/perfil_placeholder.dart';
import '../layout/widgets/promocion_almuerzos_widget.dart';
import '../../services/historial_service.dart';
import 'package:cafeteria_uide/utils/secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Cargando...";
  String _correo = "Cargando...";
  int _sellosCompletos = 0;
  String _loyaltyToken = "";
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Datos del usuario desde SecureStorage
      final name = await SecureStorage.getUserName() ?? "Usuario";
      final correo =
          await SecureStorage.getEmail() ??
          "No disponible"; // si tienes email guardado

      // 2. Progreso real desde HistorialService
      final resultado = await HistorialService.obtenerMiHistorial();

      if (resultado['success'] == true) {
        final data = resultado['data'] as Map<String, dynamic>? ?? {};
        final progreso = data['progreso'] as Map<String, dynamic>? ?? {};

        setState(() {
          _userName = name;
          _correo = correo;
          _sellosCompletos = (progreso['pagados'] as int? ?? 0) % 10;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              resultado['message'] ?? "No se pudo cargar el progreso";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error al cargar datos: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Avatar
                    ProfilePlaceholder(
                      size: 110,
                      onEditTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Editar foto de perfil"),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Nombre y correo
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _correo,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Sección de Tarjeta de Sellos Digital
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      PromocionAlmuerzosWidget(
                        sellosCompletos: _sellosCompletos,
                        loyaltyToken: _loyaltyToken,
                      ),

                    const SizedBox(height: 40),

                    // Otras opciones
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: const Text(
                              "Cerrar sesión",
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () async {
                              // Mostrar un diálogo de confirmación (opcional pero buena práctica)
                              final bool? confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Cerrar sesión"),
                                  content: const Text(
                                    "¿Estás seguro que deseas cerrar sesión?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Sí, cerrar",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar != true) return;

                              // Limpiar datos
                              await SecureStorage.logout(); // o clearAll()

                              // Redirigir y limpiar stack
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}
