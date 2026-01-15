import 'package:flutter/material.dart';
import '../../../models/menu_del_dia.dart';
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
    final days = DiaSemana.values;
    final today = DateTime.now().weekday;
    final todayEnum = () {
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
    }();
    final isToday = (day) => day == todayEnum;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: days.map((day) {
          final selected = day == selectedDay;
          final todayDay = isToday(day);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onDaySelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryColor
                      : (todayDay
                            ? AppTheme.primaryColor.withOpacity(0.07)
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primaryColor
                        : (todayDay
                              ? AppTheme.accentColor
                              : Colors.grey.withOpacity(0.35)),
                    width: todayDay && !selected ? 2.4 : 1.5,
                  ),
                  boxShadow: selected || (todayDay && !selected)
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.20),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayAbbreviation(day),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : AppTheme.primaryColor.withOpacity(0.9),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (todayDay)
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Colors.white
                                : AppTheme.accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
