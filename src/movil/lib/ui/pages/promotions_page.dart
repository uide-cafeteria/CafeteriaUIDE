import 'package:cafeteria_uide/ui/layout/widgets/promotion_card.dart';
import 'package:cafeteria_uide/ui/layout/widgets/horarios_widget.dart'; // ← Añadido
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/promocion.dart';
import '../../services/promocion_service.dart';
import '../../services/horario_atencion_service.dart'; // ← Añadido
import '../../config/app_theme.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  late Future<List<Promotion>> _promotionsFuture;

  // Variables para horarios (copiadas de tu home)
  bool _horariosLoading = true;
  bool _isOpen = false;
  String _closingTime = "—";
  String _locationName = "Cargando...";
  String _levelInfo = "Cafetería Principal";
  List<dynamic> _allHorarios = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _promotionsFuture = _fetchPromotions();
    _loadHorarios(); // ← Cargamos horarios al iniciar
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

  Future<List<Promotion>> _fetchPromotions() async {
    final result = await PromocionService.obtenerPromocionesActivas();

    if (result['success'] == true) {
      return result['promociones'] as List<Promotion>;
    } else {
      throw Exception(result['message'] ?? 'Error al cargar promociones');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardColor,
      appBar: AppBar(
        title: const Text(
          'Ofertas Especiales',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _promotionsFuture = _fetchPromotions();
            _horariosLoading = true; // Recargamos horarios también
          });
          await Future.wait([_fetchPromotions(), _loadHorarios()]);
        },
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            // Widget de horarios (igual que en home)
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

            // Encabezado con texto + fueguito
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF97316),
                            const Color(0xFFFFA726),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Promociones Especiales',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de promociones
            FutureBuilder<List<Promotion>>(
              future: _promotionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _promotionsFuture = _fetchPromotions();
                            }),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final promotions = snapshot.data ?? [];

                if (promotions.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No hay promociones activas en este momento 😔',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return PromotionCard(promotion: promotions[index]);
                    }, childCount: promotions.length),
                  ),
                );
              },
            ),

            // Espacio extra al final
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
