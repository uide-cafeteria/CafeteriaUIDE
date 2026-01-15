import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:cafeteria_uide/services/historial_service.dart';
import 'dart:math' as math;

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage>
    with TickerProviderStateMixin {
  String _userName = "Cargando...";
  String _codigoUnico = "";
  String _loyaltyToken = "";
  int _pagados = 0;
  int _gratisObtenidos = 0;
  bool _tieneGratisHoy = false;
  bool _yaConsumioHoy = false;
  bool _isLoading = true;

  late AnimationController _qrAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _floatingController;
  late Animation<double> _qrScaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _qrAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _qrScaleAnimation = CurvedAnimation(
      parent: _qrAnimationController,
      curve: Curves.elasticOut,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    );

    _cargarDatosUsuario();
    _qrAnimationController.forward();
  }

  @override
  void dispose() {
    _qrAnimationController.dispose();
    _progressAnimationController.dispose();
    _floatingController.dispose();
    super.dispose();
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

        _progressAnimationController.forward(from: 0);
      } else {
        final mensaje = resultado['message'] ?? "Error al cargar progreso";
        _showErrorSnackBar(mensaje, Colors.orange[700]!);
        _setDefaultValues();
      }
    } catch (e) {
      _showErrorSnackBar("Error de red: $e", Colors.red);
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    setState(() {
      _pagados = 0;
      _gratisObtenidos = 0;
      _tieneGratisHoy = false;
      _yaConsumioHoy = false;
    });
  }

  void _showErrorSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double qrSize = MediaQuery.of(context).size.width * 0.6;
    final int faltan = _pagados % 10 == 0 ? 10 : 10 - (_pagados % 10);
    final double progress = _pagados % 10 / 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Fondo decorativo animado
          _buildAnimatedBackground(),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarDatosUsuario,
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Tarjeta QR
                            _buildQRCard(qrSize, faltan),
                            const SizedBox(height: 24),

                            // Tarjeta de progreso
                            _buildProgressCard(progress, faltan),
                            const SizedBox(height: 24),

                            // Estadísticas detalladas
                            _buildStatsCards(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.sin(_floatingController.value * 2 * math.pi) * 20,
                  math.cos(_floatingController.value * 2 * math.pi) * 20,
                ),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -math.sin(_floatingController.value * 2 * math.pi) * 15,
                  -math.cos(_floatingController.value * 2 * math.pi) * 15,
                ),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.green.withOpacity(0.08),
                        Colors.green.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.loyalty_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        'Mi Fidelidad',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Acumula y gana recompensas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCard(double qrSize, int faltan) {
    return ScaleTransition(
      scale: _qrScaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar y nombre
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              _userName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.15),
                    Theme.of(context).primaryColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                _codigoUnico,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _isLoading
                  ? SizedBox(
                      width: qrSize,
                      height: qrSize,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  : QrImageView(
                      data: _loyaltyToken.isEmpty
                          ? "cargando..."
                          : "http://localhost:3000/scan-confirm?loyalty_token=$_loyaltyToken",
                      version: QrVersions.auto,
                      size: qrSize,
                      gapless: false,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Theme.of(context).primaryColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black87,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Mensaje de estado
            _buildStatusBadge(faltan),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int faltan) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String message;

    if (_yaConsumioHoy) {
      bgColor = Colors.grey.withOpacity(0.15);
      textColor = Colors.grey.shade700;
      icon = Icons.check_circle_rounded;
      message = "Ya consumiste hoy";
    } else if (_tieneGratisHoy) {
      bgColor = Colors.green.withOpacity(0.15);
      textColor = Colors.green.shade700;
      icon = Icons.celebration_rounded;
      message = "¡HOY TE TOCA GRATIS!";
    } else {
      bgColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange.shade700;
      icon = Icons.local_fire_department_rounded;
      message = "Te faltan $faltan para tu próximo GRATIS";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int faltan) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _tieneGratisHoy
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      (_tieneGratisHoy
                              ? Colors.green
                              : Theme.of(context).primaryColor)
                          .withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_tieneGratisHoy
                                  ? Colors.green
                                  : Theme.of(context).primaryColor)
                              .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Progreso de Almuerzos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Barra circular animada
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final animatedProgress = progress * _progressAnimation.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: animatedProgress,
                      strokeWidth: 16,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _tieneGratisHoy
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_pagados % 10}",
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: _tieneGratisHoy
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "de 10 pagados",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Indicadores de progreso
          _buildProgressIndicators(progress),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(10, (index) {
          final isCompleted = index < (_pagados % 10);
          final isNext = index == (_pagados % 10);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isNext ? 16 : 12,
            height: isNext ? 16 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? (_tieneGratisHoy
                        ? Colors.green
                        : Theme.of(context).primaryColor)
                  : Colors.grey[300],
              border: isNext
                  ? Border.all(
                      color: _tieneGratisHoy
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      width: 2,
                    )
                  : null,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color:
                            (_tieneGratisHoy
                                    ? Colors.green
                                    : Theme.of(context).primaryColor)
                                .withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isCompleted
                ? Icon(Icons.check, size: 8, color: Colors.white)
                : null,
          );
        }),
      ),
    );
  }

  Widget _buildStatsCards() {
    final int faltan = _pagados % 10 == 0 ? 10 : 10 - (_pagados % 10);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Pagados",
            _pagados.toString(),
            Colors.blue,
            Icons.payments_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Gratis",
            _gratisObtenidos.toString(),
            Colors.green,
            Icons.celebration_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Faltan",
            faltan.toString(),
            Colors.orange,
            Icons.hourglass_empty_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
