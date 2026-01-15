import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/promocion.dart';
import '../../../config/app_theme.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final startDate = dateFormat.format(promotion.fechaInicio);
    final endDate = dateFormat.format(promotion.fechaFin);

    return GestureDetector(
      onTap: () {
        // Opcional: puedes abrir un detalle o mostrar SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promoción: ${promotion.titulo}')),
        );
      },
      child: Container(
        width: 280, // Ancho ideal para horizontal scroll o grid
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo (desde tu API)
              CachedNetworkImage(
                imageUrl:
                    promotion.imagen ??
                    'https://via.placeholder.com/600x400?text=Promoción+Sin+Imagen',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.local_offer_rounded,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),

              // Degradado oscuro en la parte inferior para legibilidad
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.80),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),

              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Badge promocional
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316), // Naranja vibrante
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Oferta Activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título
                    Text(
                      promotion.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (promotion.descripcion != null &&
                        promotion.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        promotion.descripcion!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Fechas de vigencia
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Válida del $startDate al $endDate',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
