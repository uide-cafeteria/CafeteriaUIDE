import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../config/app_theme.dart';

class PromocionAlmuerzosWidget extends StatefulWidget {
  final int sellosCompletos;
  final String loyaltyToken;

  const PromocionAlmuerzosWidget({
    super.key,
    required this.sellosCompletos,
    required this.loyaltyToken,
  });

  @override
  State<PromocionAlmuerzosWidget> createState() =>
      _PromocionAlmuerzosWidgetState();
}

class _PromocionAlmuerzosWidgetState extends State<PromocionAlmuerzosWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    const int totalSellos = 10;
    final double progress = widget.sellosCompletos / totalSellos;

    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final isFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _flipAnimation.value > 0.5
                        ? AppTheme.accentColor.withOpacity(
                            0.6 * _flipAnimation.value,
                          )
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: _flipAnimation.value > 0.5 ? 8 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isFront
                  ? _buildFront(progress, totalSellos)
                  : _buildBack(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(double progress, int totalSellos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "¡Casi listo para tu almuerzo gratis!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Toca para ver tu código QR",
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.accentColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Grid de sellos (igual que antes)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: totalSellos,
          itemBuilder: (context, index) {
            final bool completado = index < widget.sellosCompletos;

            if (index == totalSellos - 1) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completado ? AppTheme.accentColor : Colors.grey[100],
                  border: completado
                      ? null
                      : Border.all(color: AppTheme.accentColor, width: 2),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: completado
                      ? Colors.white
                      : AppTheme.accentColor.withOpacity(0.6),
                  size: 32,
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completado ? AppTheme.accentColor : null,
                border: completado
                    ? null
                    : Border.all(color: AppTheme.accentColor, width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  color: completado ? Colors.white : AppTheme.accentColor,
                  size: 28,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Progreso de almuerzo",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              "${widget.sellosCompletos} de $totalSellos sellos",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi), // corrige el espejo
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Tu código QR",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: widget.loyaltyToken.isEmpty
                ? const SizedBox(
                    width: 180,
                    height: 180,
                    child: Center(
                      child: Text(
                        "No hay código QR disponible",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : QrImageView(
                    data:
                        "http://localhost:3000/scan-confirm?loyalty_token=${widget.loyaltyToken}",
                    version: QrVersions.auto,
                    size: 180,
                    gapless: false,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.primaryColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black87,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Escanea en caja para sumar puntos",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: _toggleFlip,
            child: const Text(
              "Volver",
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
