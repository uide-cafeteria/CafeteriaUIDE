// lib/models/menu_del_dia_producto.dart
import 'producto.dart';

class MenuDelDiaProducto {
  final double? precioEspecial;
  final bool esPromocion;
  final Producto producto;

  MenuDelDiaProducto({
    this.precioEspecial,
    this.esPromocion = false,
    required this.producto,
  });

  double get precioFinal => precioEspecial ?? producto.precio;

  factory MenuDelDiaProducto.fromJson(Map<String, dynamic> json) {
    final relacion = json['menu_del_dia_productos'] as Map<String, dynamic>?;

    return MenuDelDiaProducto(
      precioEspecial: relacion?['precio_especial'] is num
          ? (relacion!['precio_especial'] as num).toDouble()
          : null,
      esPromocion: relacion?['es_promocion'] as bool? ?? false,
      producto: Producto.fromJson(json),
    );
  }
}
