// lib/pages/home_page.dart
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import '../../models/menu_del_dia.dart';
import '../../services/menu_services.dart';
import '../../config/app_theme.dart';
import '../layout/widgets/dish_card.dart';
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
    _loadMenu();
  }

  // === LÓGICA MANTENIDA INTACTA ===
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

  Future<void> _onRefresh() async {
    // Solo recargamos si estamos viendo el día de hoy
    if (_selectedDay == _getCurrentDiaSemana()) {
      await _loadMenu();
    } else {
      // Opcional: podrías mostrar un mensaje o simplemente no hacer nada
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  void _onDayChanged(DiaSemana day) {
    setState(() {
      _selectedDay = day;
    });
    if (day == _getCurrentDiaSemana()) {
      _loadMenu();
    } else {
      setState(() {
        _currentMenu = null;
        _menuError = null;
        _isLoadingMenu = false;
      });
    }
  }

  void _logout() async {
    await SecureStorage.clearAll();
    setState(() {
      _isLoggedIn = false;
      _userName = "Invitado";
      _codigoUnico = "";
    });
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  // === WIDGETS DE UI MEJORADOS ===

  Widget _buildPromoCards() {
    final List<Map<String, dynamic>> promos = [
      {
        'title': 'Combo Almuerzo',
        'subtitle': 'Sopa + Plato Fuerte + Jugo',
        'price': '\$3.50',
        'color': AppTheme.primaryColor,
        'icon': Icons.lunch_dining,
      },
      {
        'title': 'Promo Estudiante',
        'subtitle': 'Postre gratis por tu cumple',
        'price': 'GRATIS',
        'color': Colors.orange[700],
        'icon': Icons.cake,
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 15, bottom: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [promo['color'], promo['color'].withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: promo['color'].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(promo['icon'], size: 80, color: Colors.white12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      promo['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promo['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        promo['price'],
                        style: TextStyle(
                          color: promo['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDay == _getCurrentDiaSemana();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          // Color del indicador de refresco (puedes personalizarlo)
          color: AppTheme.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // === HEADER (UX REVISADO) ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              _isLoadingUser ? 'Cargando...' : _userName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildUserMenu(),
                    ],
                  ),
                ),
              ),

              // === SECCIÓN PROMOCIONES ===
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Text(
                    "Ofertas de hoy",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPromoCards()),

              // === SELECTOR DE DÍA ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isToday
                                ? 'Menú de hoy'
                                : 'Menú para ${_selectedDay.nombre}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      DaySelector(
                        selectedDay: _selectedDay,
                        onDaySelected: _onDayChanged,
                      ),
                    ],
                  ),
                ),
              ),

              // === CONTENIDO DEL MENÚ ===
              if (_isLoadingMenu)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!isToday ||
                  _menuError != null ||
                  _currentMenu == null ||
                  _currentMenu!.productos.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(isToday))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _currentMenu!.productos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: DishCard(item: item),
                        ),
                      );
                    }, childCount: _currentMenu!.productos.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 50),
      child: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        radius: 24,
        child: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
      ),
      onSelected: (value) {
        if (value == 'login') Navigator.pushNamed(context, '/login');
        if (value == 'logout') _logout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            _userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),
        _isLoggedIn
            ? PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text("Cerrar Sesión", style: TextStyle(color: Colors.red)),
                  ],
                ),
              )
            : PopupMenuItem(
                value: 'login',
                child: Row(
                  children: const [
                    Icon(Icons.login, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 10),
                    Text("Iniciar Sesión"),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState(bool isToday) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isToday ? Icons.no_meals_outlined : Icons.event_note,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _menuError ??
                (isToday
                    ? "No hay platos disponibles por ahora"
                    : "El menú para ${_selectedDay.nombre}\nse publicará pronto"),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
