// lib/pages/home_page.dart
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/menu_del_dia.dart';
import '../../models/promocion.dart';
import '../../services/menu_services.dart';
import '../../services/promocion_service.dart';
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

  // Promociones
  List<Promotion> _promotions = [];
  bool _isLoadingPromos = true;
  String? _promosError;

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
    _loadPromotions();
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

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoadingPromos = true;
      _promosError = null;
    });

    final result = await PromocionService.obtenerPromocionesActivas();

    setState(() {
      if (result['success'] == true) {
        _promotions = result['promociones'] as List<Promotion>;
      } else {
        _promosError = result['message'] ?? "No hay promociones activas";
      }
      _isLoadingPromos = false;
    });
  }

  Future<void> _onRefresh() async {
    // Recargamos todo lo que corresponda
    await Future.wait([
      if (_selectedDay == _getCurrentDiaSemana()) _loadMenu(),
      _loadPromotions(),
    ]);
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

  // === SECCIÓN PROMOCIONES DINÁMICA ===
  Widget _buildPromotionsSection() {
    if (_isLoadingPromos) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_promosError != null || _promotions.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            _promosError ?? "Sin ofertas por ahora",
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          return HomePromotionCard(promotion: _promotions[index]);
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
          color: AppTheme.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // === HEADER ===
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ofertas y Promociones",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPromotionsSection()),

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

// Widget para tarjeta de promoción en Home (estilo similar a PromotionsPage pero más compacto)
class HomePromotionCard extends StatelessWidget {
  final Promotion promotion;

  const HomePromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final start = dateFormat.format(promotion.fechaInicio);
    final end = dateFormat.format(promotion.fechaFin);

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            CachedNetworkImage(
              imageUrl:
                  promotion.imagen ??
                  'https://via.placeholder.com/500x280?text=Promo',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[400],
                child: const Icon(
                  Icons.local_offer,
                  size: 60,
                  color: Colors.white70,
                ),
              ),
            ),

            // Degradado inferior
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Oferta Activa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    promotion.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (promotion.descripcion != null &&
                      promotion.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      promotion.descripcion!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${promotion.precio}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$start - $end',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
