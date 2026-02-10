import 'package:cafeteria_uide/config/app_theme.dart';
import 'package:cafeteria_uide/models/menu_del_dia_producto.dart';
import 'package:cafeteria_uide/ui/layout/widgets/almuerzo_plato_card.dart';
import 'package:cafeteria_uide/ui/layout/widgets/desayuno_plato_card.dart';
import 'package:cafeteria_uide/ui/layout/widgets/otros_productos_card.dart';
import 'package:flutter/material.dart';

class MenuCompletoPage extends StatefulWidget {
  final List<MenuDelDiaProducto> menuProductos;

  const MenuCompletoPage({super.key, required this.menuProductos});

  @override
  State<MenuCompletoPage> createState() => _MenuCompletoPageState();
}

class _MenuCompletoPageState extends State<MenuCompletoPage> {
  int _selectedLocation = 0; // 0 = Cafetería Main, 1 = Rooftop Lounge

  // FILTRO ALMUERZOS (solo para Cafetería Main)
  List<MenuDelDiaProducto> get almuerzos {
    return widget.menuProductos.where((item) {
      final cat = item.producto?.categoria?.toLowerCase() ?? '';
      return cat == 'almuerzo' ||
          cat == 'almuerzo ejecutivo' ||
          cat == 'ejecutivo' ||
          cat == 'balanceado';
    }).toList();
  }

  // FILTRO DESAYUNOS (solo para Cafetería Main)
  List<MenuDelDiaProducto> get desayunos {
    return widget.menuProductos.where((item) {
      final cat = item.producto?.categoria?.toLowerCase() ?? '';
      return cat == 'desayuno' ||
          cat == 'desayunos' ||
          cat == 'continental' ||
          cat == 'tigrillo';
    }).toList();
  }

  // FILTRO OTROS / POSTRES + filtro por ubicación cuando es Rooftop
  List<MenuDelDiaProducto> get otrosProductos {
    return widget.menuProductos.where((item) {
      final cat = item.producto?.categoria?.toLowerCase() ?? '';
      return cat == 'otro' ||
          cat == 'otros' ||
          cat == 'postre' ||
          cat == 'postres';
    }).toList();
  }

  // FILTRO PRODUCTOS ROOFTOP: solo ubicación rooftop
  List<MenuDelDiaProducto> get rooftopProductos {
    return widget.menuProductos.where((item) {
      final ubicacion =
          item.producto?.ubicacion?.toLowerCase() ??
          ''; // ajusta el nombre del campo si es diferente
      return ubicacion.contains('rooftop') || ubicacion.contains('lounge');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menú de Hoy',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones abiertas')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Tabs (bajan con el scroll)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 233, 233, 233),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedLocation = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedLocation == 0
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                'Cafetería',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedLocation == 0
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedLocation = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedLocation == 1
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                'Rooftop',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedLocation == 1
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contenido según tab seleccionado
                  if (_selectedLocation == 0) ...[
                    // Cafetería Main: almuerzos + desayunos + varios
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                      child: Text(
                        'Almuerzos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (almuerzos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay almuerzos disponibles hoy',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...almuerzos.map(
                        (plato) => AlmuerzoPlatoCard(
                          plato: plato,
                          onAddTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Agregado al carrito! 🛒'),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 32),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                      child: Text(
                        'Desayunos UIDE',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (desayunos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay desayunos disponibles hoy',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...desayunos.map(
                        (item) =>
                            DesayunoPlatoCard(item: item, showAsMain: false),
                      ),

                    const SizedBox(height: 32),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                      child: Text(
                        'Más Productos Varios',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (otrosProductos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay productos varios disponibles hoy',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: otrosProductos.length,
                        itemBuilder: (context, index) {
                          final item = otrosProductos[index];
                          return OtrosProductosCard(
                            item: item,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto seleccionado'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ] else ...[
                    // Rooftop Lounge: reemplaza todo con solo productos rooftop
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 16, 4, 12),
                      child: Text(
                        'Productos Rooftop',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (rooftopProductos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay productos en Rooftop Lounge hoy',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: rooftopProductos.length,
                        itemBuilder: (context, index) {
                          final item = rooftopProductos[index];
                          return OtrosProductosCard(
                            item: item,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto seleccionado'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
