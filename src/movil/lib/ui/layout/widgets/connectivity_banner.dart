// lib/ui/layout/widgets/connectivity_banner.dart
//
// Banner de conectividad con detección de red en tiempo real.
// Features:
//   - Banner rojo animado cuando no hay internet
//   - Banner verde al recuperar conexión (se oculta solo)
//   - Reconexión automática via callback
//   - Loguea evento 'connectivity_restored' en Analytics

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReconnect;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.onReconnect,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  bool _showRestoredBanner = false;
  DateTime? _disconnectedAt;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Escuchar cambios de conectividad
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);

    // Verificar estado inicial
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    _handleConnectivityChange(result);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasConnection && !_isOffline) {
      // Acaba de perder conexión
      _disconnectedAt = DateTime.now();
      if (mounted) {
        setState(() => _isOffline = true);
        _animationController.forward();
      }
    } else if (hasConnection && _isOffline) {
      // Recuperó conexión
      final secondsOffline = _disconnectedAt != null
          ? DateTime.now().difference(_disconnectedAt!).inSeconds
          : 0;

      // Loguear evento de analítica
      AnalyticsService().logConnectivityRestored(
        segundosDesconectado: secondsOffline,
      );

      if (mounted) {
        setState(() {
          _isOffline = false;
          _showRestoredBanner = true;
        });
        _animationController.reverse();

        // Reconexión automática
        widget.onReconnect?.call();

        // Ocultar banner verde tras 2.5 segundos
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() => _showRestoredBanner = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Banner offline (rojo) - desliza desde arriba
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 4,
                child: Container(
                  color: const Color(0xFFD32F2F),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: const SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sin conexión — Mostrando datos guardados',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Banner conectado (verde) - aparece brevemente
        if (_showRestoredBanner && !_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showRestoredBanner ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Material(
                elevation: 4,
                child: Container(
                  color: const Color(0xFF388E3C),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: const SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Conexión restaurada ✓',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
