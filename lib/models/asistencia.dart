enum EstadoAsistencia {
  presente,
  ausente,
  tarde,
  permisoEspecial,
}

class Asistencia {
  final String id;
  final String alumnoId;
  final DateTime fecha;
  final DateTime? horaEntrada;
  final DateTime? horaSalida;
  final EstadoAsistencia estado;
  final String? observaciones;
  final bool? requiereJustificacion;

  const Asistencia({
    required this.id,
    required this.alumnoId,
    required this.fecha,
    this.horaEntrada,
    this.horaSalida,
    required this.estado,
    this.observaciones,
    this.requiereJustificacion,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] ?? '',
      alumnoId: json['alumnoId'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      horaEntrada: json['horaEntrada'] != null
          ? DateTime.parse(json['horaEntrada'])
          : null,
      horaSalida: json['horaSalida'] != null
          ? DateTime.parse(json['horaSalida'])
          : null,
      estado: EstadoAsistencia.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoAsistencia.ausente,
      ),
      observaciones: json['observaciones'],
      requiereJustificacion: json['requiereJustificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumnoId': alumnoId,
      'fecha': fecha.toIso8601String(),
      'horaEntrada': horaEntrada?.toIso8601String(),
      'horaSalida': horaSalida?.toIso8601String(),
      'estado': estado.name,
      'observaciones': observaciones,
      'requiereJustificacion': requiereJustificacion,
    };
  }

  Asistencia copyWith({
    String? id,
    String? alumnoId,
    DateTime? fecha,
    DateTime? horaEntrada,
    DateTime? horaSalida,
    EstadoAsistencia? estado,
    String? observaciones,
    bool? requiereJustificacion,
  }) {
    return Asistencia(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      fecha: fecha ?? this.fecha,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      requiereJustificacion:
          requiereJustificacion ?? this.requiereJustificacion,
    );
  }

  bool get estaPresente =>
      estado == EstadoAsistencia.presente || estado == EstadoAsistencia.tarde;
  bool get llegaTarde => estado == EstadoAsistencia.tarde;

  @override
  String toString() {
    return 'Asistencia(id: $id, alumnoId: $alumnoId, fecha: $fecha, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
