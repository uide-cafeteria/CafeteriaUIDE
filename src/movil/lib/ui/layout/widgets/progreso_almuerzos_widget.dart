import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class ProgresoAlmuerzoWidget extends StatelessWidget {
  final int almuerzosPagados;
  final int totalRequerido;
  final VoidCallback? onVerTarjeta;

  const ProgresoAlmuerzoWidget({
    super.key,
    required this.almuerzosPagados,
    this.totalRequerido = 10,
    this.onVerTarjeta,
  });

  @override
  Widget build(BuildContext context) {
    final progress = almuerzosPagados / totalRequerido;
    final faltan = totalRequerido - almuerzosPagados;

    return GestureDetector(
      onTap: () {
        if (onVerTarjeta != null) {
          onVerTarjeta!(); // Si tienes lógica extra
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 166, 223, 168).withOpacity(0.50),
                    const Color.fromARGB(255, 180, 233, 183).withOpacity(0.50),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tu progreso de lealtad",
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.50),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$almuerzosPagados/$totalRequerido ",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: "Almuerzos",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ver tarjeta",
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity(0.50),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textColor.withOpacity(0.50),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
