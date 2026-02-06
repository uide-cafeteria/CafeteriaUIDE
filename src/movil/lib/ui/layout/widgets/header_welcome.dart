// lib/layout/widgets/welcome_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../services/horario_atencion_service.dart';

class WelcomeHeader extends StatefulWidget {
  final String userName;

  const WelcomeHeader({super.key, required this.userName});

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  bool _isLoading = true;
  bool _isOpen = false;
  String _closingTime = "—";
  String _locationName = "Cargando...";
  String _errorMessage = "";
  List<dynamic> _allHorarios = []; // para mostrar en el bottom sheet

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    final service = HorarioAtencionService();
    final result = await HorarioAtencionService.getHorariosPublicos();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      final horarios = result['horarios'] as List<dynamic>;
      _allHorarios = horarios;

      // Día actual en español
      final now = DateTime.now();
      final diaSemana = DateFormat('EEEE', 'es_ES').format(now);
      final diaCapitalizado =
          diaSemana[0].toUpperCase() + diaSemana.substring(1);

      // Horarios de hoy
      final horariosHoy = horarios.where((h) {
        return h['dia_semana'] == diaCapitalizado;
      }).toList();

      if (horariosHoy.isEmpty) {
        setState(() {
          _isOpen = false;
          _closingTime = "—";
          _locationName = "No hay horario hoy";
        });
        return;
      }

      // Tomamos uno representativo (el primero que esté abierto, o el primero)
      final horarioActual = horariosHoy.firstWhere(
        (h) => _estaAbiertoAhora(h),
        orElse: () => horariosHoy.first,
      );

      final horaCierre = horarioActual['hora_cierre'] as String?;
      final ubicacion = horarioActual['ubicacion'] as String? ?? "Cafetería";

      final timeFormat = DateFormat("h:mm a", 'es');
      final closingTimeFormatted = horaCierre != null
          ? timeFormat.format(DateFormat("HH:mm:ss").parse(horaCierre))
          : "—";

      final isOpenNow = _estaAbiertoAhora(horarioActual);

      setState(() {
        _isOpen = isOpenNow;
        _closingTime = closingTimeFormatted;
        _locationName = ubicacion == 'cafeteria'
            ? "Cafetería UIDE"
            : "Rooftop UIDE";
      });
    } else {
      setState(() {
        _errorMessage =
            result['message'] ?? "No se pudieron cargar los horarios";
        _isOpen = false;
        _closingTime = "—";
        _locationName = "Sin información";
      });
    }
  }

  bool _estaAbiertoAhora(Map<String, dynamic> horario) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    final aperturaStr = horario['hora_apertura'] as String?;
    final cierreStr = horario['hora_cierre'] as String?;

    if (aperturaStr == null || cierreStr == null) return false;

    final apertura = TimeOfDay(
      hour: int.parse(aperturaStr.split(':')[0]),
      minute: int.parse(aperturaStr.split(':')[1]),
    );

    final cierre = TimeOfDay(
      hour: int.parse(cierreStr.split(':')[0]),
      minute: int.parse(cierreStr.split(':')[1]),
    );

    final nowMinutes = currentTime.hour * 60 + currentTime.minute;
    final aperturaMinutes = apertura.hour * 60 + apertura.minute;
    final cierreMinutes = cierre.hour * 60 + cierre.minute;

    if (cierreMinutes < aperturaMinutes) {
      return nowMinutes >= aperturaMinutes || nowMinutes <= cierreMinutes;
    }

    return nowMinutes >= aperturaMinutes && nowMinutes <= cierreMinutes;
  }

  void _showHorariosBottomSheet() {
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
                  if (_allHorarios.isEmpty)
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
                        itemCount: _allHorarios.length,
                        itemBuilder: (context, index) {
                          final h = _allHorarios[index];
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showHorariosBottomSheet, // ← al tocar abre el bottom sheet
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenido de nuevo",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Hola, ${widget.userName.isNotEmpty ? widget.userName : 'Usuario'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // notificaciones
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isOpen
                            ? Colors.greenAccent[400]
                            : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    _isLoading
                        ? "Cargando..."
                        : (_isOpen ? "ABIERTO" : "CERRADO"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLoading
                        ? ""
                        : (_isOpen
                              ? "• Cierra a las $_closingTime"
                              : "• Cerrado"),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _locationName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
