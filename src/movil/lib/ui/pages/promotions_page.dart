// promotions_page.dart (mejorado: appbar más moderna, error states visuales, cards con más sombra y tipografía jerárquica)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/promocion.dart';
import '../../services/promocion_service.dart';
import '../../../config/app_theme.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  late Future<List<Promotion>> _promotionsFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _promotionsFuture = _fetchPromotions();
  }

  Future<List<Promotion>> _fetchPromotions() async {
    final result = await PromocionService.obtenerPromocionesActivas();

    if (result['success'] == true) {
      return result['promociones'] as List<Promotion>;
    } else {
      throw Exception(result['message'] ?? 'Error al cargar promociones');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Ofertas y Promociones',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.primaryColor,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _promotionsFuture = _fetchPromotions();
          });
        },
        color: AppTheme.accentColor,
        backgroundColor: AppTheme.cardColor,
        child: FutureBuilder<List<Promotion>>(
          future: _promotionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 100,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Ups! Algo salió mal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _promotionsFuture = _fetchPromotions();
                      }),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ],
                ),
              );
            }

            final promotions = snapshot.data ?? [];

            if (promotions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 120,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No hay promociones activas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        '¡Vuelve pronto! Estamos preparando ofertas irresistibles para ti',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                return PromotionCard(promotion: promotions[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

// PromotionCard (pulido: radius más suave, sombras, tipografía con sombras para legibilidad)
class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final startDate = dateFormat.format(promotion.fechaInicio);
    final endDate = dateFormat.format(promotion.fechaFin);

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  promotion.imagen ??
                  'https://via.placeholder.com/600x400?text=Promoción+Sin+Imagen',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceColor,
                child: const Icon(
                  Icons.local_offer_rounded,
                  size: 100,
                  color: Colors.white70,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '¡Oferta Activa!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    promotion.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black54,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (promotion.descripcion != null &&
                      promotion.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      promotion.descripcion!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 22,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Válida del $startDate al $endDate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
