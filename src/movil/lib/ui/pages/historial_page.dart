// historial_page.dart (mejorado: cards con radius, sombras suaves, progress con animación implícita, colores coherentes, tipografía bold)
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:cafeteria_uide/services/historial_service.dart';
import '../../../config/app_theme.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  String _userName = "Cargando...";
  String _codigoUnico = "";
  String _loyaltyToken = "";
  int _pagados = 0;
  int _gratisObtenidos = 0;
  bool _tieneGratisHoy = false;
  bool _yaConsumioHoy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final name = await SecureStorage.getUserName() ?? "Usuario";
    final codigo = await SecureStorage.getCodigoUnico() ?? "";
    final loyaltyToken = await SecureStorage.getLoyaltyToken() ?? "";

    setState(() {
      _userName = name;
      _codigoUnico = codigo.isNotEmpty ? "#$codigo" : "#Sin código";
      _loyaltyToken = loyaltyToken;
      _isLoading = false;
    });

    try {
      final resultado = await HistorialService.obtenerMiHistorial();

      if (resultado['success'] == true) {
        final data = resultado['data'] as Map<String, dynamic>;
        final progreso = data['progreso'] as Map<String, dynamic>? ?? {};

        setState(() {
          _pagados = progreso['pagados'] as int? ?? 0;
          _gratisObtenidos = progreso['gratis_obtenidos'] as int? ?? 0;
          _tieneGratisHoy = progreso['tiene_gratis_hoy'] as bool? ?? false;
          _yaConsumioHoy = progreso['ya_consumio_hoy'] as bool? ?? false;
        });
      } else {
        final mensaje = resultado['message'] ?? "Error al cargar progreso";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.orange[700]),
        );
        setState(() {
          _pagados = 0;
          _gratisObtenidos = 0;
          _tieneGratisHoy = false;
          _yaConsumioHoy = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de red: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _pagados = 0;
        _gratisObtenidos = 0;
        _tieneGratisHoy = false;
        _yaConsumioHoy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double qrSize = MediaQuery.of(context).size.width * 0.7;
    final int faltan = _pagados % 10 == 0 ? 10 : 10 - (_pagados % 10);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Mi QR y Fidelidad"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatosUsuario,
        color: AppTheme.accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _codigoUnico,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentColor,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _loyaltyToken.isEmpty
                              ? "cargando..."
                              : "http://localhost:3000/scan-confirm?loyalty_token=$_loyaltyToken",
                          version: QrVersions.auto,
                          size: qrSize,
                          gapless: false,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _tieneGratisHoy
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: _tieneGratisHoy
                                ? Colors.green[300]!
                                : Colors.orange[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _yaConsumioHoy
                              ? "Ya consumiste hoy"
                              : _tieneGratisHoy
                              ? "¡HOY TE TOCA ALMUERZO GRATIS!"
                              : "Te faltan $faltan para tu próximo GRATIS",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _tieneGratisHoy
                                ? Colors.green[800]
                                : Colors.orange[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Progreso de Almuerzos",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: _pagados / (_pagados + faltan),
                                strokeWidth: 16,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _tieneGratisHoy
                                      ? Colors.green[600]!
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "$_pagados",
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  "de 10 pagados",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              "Pagados",
                              _pagados.toString(),
                              Colors.blue[600]!,
                            ),
                            _buildStat(
                              "Gratis",
                              _gratisObtenidos.toString(),
                              Colors.green[600]!,
                            ),
                            _buildStat(
                              "Faltan",
                              faltan.toString(),
                              Colors.orange[600]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
      ],
    );
  }
}
