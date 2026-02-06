// lib/models/catering.dart
class Catering {
  final int idSolicitud;
  final int? idUsuario;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String fechaEvento; // 'YYYY-MM-DD'
  final String? horaEvento; // 'HH:mm:ss' o null
  final String tipoEvento;
  final int? cantidadPersonas;
  final String? descripcion;
  final String estado; // pendiente, confirmada, rechazada, cancelada
  final String fechaSolicitud; // fecha + hora
  final int? respondidaPor;
  final String? respuesta;

  // Datos del admin que respondió (opcional, cuando el backend lo incluye)
  final String? nombreAdminRespuesta;

  Catering({
    required this.idSolicitud,
    this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.fechaEvento,
    this.horaEvento,
    required this.tipoEvento,
    this.cantidadPersonas,
    this.descripcion,
    required this.estado,
    required this.fechaSolicitud,
    this.respondidaPor,
    this.respuesta,
    this.nombreAdminRespuesta,
  });

  factory Catering.fromJson(Map<String, dynamic> json) {
    return Catering(
      idSolicitud: json['idSolicitud'],
      idUsuario: json['idUsuario'],
      nombreCompleto: json['nombreCompleto'] ?? json['nombre_completo'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      fechaEvento: json['fechaEvento'] ?? json['fecha_evento'] ?? '',
      horaEvento: json['horaEvento'] ?? json['hora_evento'],
      tipoEvento: json['tipoEvento'] ?? json['tipo_evento'] ?? '',
      cantidadPersonas: json['cantidadPersonas'] ?? json['cantidad_personas'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'pendiente',
      fechaSolicitud: json['fechaSolicitud'] ?? json['fecha_solicitud'] ?? '',
      respondidaPor: json['respondidaPor'] ?? json['respondida_por'],
      respuesta: json['respuesta'],
      nombreAdminRespuesta: json['administradorRespuesta']?['username'],
    );
  }
}
