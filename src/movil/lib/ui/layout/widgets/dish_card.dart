import 'package:cafeteria_uide/models/menu_del_dia_producto.dart';
import 'package:flutter/material.dart';
import '../../../models/menu_del_dia.dart';
import '../../../config/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ... imports iguales (incluye cached_network_image y app_theme)

class DishCard extends StatelessWidget {
  final MenuDelDiaProducto item;
  final bool showAsMain;

  const DishCard({super.key, required this.item, this.showAsMain = false});

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    if (producto == null) return const SizedBox.shrink();

    final hasSpecialPrice = item.precioEspecial != null;
    final isPromo = item.esPromocion;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(22),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: producto.imagen != null && producto.imagen!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: producto.imagen!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.restaurant_rounded,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),

                if (showAsMain || producto.categoria == 'Almuerzo')
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                if (isPromo)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Oferta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (producto.descripcion != null &&
                      producto.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      producto.descripcion!,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasSpecialPrice)
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (hasSpecialPrice || isPromo)
                              ? AppTheme.accentColor.withOpacity(0.12)
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: (hasSpecialPrice || isPromo)
                              ? Border.all(
                                  color: AppTheme.accentColor,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Text(
                          '\$${item.precioFinal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: (hasSpecialPrice || isPromo)
                                ? AppTheme.accentColor
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
