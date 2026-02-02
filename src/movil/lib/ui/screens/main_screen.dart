import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/promotions_page.dart';
import '../pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    PromotionsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_currentIndex],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 0, maxHeight: 80),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,

              // Colores (sin cambiar tamaños)
              selectedItemColor: const Color(0xFFE8A54B),
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 12,
              unselectedFontSize: 10,
              iconSize: 28,

              // Eliminar TODO efecto de selección (ripple, fondo, indicador)
              enableFeedback: false,

              // Centrado vertical de íconos respecto al label
              selectedLabelStyle: const TextStyle(
                //height: 1.0,
                //fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(height: 1.0),

              items: const [
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height:
                        40, // ← este valor es clave: más alto que el iconSize para dar espacio abajo
                    child: Align(
                      // Align en lugar de Center → más control
                      alignment: Alignment
                          .bottomCenter, // pega el ícono hacia abajo (más cerca del label)
                      child: Icon(Icons.restaurant_menu_outlined),
                    ),
                  ),
                  activeIcon: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.restaurant_menu),
                    ),
                  ),
                  label: 'Menú',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.local_offer_outlined),
                    ),
                  ),
                  activeIcon: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.local_offer),
                    ),
                  ),
                  label: 'Promociones',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.person_outline),
                    ),
                  ),
                  activeIcon: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Icon(Icons.person),
                    ),
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
