import 'package:cafeteria_uide/models/menu_del_dia_producto.dart';
import 'package:flutter/material.dart';
import '../../../models/menu_del_dia.dart';
import '../../../config/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DishCard extends StatelessWidget {
  final MenuDelDiaProducto item;
  final bool showAsMain;

  const DishCard({super.key, required this.item, this.showAsMain = false});

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    if (producto == null) {
      return const SizedBox(); // En caso raro de que no venga el producto
    }

    final bool hasSpecialPrice = item.precioEspecial != null;
    final bool isPromo = item.esPromocion;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen del plato (desde URL del backend)
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: producto.imagen != null && producto.imagen!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: producto.imagen!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),

                // Badge Principal
                if (showAsMain || producto.categoria == 'Almuerzo')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Badge Promoción
                if (isPromo)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Oferta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Información
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (producto.descripcion != null &&
                      producto.descripcion!.isNotEmpty)
                    Text(
                      producto.descripcion!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSpecialPrice)
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasSpecialPrice || isPromo
                              ? Colors.orange[50]
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: hasSpecialPrice || isPromo
                              ? Border.all(color: Colors.orange)
                              : null,
                        ),
                        child: Text(
                          '\$${item.precioFinal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: hasSpecialPrice || isPromo
                                ? Colors.orange[700]
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
