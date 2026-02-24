// lib/ui/layout/widgets/connectivity_banner.dart
//
// Banner de conectividad con detección REAL de internet.
// - Usa connectivity_plus para detectar cambios de interfaz
// - Valida con InternetAddress.lookup para confirmar internet real
// - Funciona correctamente en emulador y dispositivo físico

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReconnect;

  const ConnectivityBanner({super.key, required this.child, this.onReconnect});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  bool _showRestoredBanner = false;
  DateTime? _disconnectedAt;
  Timer? _pollingTimer;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Escuchar cambios de interfaz de red
    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Verificar estado inicial
    _checkRealInternet();

    // Polling cada 3 segundos para detectar cambios en emulador
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkRealInternet(),
    );
  }

  // Verifica si hay internet REAL (no solo interfaz de red)
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkRealInternet() async {
    final hasInternet = await _hasRealInternet();

    if (!hasInternet && !_isOffline) {
      // Perdió internet
      _disconnectedAt = DateTime.now();
      if (mounted) {
        setState(() => _isOffline = true);
        _animationController.forward();
        debugPrint('[ConnectivityBanner] 🔴 Sin conexión detectada');
      }
    } else if (hasInternet && _isOffline) {
      // Recuperó internet
      final secondsOffline = _disconnectedAt != null
          ? DateTime.now().difference(_disconnectedAt!).inSeconds
          : 0;

      AnalyticsService().logConnectivityRestored(
        segundosDesconectado: secondsOffline,
      );

      if (mounted) {
        setState(() {
          _isOffline = false;
          _showRestoredBanner = true;
        });
        _animationController.reverse();
        widget.onReconnect?.call();

        debugPrint('[ConnectivityBanner] 🟢 Conexión restaurada');

        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() => _showRestoredBanner = false);
        });
      }
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Al cambiar la interfaz, verificamos internet real inmediatamente
    _checkRealInternet();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pollingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Banner offline (rojo)
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

        // Banner conectado (verde)
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
                        Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
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
