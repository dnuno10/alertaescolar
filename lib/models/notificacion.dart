enum TipoNotificacion {
  entrada,
  salida,
  retraso,
  ausencia,
  permisoEspecial,
  comunicado,
}

enum EstadoNotificacion {
  nueva,
  leida,
}

enum TipoComunicacion {
  emergencia,
  paseo,
  evento,
  recordatorioPago,
  citatorio,
  informativo,
  celebracion,
  suspencionClases,
  cambioHorario,
}

enum PrioridadComunicado {
  baja,
  media,
  alta,
  critica,
}

class Notificacion {
  final String id;
  final String alumnoId;
  final String? adminId;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final EstadoNotificacion estado;
  final DateTime fechaHora;
  final Map<String, dynamic>? datosAdicionales;

  // Campos específicos para comunicados
  final TipoComunicacion? tipoComunicacion;
  final PrioridadComunicado? prioridadComunicado;

  const Notificacion({
    required this.id,
    required this.alumnoId,
    this.adminId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.estado = EstadoNotificacion.nueva,
    required this.fechaHora,
    this.datosAdicionales,
    this.tipoComunicacion,
    this.prioridadComunicado,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      alumnoId: json['alumnoId'] ?? '',
      adminId: json['adminId'],
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: TipoNotificacion.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoNotificacion.entrada,
      ),
      estado: EstadoNotificacion.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoNotificacion.nueva,
      ),
      fechaHora: DateTime.parse(json['fechaHora']),
      datosAdicionales: json['datosAdicionales'],
      tipoComunicacion: json['tipoComunicacion'] != null
          ? TipoComunicacion.values.firstWhere(
              (e) => e.name == json['tipoComunicacion'],
              orElse: () => TipoComunicacion.informativo,
            )
          : null,
      prioridadComunicado: json['prioridadComunicado'] != null
          ? PrioridadComunicado.values.firstWhere(
              (e) => e.name == json['prioridadComunicado'],
              orElse: () => PrioridadComunicado.media,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumnoId': alumnoId,
      'adminId': adminId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.name,
      'estado': estado.name,
      'fechaHora': fechaHora.toIso8601String(),
      'datosAdicionales': datosAdicionales,
      'tipoComunicacion': tipoComunicacion?.name,
      'prioridadComunicado': prioridadComunicado?.name,
    };
  }

  Notificacion copyWith({
    String? id,
    String? alumnoId,
    String? adminId,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    EstadoNotificacion? estado,
    DateTime? fechaHora,
    Map<String, dynamic>? datosAdicionales,
    TipoComunicacion? tipoComunicacion,
    PrioridadComunicado? prioridadComunicado,
  }) {
    return Notificacion(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      adminId: adminId ?? this.adminId,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
      tipoComunicacion: tipoComunicacion ?? this.tipoComunicacion,
      prioridadComunicado: prioridadComunicado ?? this.prioridadComunicado,
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
