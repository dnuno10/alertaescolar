import '../utils/time_format.dart';

class Turno {
  final String id;
  final String turno;
  final String horaInicio; // HH:MM (derivado de hora_inicio)
  final String horaFin; // HH:MM (derivado de hora_fin)
  final DateTime fechaRegistro; // fecha_registro
  final String idEscuela; // id_escuela
  final int tolerancia; // minutos
  final bool
      aplicarTolerancia; // Si FALSE, no se considera tolerancia (sin retrasos)

  const Turno({
    required this.id,
    required this.turno,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaRegistro,
    required this.idEscuela,
    this.tolerancia = 15,
    this.aplicarTolerancia =
        true, // Por defecto TRUE para mantener comportamiento actual
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    // Extrae "HH:MM" desde timestamptz o HH:MM(:SS)
    String parseTime(dynamic time) {
      final s = (time ?? '').toString();
      if (s.isEmpty) return '00:00';

      // Caso timestamptz: "2024-01-01T07:30:00+00:00" -> "07:30"
      final tMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(s);
      if (tMatch != null) {
        return '${tMatch.group(1)}:${tMatch.group(2)}';
      }

      // Caso HH:MM(:SS)
      if (s.contains(':')) {
        final parts = s.split(':');
        if (parts.length >= 2) {
          final hh = parts[0].padLeft(2, '0');
          final mm = parts[1].padLeft(2, '0');
          return '$hh:$mm';
        }
      }

      // Último recurso
      return '00:00';
    }

    return Turno(
      id: json['id'] ?? '',
      turno: json['turno'] ?? '',
      horaInicio: parseTime(json['hora_inicio']),
      horaFin: parseTime(json['hora_fin']),
      fechaRegistro: DateTime.parse(
        (json['fecha_registro'] ?? DateTime.now().toIso8601String()).toString(),
      ),
      idEscuela: json['id_escuela'] ?? '',
      tolerancia: (json['tolerancia'] is num)
          ? (json['tolerancia'] as num).toInt()
          : 15,
      aplicarTolerancia: (json['aplicar_tolerancia'] ?? false) == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turno': turno,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'id_escuela': idEscuela,
      'tolerancia': tolerancia,
      'aplicar_tolerancia': aplicarTolerancia,
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
    bool? aplicarTolerancia,
  }) {
    return Turno(
      id: id ?? this.id,
      turno: turno ?? this.turno,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEscuela: idEscuela ?? this.idEscuela,
      tolerancia: tolerancia ?? this.tolerancia,
      aplicarTolerancia: aplicarTolerancia ?? this.aplicarTolerancia,
    );
  }

  String get horaInicioAmPm => TimeFormat.format24to12(horaInicio);
  String get horaFinAmPm => TimeFormat.format24to12(horaFin);

  String get horarioCompleto => '$horaInicioAmPm - $horaFinAmPm';

  @override
  String toString() {
    return 'Turno(id: $id, turno: $turno, horario: $horarioCompleto, tolerancia: $tolerancia, aplicarTolerancia: $aplicarTolerancia)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Turno && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
