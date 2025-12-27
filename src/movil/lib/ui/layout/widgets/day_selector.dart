import 'package:flutter/material.dart';
import '../../../models/menu_del_dia.dart'; // Importa el enum correcto
import '../../../config/app_theme.dart';

class DaySelector extends StatelessWidget {
  final DiaSemana selectedDay;
  final Function(DiaSemana) onDaySelected;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final days = DiaSemana.values; // Solo Lunes a Viernes
    final today = DateTime.now().weekday; // 1 = Lunes, 5 = Viernes

    DiaSemana todayEnum() {
      switch (today) {
        case 1:
          return DiaSemana.lunes;
        case 2:
          return DiaSemana.martes;
        case 3:
          return DiaSemana.miercoles;
        case 4:
          return DiaSemana.jueves;
        case 5:
          return DiaSemana.viernes;
        default:
          return DiaSemana.lunes;
      }
    }

    final DiaSemana todayDay = todayEnum();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = day == selectedDay;
        final isToday = day == todayDay;

        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : isToday
                    ? AppTheme.accentColor
                    : Colors.grey.withOpacity(0.3),
                width: isToday && !isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _getDayAbbreviation(day),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                if (isToday)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : AppTheme.accentColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDayAbbreviation(DiaSemana day) {
    switch (day) {
      case DiaSemana.lunes:
        return 'Lun';
      case DiaSemana.martes:
        return 'Mar';
      case DiaSemana.miercoles:
        return 'Mié';
      case DiaSemana.jueves:
        return 'Jue';
      case DiaSemana.viernes:
        return 'Vie';
    }
  }
}
