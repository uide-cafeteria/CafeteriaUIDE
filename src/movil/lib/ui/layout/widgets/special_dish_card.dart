import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_del_dia_producto.dart'; // ← tu modelo

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

    return GestureDetector(
      onTap: onTap, // si quieres navegación al detalle al tocar toda la card
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen + precio
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
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

                // Badge precio (arriba derecha, como antes)
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
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Rating stars (por ahora estático, puedes obtenerlo del backend después)
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        const double rating =
                            3.5; // ← aquí puedes poner item.rating si lo tienes
                        final starValue = i + 1;
                        if (starValue <= rating.floor()) {
                          return const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          );
                        } else if (starValue - 0.5 <= rating) {
                          return const Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 20,
                          );
                        } else {
                          return const Icon(
                            Icons.star_border,
                            color: Colors.grey,
                            size: 20,
                          );
                        }
                      }),
                      const SizedBox(width: 8),
                      const Text(
                        '3.5',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
