import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../models/menu_del_dia_producto.dart';

class BreakfastDishCard extends StatelessWidget {
  final MenuDelDiaProducto item;
  final VoidCallback? onTap;

  const BreakfastDishCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen sola, redondeada por los 4 lados, SIN fondo blanco
          ClipRRect(
            borderRadius: BorderRadius.circular(
              50,
            ), // bordes redondeados por todos lados
            child: SizedBox(
              width: 180, // ancho fijo pequeño
              height: 180, // altura igual para que sea cuadrada/redondeada
              child: CachedNetworkImage(
                imageUrl: producto.imagen ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10), // espacio entre imagen y texto
          // Texto debajo, SIN fondo blanco, transparente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${item.precioFinal.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
