import 'package:intl/intl.dart';

class Promotion {
  final int idPromocion;
  final String titulo;
  final String? descripcion;
  final String? imagen;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final double? precio;

  Promotion({
    required this.idPromocion,
    required this.titulo,
    this.descripcion,
    this.imagen,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    this.precio,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      idPromocion: json['idPromocion'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      imagen: json['imagen'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      activo: (json['activo'] as bool?) ?? true,
      precio: json['precio'] != null
          ? double.tryParse(json['precio'].toString()) ?? 0.0
          : null,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return activo && fechaInicio.isBefore(now) && fechaFin.isAfter(now);
  }

  String get formattedDateRange {
    final format = DateFormat('dd MMM', 'es');
    return 'Del ${format.format(fechaInicio)} al ${format.format(fechaFin)}';
  }

  String get formattedPrice {
    if (precio == null || precio == 0) return 'Gratis / Incluido';
    return NumberFormat.currency(locale: 'es_EC', symbol: '\$').format(precio);
  }

  @override
  String toString() {
    return 'Promotion(id: $idPromocion, título: "$titulo", precio: ${formattedPrice}, vigente: $isValid)';
  }
}
