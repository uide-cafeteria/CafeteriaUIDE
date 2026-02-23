import 'package:cafeteria_uide/services/historial_service.dart';
import 'package:cafeteria_uide/ui/layout/widgets/categorias_menu_widget.dart';
import 'package:cafeteria_uide/ui/layout/widgets/header_welcome.dart';
import 'package:cafeteria_uide/ui/layout/widgets/horarios_widget.dart';
import 'package:cafeteria_uide/ui/layout/widgets/progreso_almuerzos_widget.dart';
import 'package:cafeteria_uide/ui/layout/widgets/promociones_home_widget.dart';
import 'package:cafeteria_uide/ui/pages/historial_page.dart';
import 'package:cafeteria_uide/ui/pages/menu_completo_page.dart';
import 'package:cafeteria_uide/ui/pages/promotions_page.dart';
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../config/app_theme.dart';
import '../../models/menu_del_dia.dart';
import '../../models/menu_del_dia_producto.dart';
import '../../services/menu_services.dart';
import '../../services/horario_atencion_service.dart';
import '../../services/analytics_service.dart';
import '../layout/widgets/special_dish_card.dart';
import '../layout/widgets/otros_productos_card.dart';
import '../layout/widgets/desayuno_plato_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Menú
  MenuDelDia? _menu;
  bool _menuLoading = true;
  String? _menuError;

  // Horarios
  bool _horariosLoading = true;
  bool _isOpen = false;
  String _closingTime = "—";
  String _locationName = "Cargando...";
  String _levelInfo = "Cafetería Principal";
  List<dynamic> _allHorarios = [];

  // Progreso de lealtad
  int _pagados = 0;
  int _totalRequerido = 10;
  bool _progresoLoading = true;
  String? _progresoError;

  String _userName = "Usuario";
  bool _isLoggedIn = false;

  // Analytics: medir tiempo de sesión en HomePage
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _checkLoginStatus();
    _loadUserName();
    _loadMenu();
    _loadHorarios();
    _loadProgresoLealtad();
    // Evento 1: menú visualizado
    AnalyticsService().logMenuViewed();
  }

  @override
  void dispose() {
    // Evento 7: tiempo de sesión en home
    if (_sessionStart != null) {
      final segundos = DateTime.now().difference(_sessionStart!).inSeconds;
      AnalyticsService().logSessionTimeOnHome(segundos: segundos);
    }
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await SecureStorage.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _loadUserName() async {
    final name = await SecureStorage.getUserName();
    if (name != null && name.isNotEmpty && mounted) {
      setState(() => _userName = name);
    }
  }

  Future<void> _loadMenu() async {
    setState(() => _menuLoading = true);
    final result = await MenuService.obtenerMenuDelDia();
    if (mounted) {
      setState(() {
        _menuLoading = false;
        if (result['success'] == true) {
          _menu = result['menu'] as MenuDelDia;
        } else {
          _menuError = result['message'] ?? "No hay menú disponible hoy";
        }
      });
    }
  }

  Future<void> _loadHorarios() async {
    final result = await HorarioAtencionService.getHorariosPublicos();

    if (!mounted) return;

    setState(() => _horariosLoading = false);

    if (result['success'] == true) {
      final horarios = result['horarios'] as List<dynamic>;
      _allHorarios = horarios;

      final now = DateTime.now();
      final diaSemana = DateFormat('EEEE', 'es_ES').format(now);
      final diaCapitalizado =
          diaSemana[0].toUpperCase() + diaSemana.substring(1);

      final horariosHoy = horarios
          .where((h) => h['dia_semana'] == diaCapitalizado)
          .toList();

      if (horariosHoy.isEmpty) {
        setState(() {
          _isOpen = false;
          _closingTime = "—";
          _locationName = "No hay horario hoy";
        });
        return;
      }

      final horarioActual = horariosHoy.firstWhere(
        (h) => _estaAbiertoAhora(h),
        orElse: () => horariosHoy.first,
      );

      final horaCierre = horarioActual['hora_cierre'] as String?;
      final ubicacion = horarioActual['ubicacion'] as String? ?? "Cafetería";

      final timeFormat = DateFormat("HH:mm", 'es');
      final closingTimeFormatted = horaCierre != null
          ? timeFormat.format(DateFormat("HH:mm:ss").parse(horaCierre))
          : "—";

      setState(() {
        _isOpen = _estaAbiertoAhora(horarioActual);
        _closingTime = closingTimeFormatted;
        _locationName = ubicacion == 'cafeteria'
            ? "Cafetería Central"
            : "Rooftop UIDE";
      });
    } else {
      setState(() {
        _isOpen = false;
        _closingTime = "—";
        _locationName = "Sin información";
      });
    }
  }

  bool _estaAbiertoAhora(Map<String, dynamic> horario) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    final aperturaStr = horario['hora_apertura'] as String?;
    final cierreStr = horario['hora_cierre'] as String?;

    if (aperturaStr == null || cierreStr == null) return false;

    final apertura = TimeOfDay(
      hour: int.parse(aperturaStr.split(':')[0]),
      minute: int.parse(aperturaStr.split(':')[1]),
    );
    final cierre = TimeOfDay(
      hour: int.parse(cierreStr.split(':')[0]),
      minute: int.parse(cierreStr.split(':')[1]),
    );

    final nowMinutes = currentTime.hour * 60 + currentTime.minute;
    final aperturaMinutes = apertura.hour * 60 + apertura.minute;
    final cierreMinutes = cierre.hour * 60 + cierre.minute;

    if (cierreMinutes < aperturaMinutes) {
      return nowMinutes >= aperturaMinutes || nowMinutes <= cierreMinutes;
    }
    return nowMinutes >= aperturaMinutes && nowMinutes <= cierreMinutes;
  }

  Future<void> _loadProgresoLealtad() async {
    // Solo cargar progreso si está logueado
    if (!_isLoggedIn) {
      setState(() {
        _progresoLoading = false;
      });
      return;
    }

    setState(() => _progresoLoading = true);

    try {
      final resultado = await HistorialService.obtenerMiHistorial();

      if (resultado['success'] == true) {
        final data = resultado['data'] as Map<String, dynamic>;
        final progreso = data['progreso'] as Map<String, dynamic>? ?? {};

        setState(() {
          _pagados = progreso['pagados'] as int? ?? 0;
          _progresoLoading = false;
        });
      } else {
        setState(() {
          _progresoError =
              resultado['message'] ?? "No se pudo cargar el progreso";
          _progresoLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _progresoError = "Error al cargar progreso: $e";
        _progresoLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final especialItem = _menu?.productos.firstWhereOrNull(
      (item) => item.producto.especial == true,
    );

    final desayunos =
        _menu?.productos
            .where(
              (item) =>
                  item.producto.categoria.toLowerCase().contains('desayuno') ||
                  item.producto.nombre.toLowerCase().contains('tigrillo') ||
                  item.producto.nombre.toLowerCase().contains('continental'),
            )
            .take(2)
            .toList() ??
        [];

    final otrosAlmuerzos =
        _menu?.productos
            .where(
              (item) =>
                  item.producto.especial != true &&
                  !item.producto.categoria.toLowerCase().contains('desayuno') &&
                  !item.producto.nombre.toLowerCase().contains('tigrillo') &&
                  !item.producto.nombre.toLowerCase().contains('continental'),
            )
            .toList() ??
        [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.cardColor,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                _loadMenu(),
                _loadHorarios(),
                if (_isLoggedIn) _loadProgresoLealtad(),
              ]);
            },
            color: AppTheme.accentColor,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header pinned
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  elevation: 4,
                  backgroundColor: AppTheme.cardColor,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 90,
                  flexibleSpace: FlexibleSpaceBar(
                    background: WelcomeHeader(
                      userName: _userName,
                      shrinkOffset: 0,
                      maxShrinkOffset: 100,
                      isLoggedIn: _isLoggedIn,
                      isCafeOpen: _isOpen, // ← de tu _loadHorarios
                      closingTime: _closingTime,
                      onLogout: () async {
                        await SecureStorage.logout(); // limpia todo el storage
                        setState(() {
                          _userName = "Usuario";
                          _isLoggedIn = false;
                          // opcional: resetear progreso u otros estados
                          _pagados = 0;
                          _progresoLoading = false;
                        });
                        // Redirige a login y reemplaza la pantalla actual
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      onLogin: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    centerTitle: false,
                  ),
                ),

                // Tarjeta de horarios
                SliverToBoxAdapter(
                  child: HorariosCardWidget(
                    isLoading: _horariosLoading,
                    isOpen: _isOpen,
                    closingTime: _closingTime,
                    locationName: _locationName,
                    levelInfo: _levelInfo,
                    allHorarios: _allHorarios,
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 15)),

                // Progreso de lealtad SOLO si está logueado
                if (_isLoggedIn)
                  SliverToBoxAdapter(
                    child: _progresoLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _progresoError != null
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _progresoError!,
                              style: TextStyle(color: Colors.red[700]),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ProgresoAlmuerzoWidget(
                            almuerzosPagados: _pagados,
                            totalRequerido: _totalRequerido,
                            onVerTarjeta: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HistorialPage(fromBottomBar: false),
                                ),
                              );
                            },
                          ),
                  ),

                // Contenido principal - Menú del día
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        if (_menuLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_menuError != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                _menuError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else ...[
                          // Menú del día
                          if (especialItem != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Menú del día",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuCompletoPage(
                                          menuProductos: _menu?.productos ?? [],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Ver todo",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // RepaintBoundary: aisla el repintado del plato especial
                            RepaintBoundary(
                              child: SpecialDishCard(item: especialItem),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // Promociones Flash
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Promociones Flash",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // RepaintBoundary: aisla repintado del widget de promociones
                          const RepaintBoundary(
                            child: PromocionesHomeWidget(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
