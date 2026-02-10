import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../pages/home_page.dart';
import '../pages/promotions_page.dart';
import '../pages/historial_page.dart';
import '../../config/app_theme.dart';
import '../pages/catering_page.dart';
import '../pages/profile_page.dart';
import '../../utils/secure_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // bool _isLoggedIn = false; // Ya no usamos estado local

  @override
  void initState() {
    super.initState();
    // No necesitamos _checkLoginStatus() aquí porque usaremos el AuthProvider
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const PromotionsPage();
      case 2:
        if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
          return const HistorialPage();
        }
        return const HomePage(); // fallback si no está logueado
      case 3:
        if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
          return const CateringPage();
        }
        return const HomePage(); // fallback
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ítems dinámicos según si está logueado
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.local_offer_outlined),
        activeIcon: Icon(Icons.local_offer),
        label: 'Promociones',
      ),
    ];

    // Solo agregar Historial y Catering si está logueado
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Historial',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Catering',
        ),
      ]);
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: _buildPage(_currentIndex)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.clamp(
          0,
          items.length - 1,
        ), // evita índices inválidos
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.black54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 26,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 8,
        items: items,
      ),
    );
  }
}
