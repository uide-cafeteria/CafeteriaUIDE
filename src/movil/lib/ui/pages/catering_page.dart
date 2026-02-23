// lib/pages/catering_page.dart
import 'package:cafeteria_uide/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/catering_service.dart';
import '../../services/analytics_service.dart';

class CateringPage extends StatefulWidget {
  const CateringPage({super.key});

  @override
  State<CateringPage> createState() => _CateringPageState();
}

class _CateringPageState extends State<CateringPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notasController = TextEditingController();
  final _cantidadController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String? _tipoEventoSeleccionado;

  final List<String> _tiposEvento = [
    "Cumpleaños",
    "Reunión académica",
    "Evento corporativo",
    "Taller / Capacitación",
    "Conferencia",
    "Graduación",
    "Otro",
  ];

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Evento 3: Formulario de catering iniciado
    AnalyticsService().logCateringFormStarted();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().add(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5D4037),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = picked);
      print("Fecha seleccionada: ${DateFormat('yyyy-MM-dd').format(picked)}");
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF5D4037)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _horaSeleccionada) {
      setState(() => _horaSeleccionada = picked);
      print(
        "Hora seleccionada: ${picked.hour}:${picked.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) {
      print("Formulario inválido - no se envía");
      return;
    }

    print("=== INICIO ENVÍO DE SOLICITUD ===");
    print("Nombre: ${_nombreController.text.trim()}");
    print("Correo: ${_correoController.text.trim()}");
    print("Teléfono: ${_telefonoController.text.trim()}");
    print("Tipo evento: $_tipoEventoSeleccionado");

    final fechaStr = _fechaSeleccionada != null
        ? DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!)
        : null;
    print("Fecha evento: $fechaStr");

    final horaStr = _horaSeleccionada != null
        ? "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}:00"
        : null;
    print("Hora evento: $horaStr");

    print("Cantidad personas: ${_cantidadController.text.trim()}");
    print("Descripción: ${_notasController.text.trim()}");

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    final result = await CateringService.crearSolicitud(
      nombreCompleto: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      fechaEvento: fechaStr!,
      horaEvento: horaStr,
      tipoEvento: _tipoEventoSeleccionado!,
      cantidadPersonas: int.tryParse(_cantidadController.text.trim()),
      descripcion: _notasController.text.trim().isNotEmpty
          ? _notasController.text.trim()
          : null,
    );

    print("=== RESPUESTA DEL SERVICE ===");
    print("Success: ${result['success']}");
    print("Message: ${result['message']}");
    print("Full result: $result");

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Evento 4: Formulario de catering enviado con éxito
      AnalyticsService().logCateringFormSubmitted(
        tipoEvento: _tipoEventoSeleccionado ?? 'desconocido',
        cantidadPersonas: int.tryParse(_cantidadController.text.trim()),
      );
      setState(() => _successMessage = result['message']);
      _formKey.currentState!.reset();
      _nombreController.clear();
      _correoController.clear();
      _telefonoController.clear();
      _cantidadController.clear();
      _notasController.clear();
      setState(() {
        _fechaSeleccionada = null;
        _horaSeleccionada = null;
        _tipoEventoSeleccionado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage!),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _errorMessage = result['message']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    }

    print("=== FIN ENVÍO DE SOLICITUD ===\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con imagen y overlay más opaco/plomo-café suave
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1555244162-803834f70033?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(
                            0xCC4A2C1F,
                          ), // café muy opaco / plomo oscuro suave
                        ],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text("★ Servicio Premium"),
                          backgroundColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Servicio de Catering UIDE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Organizamos tus eventos con la mejor calidad culinaria",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber[700],
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Las solicitudes deben realizarse con al menos 48 horas de anticipación para garantizar disponibilidad.",
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detalles del Evento",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: _buildDateField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTimeField()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: _tipoEventoSeleccionado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Tipo de evento",
                            labelStyle: const TextStyle(
                              color: Color(0xFF5D4037),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF5D4037),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _tiposEvento.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _tipoEventoSeleccionado = value),
                          validator: (value) => value == null
                              ? "Selecciona un tipo de evento"
                              : null,
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Número de asistentes",
                            hintText: "Ej: 25",
                            prefixIcon: const Icon(
                              Icons.group,
                              color: Color(0xFF5D4037),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            final n = int.tryParse(value);
                            if (n == null || n <= 0) return "Número válido";
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          "Información de Contacto",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Nombre del solicitante",
                            hintText: "Tu nombre completo",
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF5D4037),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty ?? true ? "Obligatorio" : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            hintText: "tu@correo.com",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFF5D4037),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            if (v?.trim().isEmpty ?? true) return "Obligatorio";
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v!)) {
                              return "Correo inválido";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Extensión / Teléfono",
                            hintText: "Ej: 0991234567",
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF5D4037),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty ?? true ? "Obligatorio" : null,
                        ),

                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _notasController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Notas adicionales (opcional)",
                            hintText:
                                "Restricciones dietéticas, requerimientos especiales...",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _enviarSolicitud,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _isLoading ? "Enviando..." : "Enviar Solicitud",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D4037),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),

                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _successMessage!,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _seleccionarFecha,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Fecha",
          labelStyle: const TextStyle(color: Color(0xFF5D4037)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF5D4037),
          ),
        ),
        child: Text(
          _fechaSeleccionada == null
              ? "dd/mm/yyyy"
              : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
          style: TextStyle(
            color: _fechaSeleccionada == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _seleccionarHora,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Hora",
          labelStyle: const TextStyle(color: Color(0xFF5D4037)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF5D4037)),
        ),
        child: Text(
          _horaSeleccionada == null
              ? "--:-- --"
              : _horaSeleccionada!.format(context),
          style: TextStyle(
            color: _horaSeleccionada == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }
}
