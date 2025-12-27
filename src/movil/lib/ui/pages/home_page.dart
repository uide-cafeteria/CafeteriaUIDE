// lib/pages/home_page.dart
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import '../../models/menu_del_dia.dart';
import '../../services/menu_services.dart';
import '../../config/app_theme.dart';
import '../layout/widgets/dish_card.dart'; // ← El que ya corregimos antes
import '../layout/widgets/day_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DiaSemana _selectedDay;
  MenuDelDia? _currentMenu;
  bool _isLoadingMenu = true;
  String? _menuError;

  bool _isLoggedIn = false;
  String _userName = "Invitado";
  String _codigoUnico = "";
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _getCurrentDiaSemana();
    _loadUserData();
    _loadMenu(); // Carga el menú activo del día actual
  }

  DiaSemana _getCurrentDiaSemana() {
    final weekday = DateTime.now().weekday;
    return switch (weekday) {
      1 => DiaSemana.lunes,
      2 => DiaSemana.martes,
      3 => DiaSemana.miercoles,
      4 => DiaSemana.jueves,
      5 => DiaSemana.viernes,
      _ => DiaSemana.lunes,
    };
  }

  Future<void> _loadUserData() async {
    final token = await SecureStorage.getToken();
    final name = await SecureStorage.getUserName();
    final codigoUnico = await SecureStorage.getCodigoUnico();

    setState(() {
      _isLoggedIn = token != null && name != null;
      _userName = _isLoggedIn ? name! : "Invitado";
      _codigoUnico = _isLoggedIn ? (codigoUnico ?? "") : "";
      _isLoadingUser = false;
    });
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoadingMenu = true;
      _menuError = null;
      _currentMenu = null;
    });

    final result = await MenuService.obtenerMenuDelDia();

    setState(() {
      if (result['success'] == true) {
        _currentMenu = result['menu'] as MenuDelDia;
      } else {
        _menuError = result['message'] ?? "No hay menú disponible hoy";
      }
      _isLoadingMenu = false;
    });
  }

  void _onDayChanged(DiaSemana day) {
    setState(() {
      _selectedDay = day;
    });

    // Solo recargamos el menú si el día seleccionado es hoy
    if (day == _getCurrentDiaSemana()) {
      _loadMenu(); // ← Vuelve a cargar y mostrar el menú real
    } else {
      // Para otros días: mensaje informativo
      setState(() {
        _currentMenu = null;
        _menuError = null; // Limpiamos error anterior
        _isLoadingMenu = false;
      });
    }
  }

  void _showLoginDialog() {
    Navigator.pushNamed(context, '/login');
  }

  void _logout() async {
    await SecureStorage.clearAll();
    setState(() {
      _isLoggedIn = false;
      _userName = "Invitado";
      _codigoUnico = "";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sesión cerrada"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDay == _getCurrentDiaSemana();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // === HEADER (saludo + perfil) ===
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingUser
                                ? 'Cargando...'
                                : _isLoggedIn
                                ? _userName
                                : 'Cafetería Universitaria',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (_isLoggedIn && _codigoUnico.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Text(
                                    "#",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _codigoUnico,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        offset: const Offset(0, 50),
                        child: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.15,
                          ),
                          radius: 22,
                          child: Icon(
                            _isLoggedIn ? Icons.person : Icons.person_outline,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'login') _showLoginDialog();
                          if (value == 'logout') _logout();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.grey[700]),
                                const SizedBox(width: 12),
                                Text(_isLoggedIn ? _userName : "Invitado"),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          _isLoggedIn
                              ? PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.logout, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text(
                                        "Cerrar Sesión",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                )
                              : PopupMenuItem(
                                  value: 'login',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.login,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text("Iniciar Sesión"),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // === SELECTOR DE DÍA ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday
                          ? 'Menú de hoy'
                          : 'Menú para ${_selectedDay.nombre}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DaySelector(
                      selectedDay: _selectedDay,
                      onDaySelected: _onDayChanged,
                    ),
                  ],
                ),
              ),
            ),

            // === ESTADO DEL MENÚ ===
            if (_isLoadingMenu)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (!isToday)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "El menú para ${_selectedDay.nombre}\nse publicará pronto",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_menuError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _menuError!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_currentMenu == null || _currentMenu!.productos.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.no_meals_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No hay menú disponible hoy",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF606060),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _currentMenu!.productos[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: DishCard(item: item), // ← Tu DishCard corregido
                    );
                  }, childCount: _currentMenu!.productos.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
