import '../utils/time_format.dart';

class Turno {
  final String id;
  final String turno;
  final String horaInicio;
  final String horaFin;
  final DateTime fechaRegistro;
  final String idEscuela;
  final int tolerancia;

  const Turno({
    required this.id,
    required this.turno,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaRegistro,
    required this.idEscuela,
    this.tolerancia = 15, // Default tolerance of 15 minutes
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    // Parse time with timezone format to extract just HH:MM
    String parseTime(String? timeString) {
      if (timeString == null || timeString.isEmpty) return '00:00';

      // If it contains timezone part (+/-), extract just the time part
      if (timeString.contains('+') ||
          (timeString.contains('-') && timeString.lastIndexOf('-') > 2)) {
        final timePart = timeString.split(RegExp(r'[+-]'))[0];
        return timePart.substring(0, 5); // Take just HH:MM
      }

      // Handle simple time format (HH:MM:SS or HH:MM)
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }

      return '00:00';
    }

    return Turno(
      id: json['id'] ?? '',
      turno: json['turno'] ?? '',
      horaInicio: parseTime(json['hora_inicio']),
      horaFin: parseTime(json['hora_fin']),
      fechaRegistro: DateTime.parse(json['fecha-registro'] ??
          json['fecha_registro'] ??
          DateTime.now().toIso8601String()),
      idEscuela: json['id_escuela'] ?? '',
      tolerancia: json['tolerancia']?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turno': turno,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'fecha-registro': fechaRegistro.toIso8601String(),
      'id_escuela': idEscuela,
      'tolerancia': tolerancia,
    };
  }

  Turno copyWith({
    String? id,
    String? turno,
    String? horaInicio,
    String? horaFin,
    DateTime? fechaRegistro,
    String? idEscuela,
    int? tolerancia,
  }) {
    return Turno(
      id: id ?? this.id,
      turno: turno ?? this.turno,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEscuela: idEscuela ?? this.idEscuela,
      tolerancia: tolerancia ?? this.tolerancia,
    );
  }

  String get horaInicioAmPm => TimeFormat.format24to12(horaInicio);
  String get horaFinAmPm => TimeFormat.format24to12(horaFin);

  String get horarioCompleto => '[32m$horaInicioAmPm - $horaFinAmPm[0m';

  @override
  String toString() {
    return 'Turno(id: $id, turno: $turno, horario: $horarioCompleto, tolerancia: $tolerancia)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Turno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
