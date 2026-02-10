import 'package:cafeteria_uide/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // para elegir promociones aleatorias

class WelcomeHeader extends StatefulWidget {
  final String userName;
  final double shrinkOffset;
  final double maxShrinkOffset;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;
  final bool isCafeOpen; // ← Nuevo: si la cafetería está abierta
  final String closingTime; // ← Nuevo: hora de cierre (ej: "20:00")

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.shrinkOffset = 0,
    this.maxShrinkOffset = 100,
    this.isLoggedIn = false,
    this.onLogout,
    this.onLogin,
    this.isCafeOpen = false,
    this.closingTime = "—",
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  bool _hasSeenNotification = false; // Controla si ya vio el mensaje

  // Lista de mensajes de promociones aleatorios
  final List<String> _promoMessages = [
    "¡Nuevas promociones estudiantiles",
    "¡Oferta exclusiva! Aprovecha en La Cafeteria",
    "¡Descubre nuestras novedades! Combos nuevos",
    "¡Gracias por tu fidelidad! Recuerda canjear la promoción de almuerzos",
  ];

  void _showNotification() {
    if (_hasSeenNotification) return; // Ya lo vio, no mostrar de nuevo

    final random = Random();
    final promoText = _promoMessages[random.nextInt(_promoMessages.length)];

    final cafeMessage = widget.isCafeOpen
        ? "¡La cafetería está abierta! Cierra a las ${widget.closingTime}"
        : "La cafetería está cerrada. Vuelve mañana 😔";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "¡Notificaciones!",
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cafeMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              promoText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _hasSeenNotification = true); // Marca como visto
            },
            child: const Text(
              "Entendido",
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.shrinkOffset / widget.maxShrinkOffset).clamp(
      0.0,
      1.0,
    );
    final scale = 1.0 - (progress * 0.15);
    final opacity = 1.0 - (progress * 0.6);

    final primary = AppTheme.primaryColor;
    final textOpacity = opacity.clamp(0.7, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12 + widget.shrinkOffset.clamp(0, 40),
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: textOpacity,
        child: Transform.scale(
          scale: scale.clamp(0.92, 1.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar con menú
              GestureDetector(
                onTap: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      20,
                      kToolbarHeight + 10,
                      20,
                      0,
                    ),
                    items: [
                      if (widget.isLoggedIn)
                        PopupMenuItem(
                          value: 'logout',
                          child: const ListTile(
                            leading: Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                            ),
                            title: Text('Cerrar sesión'),
                          ),
                          onTap: widget.onLogout,
                        )
                      else
                        PopupMenuItem(
                          value: 'login',
                          child: ListTile(
                            leading: Icon(Icons.login_rounded, color: primary),
                            title: const Text('Iniciar sesión'),
                          ),
                          onTap: widget.onLogin,
                        ),
                    ],
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF69F0AE), Color(0xFF00C853)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, size: 34, color: primary),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenido de nuevo,",
                      style: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.50),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userName.isNotEmpty ? widget.userName : "Usuario",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Campanita con badge (solo si NO ha visto la notificación)
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: primary,
                      size: 30,
                    ),
                    onPressed: _showNotification,
                  ),
                  if (!_hasSeenNotification)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurRadius: 6,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
