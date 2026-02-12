import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_del_dia_producto.dart';

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

  // ← Nueva función para mostrar el modal
  void _showDescriptionModal(BuildContext context) {
    final producto = item.producto;
    final String descripcionCompleta = producto.descripcion?.isNotEmpty == true
        ? producto.descripcion!
        : "Plato delicioso preparado con los mejores ingredientes del día. "
              "Incluye acompañamientos frescos y salsas caseras.";

    final String nombre = producto.nombre.isNotEmpty
        ? producto.nombre
        : "Almuerzo Ejecutivo";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permite que ocupe más espacio
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ListView(
              controller: scrollController,
              children: [
                // Barra superior decorativa
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                // Título
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      final val = i + 1;
                      if (val <= 4) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        );
                      } else if (val - 0.5 <= 4.2) {
                        return const Icon(
                          Icons.star_half,
                          color: Colors.amber,
                          size: 20,
                        );
                      }
                      return const Icon(
                        Icons.star_border,
                        color: Colors.grey,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: 8),
                    const Text(
                      "4.2 • Muy bueno",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Imagen (opcional, más grande)
                if (producto.imagen != null && producto.imagen!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: producto.imagen!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 24),

                // Descripción
                Text(
                  "Descripción",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descripcionCompleta,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final String descripcionCorta = producto.descripcion?.isNotEmpty == true
        ? producto.descripcion!
        : "Pollo a la plancha marinado en finas hierbas, "
              "acompañado de quinoa orgánica, aguacate y...";

    final String nombre = producto.nombre.isNotEmpty
        ? producto.nombre
        : "Almuerzo Ejecutivo";
    final String precioStr = "\$${item.precioFinal.toStringAsFixed(2)}";
    final String? imagenUrl = producto.imagen;
    const double rating = 4.2;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen + precio (sin cambios)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: imagenUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      size: 70,
                      color: Colors.grey,
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
                  Row(
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
                    descripcionCorta,
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
                          onPressed: () => _showDescriptionModal(
                            context,
                          ), // ← ¡Aquí se abre el modal!
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
