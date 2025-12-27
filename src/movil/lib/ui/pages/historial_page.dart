import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:cafeteria_uide/services/historial_service.dart';

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
    // Cargar datos locales primero (siempre se muestran)
    final name = await SecureStorage.getUserName() ?? "Usuario";
    final codigo = await SecureStorage.getCodigoUnico() ?? "";
    final loyaltyToken = await SecureStorage.getLoyaltyToken() ?? "";

    setState(() {
      _userName = name;
      _codigoUnico = codigo.isNotEmpty ? "#$codigo" : "#Sin código";
      _loyaltyToken = loyaltyToken;
      _isLoading = false; // Quitamos loading temprano para mostrar QR y nombre
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
        // Error controlado del backend
        final mensaje = resultado['message'] ?? "Error al cargar progreso";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.orange[700]),
        );
        // Valores por defecto
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
    final double qrSize = MediaQuery.of(context).size.width * 0.65;
    final int faltan = _pagados % 10 == 0 ? 10 : 10 - (_pagados % 10);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Mi QR y Fidelidad"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatosUsuario,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // === TARJETA PRINCIPAL CON QR ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Nombre y código
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _codigoUnico,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // QR GIGANTE
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
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
                      const SizedBox(height: 20),

                      // Mensaje de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _tieneGratisHoy
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _yaConsumioHoy
                              ? "Ya consumiste hoy"
                              : _tieneGratisHoy
                              ? "¡HOY TE TOCA ALMUERZO GRATIS!"
                              : "Te faltan $faltan para tu próximo GRATIS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _tieneGratisHoy
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // === PROGRESO DE FIDELIDAD ===
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Progreso de Almuerzos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Barra circular épica
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: _pagados / (_pagados + faltan),
                                strokeWidth: 14,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _tieneGratisHoy
                                      ? Colors.green
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "$_pagados",
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "de 10 pagados",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Estadísticas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              "Pagados",
                              _pagados.toString(),
                              Colors.blue,
                            ),
                            _buildStat(
                              "Gratis",
                              _gratisObtenidos.toString(),
                              Colors.green,
                            ),
                            _buildStat(
                              "Faltan",
                              faltan.toString(),
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
