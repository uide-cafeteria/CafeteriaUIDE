import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/promocion.dart';
import '../../../services/promocion_service.dart';
import '../../../config/app_theme.dart';

class PromocionesHomeWidget extends StatelessWidget {
  const PromocionesHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: PromocionService.obtenerPromocionesActivas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?['success'] != true) {
          return const SizedBox.shrink();
        }

        final List<Promotion> promos = snapshot.data!['promociones'] ?? [];
        final validPromos = promos.where((p) => p.isValid).toList();

        if (validPromos.isEmpty) {
          return const SizedBox.shrink();
        }

        // Si solo hay una promoción, mostramos directamente sin PageView
        if (validPromos.length == 1) {
          return _buildPromoCard(validPromos.first);
        }

        // Si hay varias → usamos PageView con snap y algo de padding para ver el siguiente
        return SizedBox(
          height: 90,
          child: PageView.builder(
            itemCount: validPromos.length,
            padEnds: false,
            controller: PageController(
              viewportFraction: 0.92, // deja ver un poquito del siguiente card
              initialPage: 0,
            ),
            itemBuilder: (context, index) {
              final promo = validPromos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPromoCard(promo),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPromoCard(Promotion promo) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // Imagen a la derecha con esquina superior izquierda grande
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 130,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: promo.imagen ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                      child: const Icon(
                        Icons.local_offer_outlined,
                        color: Colors.white54,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenido de texto
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 130, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promo.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    promo.descripcion ?? "Oferta disponible",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    promo.formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
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
