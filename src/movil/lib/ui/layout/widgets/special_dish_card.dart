import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_del_dia_producto.dart'; // ← tu modelo

// SpecialDishCard.dart (versión simplificada, sin título interno)

class SpecialDishCard extends StatelessWidget {
  const SpecialDishCard({
    super.key,
    required this.item,
    this.onOrderPressed,
    this.onFavoritePressed,
    this.onTap,
  });

  final MenuDelDiaProducto item;
  final VoidCallback? onOrderPressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final String descripcion = producto.descripcion?.isNotEmpty == true
        ? producto.descripcion!
        : "Pollo a la plancha marinado en finas hierbas, "
              "acompañado de quinoa orgánica, aguacate y...";

    final String nombre = producto.nombre.isNotEmpty
        ? producto.nombre
        : "Almuerzo Ejecutivo";

    final String precioStr = "\$${item.precioFinal.toStringAsFixed(2)}";
    final String? imagenUrl = producto.imagen;

    // Rating (puedes venir del modelo después)
    const double rating = 4.2; // ← reemplaza por item.rating cuando exista

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        // Más ancha: margen horizontal reducido
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen + precio badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9, // más ancho visualmente
                  child: CachedNetworkImage(
                    imageUrl: imagenUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      precioStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + estrellas en la misma fila
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (i) {
                            final starValue = i + 1;
                            if (starValue <= rating.floor()) {
                              return const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 22,
                              );
                            } else if (starValue - 0.5 <= rating) {
                              return const Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 22,
                              );
                            } else {
                              return const Icon(
                                Icons.star_border,
                                color: Colors.grey,
                                size: 22,
                              );
                            }
                          }),
                          const SizedBox(width: 6),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onOrderPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Más Información →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: onFavoritePressed,
                        icon: const Icon(Icons.favorite_border, size: 26),
                        color: Colors.grey.shade700,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
