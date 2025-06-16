class Turno {
  final String id;
  final String turno;
  final String horaInicio;
  final String horaFin;
  final DateTime fechaRegistro;
  final String idEscuela;

  const Turno({
    required this.id,
    required this.turno,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaRegistro,
    required this.idEscuela,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] ?? '',
      turno: json['turno'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      fechaRegistro: DateTime.parse(json['fecha-registro'] ??
          json['fecha_registro'] ??
          DateTime.now().toIso8601String()),
      idEscuela: json['id_escuela'] ?? '',
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
    };
  }

  Turno copyWith({
    String? id,
    String? turno,
    String? horaInicio,
    String? horaFin,
    DateTime? fechaRegistro,
    String? idEscuela,
  }) {
    return Turno(
      id: id ?? this.id,
      turno: turno ?? this.turno,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEscuela: idEscuela ?? this.idEscuela,
    );
  }

  String get horarioCompleto => '$horaInicio - $horaFin';

  @override
  String toString() {
    return 'Turno(id: $id, turno: $turno, horario: $horarioCompleto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Turno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
