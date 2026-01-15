// home_page.dart (mejorado: slivers más fluidos, secciones con padding, textos con jerarquía, promos cards pulidas, error states visuales)
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

  Widget _buildPromotionsSection() {
    if (_isLoadingPromos) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_promosError != null || _promotions.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            _promosError ?? "Sin ofertas por ahora",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
    final theme = Theme.of(context);

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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (_isLoggedIn)
                        IconButton(
                          icon: Icon(
                            Icons.logout_rounded,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                          onPressed: _logout,
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: DaySelector(
                  selectedDay: _selectedDay,
                  onDaySelected: _onDayChanged,
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              if (_isLoadingMenu)
                const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                    ),
                  ),
                )
              else if (_currentMenu != null && isToday) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Menú del Día',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _currentMenu!.productos[index];
                    return DishCard(
                      item: item,
                      showAsMain:
                          item.producto?.categoria == 'Almuerzo' ?? false,
                    );
                  }, childCount: _currentMenu!.productos.length),
                ),
              ] else
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          isToday
                              ? Icons.no_meals_outlined
                              : Icons.event_note_outlined,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _menuError ??
                              (isToday
                                  ? "No hay platos disponibles por ahora"
                                  : "El menú para ${_selectedDay.nombre}\nse publicará pronto"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Promociones Activas',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildPromotionsSection()),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// HomePromotionCard (pulido: shadows, tipografía, gradiente suave)
class HomePromotionCard extends StatelessWidget {
  final Promotion promotion;

  const HomePromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final start = dateFormat.format(promotion.fechaInicio);
    final end = dateFormat.format(promotion.fechaFin);

    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      margin: const EdgeInsets.only(right: 20, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  promotion.imagen ??
                  'https://via.placeholder.com/500x280?text=Promo',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppTheme.surfaceColor),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceColor,
                child: const Icon(
                  Icons.local_offer_rounded,
                  size: 70,
                  color: Colors.white70,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Text(
                      'Oferta Activa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    promotion.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (promotion.descripcion != null &&
                      promotion.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      promotion.descripcion!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${promotion.precio}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$start - $end',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 14,
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
