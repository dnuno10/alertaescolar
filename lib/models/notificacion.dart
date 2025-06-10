enum TipoNotificacion {
  entrada,
  salida,
  retraso,
  ausencia,
  permisoEspecial,
  alerta,
  comunicado,
}

enum EstadoNotificacion {
  nueva,
  leida,
}

class Notificacion {
  final String id;
  final String alumnoId;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final EstadoNotificacion estado;
  final DateTime fechaHora;
  final Map<String, dynamic>? datosAdicionales;

  const Notificacion({
    required this.id,
    required this.alumnoId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.estado = EstadoNotificacion.nueva,
    required this.fechaHora,
    this.datosAdicionales,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      alumnoId: json['alumnoId'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: TipoNotificacion.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoNotificacion.alerta,
      ),
      estado: EstadoNotificacion.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoNotificacion.nueva,
      ),
      fechaHora: DateTime.parse(json['fechaHora']),
      datosAdicionales: json['datosAdicionales'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumnoId': alumnoId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.name,
      'estado': estado.name,
      'fechaHora': fechaHora.toIso8601String(),
      'datosAdicionales': datosAdicionales,
    };
  }

  Notificacion copyWith({
    String? id,
    String? alumnoId,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    EstadoNotificacion? estado,
    DateTime? fechaHora,
    Map<String, dynamic>? datosAdicionales,
  }) {
    return Notificacion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
    );
  }

  @override
  String toString() {
    return 'Notificacion(id: $id, titulo: $titulo, tipo: $tipo, estado: $estado, fechaHora: $fechaHora)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notificacion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
