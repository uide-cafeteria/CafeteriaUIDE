import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Placeholder para logo real → reemplaza cuando lo tengas
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                // child: Image.asset('assets/images/logo_cafeteria.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Text(
                "La Cafetería",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          Icon(Icons.local_cafe_rounded, color: AppTheme.accentColor, size: 32),
        ],
      ),
    );
  }
}
