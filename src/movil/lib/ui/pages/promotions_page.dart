// lib/pages/promotions_page.dart
/*
import 'package:flutter/material.dart';
import '../../models/promotion.dart';
import '../../services/menu_services.dart';
import '../../config/app_theme.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CafeteriaService();
    final activePromotions = service
        .getAllPromotions()
        .where((p) => p.isValid)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ofertas y Promociones',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: activePromotions.isEmpty
          ? _buildEmptyState()
          : _buildPromotionsList(activePromotions),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'No hay ofertas activas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Vuelve pronto! Aquí aparecerán las mejores promociones',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsList(List<Promotion> promotions) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        final promo = promotions[index];
        return _buildPromotionCard(promo);
      },
    );
  }

  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Imagen de fondo
            Image.asset(
              promo.image.isNotEmpty
                  ? promo.image
                  : 'assets/images/promo_cafe.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 70,
                  color: Colors.white70,
                ),
              ),
            ),

            // Degradado oscuro
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge de descuento
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '-${promo.discountPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título
                  Text(
                    promo.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  if (promo.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      promo.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Fecha de validez
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Válida hasta el ${promo.endDate.day} de ${_monthName(promo.endDate.month)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
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
    );
  }

  String _monthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }
}
*/
