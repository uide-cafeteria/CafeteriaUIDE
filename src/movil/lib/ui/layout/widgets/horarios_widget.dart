import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';

class HorariosCardWidget extends StatelessWidget {
  final bool isLoading;
  final bool isOpen;
  final String closingTime;
  final String locationName;
  final String levelInfo;
  final List<dynamic>
  allHorarios; // ← Nueva: lista completa para el bottom sheet
  final VoidCallback? onTap; // Opcional, si quieres manejar el tap fuera

  const HorariosCardWidget({
    super.key,
    this.isLoading = false,
    this.isOpen = false,
    this.closingTime = "—",
    this.locationName = "Cargando...",
    this.levelInfo = "",
    required this.allHorarios, // Requerido para mostrar todos
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = AppTheme.primaryColor;
    final accent = AppTheme.accentColor;
    final textColor = Colors.white;
    final subtleWhite = Colors.white.withOpacity(0.92);
    final indicatorColor = isOpen
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade400;

    // Degradado bonito
    final gradientColors = isDark
        ? [primary, Color.lerp(primary, Colors.black, 0.4)!]
        : [primary, Color.lerp(primary, accent, 0.15)!];

    return GestureDetector(
      onTap: onTap ?? () => _showAllHorariosBottomSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: indicatorColor.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        isLoading
                            ? "Cargando..."
                            : (isOpen ? "ABIERTO AHORA" : "CERRADO"),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    locationName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    isOpen
                        ? "Cierra a las $closingTime • $levelInfo"
                        : "Cerrado • $levelInfo",
                    style: TextStyle(
                      color: subtleWhite,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.storefront_rounded, color: accent, size: 34),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet con TODOS los horarios
  void _showAllHorariosBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Horarios de Atención",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (allHorarios.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text("No hay horarios disponibles"),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: allHorarios.length,
                        itemBuilder: (context, index) {
                          final h = allHorarios[index];
                          final ubicacion = h['ubicacion'] == 'cafeteria'
                              ? "Cafetería"
                              : "Rooftop";
                          final dia = h['dia_semana'];
                          final apertura =
                              h['hora_apertura']?.substring(0, 5) ?? "—";
                          final cierre =
                              h['hora_cierre']?.substring(0, 5) ?? "—";
                          final estado = h['activo'] == true
                              ? "Activo"
                              : "Inactivo";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                h['activo'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: h['activo'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                "$ubicacion - $dia",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Apertura: $apertura • Cierre: $cierre",
                              ),
                              trailing: Text(
                                estado,
                                style: TextStyle(
                                  color: h['activo'] == true
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
