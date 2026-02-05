// lib/pages/home_page.dart
import 'package:cafeteria_uide/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../config/app_theme.dart';
import '../../models/menu_del_dia.dart';
import '../../models/menu_del_dia_producto.dart';
import '../../services/menu_services.dart';
import '../../services/auth_service.dart'; // ← agregado para obtener nombre
import '../layout/widgets/special_dish_card.dart';
import '../layout/widgets/breakfast_dish_card.dart';
import '../layout/widgets/dish_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MenuDelDia? _menu;
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = "Usuario"; // valor por defecto

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadMenu();
  }

  Future<void> _loadUserName() async {
    final name = await SecureStorage.getUserName();
    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await MenuService.obtenerMenuDelDia();

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _menu = result['menu'] as MenuDelDia;
      } else {
        _errorMessage = result['message'] ?? "No hay menú disponible hoy";
      }
    });
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat("EEEE d 'de' MMMM", 'es');
    String formatted = formatter.format(now);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Filtrado por campo 'especial'
    final especialItem = _menu?.productos.firstWhereOrNull(
      (item) => item.producto.especial == true,
    );

    // Desayunos
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

    // Otras opciones de almuerzo
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

    final now = DateTime.now();
    final timeFormat = DateFormat("h:mm a", 'es');
    final currentTime = timeFormat.format(now);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadMenu,
        color: AppTheme.accentColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header de bienvenida ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF5D4037,
                  ), // marrón oscuro estilo "bienvenido"
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bienvenido de nuevo",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Hola, $_userName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            // TODO: ir a pantalla de notificaciones
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "ABIERTO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• Cierra a las 4:00 PM",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.90),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "UIDE Campus",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenido principal ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ESPECIAL DEL DÍA
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else if (especialItem != null)
                      SpecialDishCard(item: especialItem)
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "Especial del día no disponible",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // DESAYUNO
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                      child: Text(
                        "Desayuno",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 240,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : desayunos.isEmpty
                          ? const Center(child: Text("Sin desayunos hoy"))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              itemCount: desayunos.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                return BreakfastDishCard(
                                  item: desayunos[index],
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 36),

                    // OTRAS OPCIONES DE ALMUERZO
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Text(
                        "Otras Opciones de Almuerzo",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : otrosAlmuerzos.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text("No hay más opciones hoy"),
                            ),
                          )
                        : Column(
                            children: otrosAlmuerzos.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DishCard(item: item),
                              );
                            }).toList(),
                          ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
