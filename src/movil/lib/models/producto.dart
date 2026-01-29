// lib/models/producto.dart
class Producto {
  final int idProducto;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagen;
  final bool especial;
  final String categoria;
  final bool activo;

  Producto({
    required this.idProducto,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagen,
    required this.especial,
    required this.categoria,
    required this.activo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    double parsedPrecio = 0.0;
    if (json['precio'] is String) {
      parsedPrecio = double.tryParse(json['precio']) ?? 0.0;
    } else if (json['precio'] is num) {
      parsedPrecio = (json['precio'] as num).toDouble();
    }

    return Producto(
      idProducto: json['idProducto'] as int,
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      precio: parsedPrecio,
      imagen: json['imagen'],
      especial: json['especial'] ?? false,
      categoria: json['categoria'] ?? 'Otro',
      activo: json['activo'] ?? true,
    );
  }
}
