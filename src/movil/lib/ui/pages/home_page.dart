// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../config/app_theme.dart';
import '../../models/menu_del_dia.dart';
import '../../models/menu_del_dia_producto.dart';
import '../../services/menu_services.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMenu();
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
    // Filtrado por campo 'especial' (ideal si tu BD lo usa correctamente)
    final especialItem = _menu?.productos.firstWhereOrNull(
      (item) => item.producto.especial == true,
    );

    // Desayunos: por categoría o nombre (ajusta si tienes categoría exacta)
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

    // Otras opciones de almuerzo: el resto que no sea desayuno ni especial
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Menú Diario UIDE",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _getFormattedDate(), // tu función que devuelve "Lunes, 12 de Junio"
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMenu,
        color: AppTheme.accentColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ESPECIAL DEL DÍA (grande)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // DESAYUNO
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: const Text(
                  "Desayuno",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: desayunos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            child: BreakfastDishCard(item: desayunos[index]),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 36),

              // OTRAS OPCIONES DE ALMUERZO
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: const Text(
                  "Otras Opciones de Almuerzo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : otrosAlmuerzos.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text("No hay más opciones hoy")),
                      )
                    : Column(
                        children: otrosAlmuerzos.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DishCard(item: item),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
