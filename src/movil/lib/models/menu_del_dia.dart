// lib/models/menu_del_dia.dart
import 'menu_del_dia_producto.dart';

enum DiaSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes;

  String get nombre {
    switch (this) {
      case lunes:
        return 'Lunes';
      case martes:
        return 'Martes';
      case miercoles:
        return 'Miércoles';
      case jueves:
        return 'Jueves';
      case viernes:
        return 'Viernes';
    }
  }
}

class MenuDelDia {
  final int idMenu;
  final String nombre;
  final DiaSemana diaSemana;
  final bool activo;
  final DateTime? creadoEn;
  final List<MenuDelDiaProducto> productos;

  MenuDelDia({
    required this.idMenu,
    required this.nombre,
    required this.diaSemana,
    required this.activo,
    this.creadoEn,
    required this.productos,
  });

  factory MenuDelDia.fromJson(Map<String, dynamic> json) {
    var productosList = json['productos'] as List<dynamic>? ?? [];

    return MenuDelDia(
      idMenu: json['idMenu'] as int,
      nombre: json['nombre'] ?? 'Menú del día',
      diaSemana: _parseDiaSemana(json['dia_semana'] ?? 'Lunes'),
      activo: json['activo'] as bool? ?? false,
      creadoEn: json['creado_en'] != null
          ? DateTime.parse(json['creado_en'])
          : null,
      productos: productosList
          .map((p) => MenuDelDiaProducto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  static DiaSemana _parseDiaSemana(String dia) {
    switch (dia) {
      case 'Lunes':
        return DiaSemana.lunes;
      case 'Martes':
        return DiaSemana.martes;
      case 'Miércoles':
        return DiaSemana.miercoles;
      case 'Jueves':
        return DiaSemana.jueves;
      case 'Viernes':
        return DiaSemana.viernes;
      default:
        return DiaSemana.lunes;
    }
  }

  List<MenuDelDiaProducto> get platosPrincipales =>
      productos.where((p) => p.producto.categoria == 'Almuerzo').toList();

  List<MenuDelDiaProducto> get acompanamientos =>
      productos.where((p) => p.producto.categoria != 'Almuerzo').toList();

  List<MenuDelDiaProducto> get promociones =>
      productos.where((p) => p.esPromocion).toList();
}
