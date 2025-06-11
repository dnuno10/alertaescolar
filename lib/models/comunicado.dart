enum TipoComunicado {
  emergencia,
  evento,
  recordatorioPago,
  citatorio,
  informativo,
  celebracion,
  suspencionClases,
  cambioHorario
}

enum PrioridadComunicado {
  baja,
  media,
  alta,
  critica,
}

enum EstadoComunicado {
  borrador,
  programado,
  enviado,
  cancelado,
}

enum TipoAudiencia {
  todos,
  padres,
  estudiantes,
  profesores,
  gradoEspecifico,
}

class Comunicado {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fechaCreacion;
  final DateTime? fechaEnvio;
  final DateTime? fechaProgramada;
  final List<String>
      destinatarios; // Puede ser grados, grupos o IDs de estudiantes
  final PrioridadComunicado prioridad;
  final EstadoComunicado estado;
  final String autorId;
  final String escuelaId;
  final Map<String, dynamic>? datosAdicionales;
  final TipoAudiencia audiencia;
  final List<String> gradosEspecificos;

  const Comunicado({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fechaCreacion,
    this.fechaEnvio,
    this.fechaProgramada,
    required this.destinatarios,
    this.prioridad = PrioridadComunicado.media,
    this.estado = EstadoComunicado.borrador,
    required this.autorId,
    required this.escuelaId,
    this.datosAdicionales,
    this.audiencia = TipoAudiencia.todos,
    this.gradosEspecificos = const [],
  });

  // Getters for backward compatibility
  String get contenido => mensaje;
  String get tipoAudiencia => destinatarios.join(', ');
  List<String> get adjuntos => [];
  Map<String, int>? get estadisticasEntrega => {
        'enviados': 100,
        'entregados': 95,
        'leidos': 80,
      };

  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaEnvio: json['fechaEnvio'] != null
          ? DateTime.parse(json['fechaEnvio'])
          : null,
      fechaProgramada: json['fechaProgramada'] != null
          ? DateTime.parse(json['fechaProgramada'])
          : null,
      destinatarios: List<String>.from(json['destinatarios'] ?? []),
      prioridad: PrioridadComunicado.values.firstWhere(
        (e) => e.name == json['prioridad'],
        orElse: () => PrioridadComunicado.media,
      ),
      estado: EstadoComunicado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoComunicado.borrador,
      ),
      autorId: json['autorId'] ?? '',
      escuelaId: json['escuelaId'] ?? '',
      datosAdicionales: json['datosAdicionales'],
      audiencia: TipoAudiencia.values.firstWhere(
        (e) => e.name == json['audiencia'],
        orElse: () => TipoAudiencia.todos,
      ),
      gradosEspecificos: List<String>.from(json['gradosEspecificos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaEnvio': fechaEnvio?.toIso8601String(),
      'fechaProgramada': fechaProgramada?.toIso8601String(),
      'destinatarios': destinatarios,
      'prioridad': prioridad.name,
      'estado': estado.name,
      'autorId': autorId,
      'escuelaId': escuelaId,
      'datosAdicionales': datosAdicionales,
      'audiencia': audiencia.name,
      'gradosEspecificos': gradosEspecificos,
    };
  }

  Comunicado copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    DateTime? fechaCreacion,
    DateTime? fechaEnvio,
    DateTime? fechaProgramada,
    List<String>? destinatarios,
    PrioridadComunicado? prioridad,
    EstadoComunicado? estado,
    String? autorId,
    String? escuelaId,
    Map<String, dynamic>? datosAdicionales,
    TipoAudiencia? audiencia,
    List<String>? gradosEspecificos,
  }) {
    return Comunicado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      destinatarios: destinatarios ?? this.destinatarios,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      autorId: autorId ?? this.autorId,
      escuelaId: escuelaId ?? this.escuelaId,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
      audiencia: audiencia ?? this.audiencia,
      gradosEspecificos: gradosEspecificos ?? this.gradosEspecificos,
    );
  }

  bool get esBorrador => estado == EstadoComunicado.borrador;
  bool get estaProgramado => estado == EstadoComunicado.programado;
  bool get estaEnviado => estado == EstadoComunicado.enviado;
  bool get estaCancelado => estado == EstadoComunicado.cancelado;

  bool get esAltaPrioridad =>
      prioridad == PrioridadComunicado.alta ||
      prioridad == PrioridadComunicado.critica;

  @override
  String toString() {
    return 'Comunicado(id: $id, titulo: $titulo, estado: $estado, prioridad: $prioridad)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comunicado && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
