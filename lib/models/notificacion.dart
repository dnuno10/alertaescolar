// notificacion.dart

// =====================
// Enums
// =====================

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

// Campos que solo aplican cuando tipo == comunicado
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

// =====================
// Extensiones: mapeo a BD (snake_case) y parse desde BD
// =====================

extension TipoNotificacionDb on TipoNotificacion {
  String get dbValue {
    switch (this) {
      case TipoNotificacion.entrada:
        return 'entrada';
      case TipoNotificacion.salida:
        return 'salida';
      case TipoNotificacion.retraso:
        return 'retraso';
      case TipoNotificacion.ausencia:
        return 'ausencia';
      case TipoNotificacion.permisoEspecial:
        return 'permiso_especial';
      case TipoNotificacion.comunicado:
        return 'comunicado';
    }
  }

  static TipoNotificacion fromDb(String v) {
    switch (v) {
      case 'entrada':
        return TipoNotificacion.entrada;
      case 'salida':
        return TipoNotificacion.salida;
      case 'retraso':
        return TipoNotificacion.retraso;
      case 'ausencia':
        return TipoNotificacion.ausencia;
      case 'permiso_especial':
        return TipoNotificacion.permisoEspecial;
      case 'comunicado':
        return TipoNotificacion.comunicado;
      default:
        // fallback por compatibilidad: intenta por .name (camelCase)
        return TipoNotificacion.values.firstWhere(
          (e) => e.name == v,
          orElse: () => TipoNotificacion.comunicado,
        );
    }
  }
}

extension EstadoNotificacionDb on EstadoNotificacion {
  String get dbValue => this == EstadoNotificacion.nueva ? 'nueva' : 'leida';

  static EstadoNotificacion fromDb(String v) {
    switch (v) {
      case 'nueva':
        return EstadoNotificacion.nueva;
      case 'leida':
        return EstadoNotificacion.leida;
      default:
        return EstadoNotificacion.values.firstWhere(
          (e) => e.name == v,
          orElse: () => EstadoNotificacion.nueva,
        );
    }
  }
}

extension TipoComunicacionDb on TipoComunicacion {
  String get dbValue {
    switch (this) {
      case TipoComunicacion.emergencia:
        return 'emergencia';
      case TipoComunicacion.paseo:
        return 'paseo';
      case TipoComunicacion.evento:
        return 'evento';
      case TipoComunicacion.recordatorioPago:
        return 'recordatorio_pago';
      case TipoComunicacion.citatorio:
        return 'citatorio';
      case TipoComunicacion.informativo:
        return 'informativo';
      case TipoComunicacion.celebracion:
        return 'celebracion';
      case TipoComunicacion.suspencionClases:
        return 'suspencion_clases';
      case TipoComunicacion.cambioHorario:
        return 'cambio_horario';
    }
  }

  static TipoComunicacion? fromDb(String? v) {
    if (v == null) return null;
    switch (v) {
      case 'emergencia':
        return TipoComunicacion.emergencia;
      case 'paseo':
        return TipoComunicacion.paseo;
      case 'evento':
        return TipoComunicacion.evento;
      case 'recordatorio_pago':
        return TipoComunicacion.recordatorioPago;
      case 'citatorio':
        return TipoComunicacion.citatorio;
      case 'informativo':
        return TipoComunicacion.informativo;
      case 'celebracion':
        return TipoComunicacion.celebracion;
      case 'suspencion_clases':
        return TipoComunicacion.suspencionClases;
      case 'cambio_horario':
        return TipoComunicacion.cambioHorario;
      default:
        return TipoComunicacion.values.firstWhere(
          (e) => e.name == v,
          orElse: () => TipoComunicacion.informativo,
        );
    }
  }
}

extension PrioridadComunicadoDb on PrioridadComunicado {
  String get dbValue {
    switch (this) {
      case PrioridadComunicado.baja:
        return 'baja';
      case PrioridadComunicado.media:
        return 'media';
      case PrioridadComunicado.alta:
        return 'alta';
      case PrioridadComunicado.critica:
        return 'critica';
    }
  }

  static PrioridadComunicado? fromDb(String? v) {
    if (v == null) return null;
    switch (v) {
      case 'baja':
        return PrioridadComunicado.baja;
      case 'media':
        return PrioridadComunicado.media;
      case 'alta':
        return PrioridadComunicado.alta;
      case 'critica':
        return PrioridadComunicado.critica;
      default:
        return PrioridadComunicado.values.firstWhere(
          (e) => e.name == v,
          orElse: () => PrioridadComunicado.media,
        );
    }
  }
}

// =====================
// Modelo
// =====================

class Notificacion {
  // Core
  final String id;
  final String alumnoId; // id_alumno
  final String? adminId; // id_admin (quien registró acceso manual, opcional)
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final EstadoNotificacion estado;
  final DateTime fechaHora; // fecha_hora (o fecha_registro en algunas vistas)
  final Map<String, dynamic>? datosAdicionales; // datos_adicionales (jsonb)

  // Solo para comunicados
  final String? escuelaId; // id_escuela
  final String? autorId; // id_autor (usuario que creó el comunicado)
  final TipoComunicacion? tipoComunicacion; // tipo_comunicado
  final PrioridadComunicado? prioridadComunicado; // prioridad_comunicado
  final DateTime? fechaEnvio; // fecha_envio
  final DateTime? fechaProgramada; // fecha_programada

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

    // comunicado
    this.escuelaId,
    this.autorId,
    this.tipoComunicacion,
    this.prioridadComunicado,
    this.fechaEnvio,
    this.fechaProgramada,
  });

  // ---------------------
  // From JSON/BD
  // ---------------------
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    String? _str(Map m, String a, String b) => (m[a] ?? m[b])?.toString();
    DateTime? _dt(dynamic v) {
      try {
        return v == null ? null : DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    // lee ambos nombres (bd y camel) por compatibilidad
    final tipoDb = _str(json, 'tipo_notificacion', 'tipo') ??
        _str(json, 'tipoNotificacion', 'tipo');

    final estadoDb = _str(json, 'estado', 'estadoNotificacion') ??
        _str(json, 'estado_notificacion', 'estado');

    final tipoNotif = tipoDb != null
        ? TipoNotificacionDb.fromDb(tipoDb)
        : TipoNotificacion.entrada;

    final estado = estadoDb != null
        ? EstadoNotificacionDb.fromDb(estadoDb)
        : EstadoNotificacion.nueva;

    final tipoComStr = _str(json, 'tipo_comunicado', 'tipoComunicacion');
    final prioridadStr =
        _str(json, 'prioridad_comunicado', 'prioridadComunicado');

    return Notificacion(
      id: _str(json, 'id', 'id') ?? '',
      alumnoId: _str(json, 'id_alumno', 'alumnoId') ?? '',
      adminId: _str(json, 'id_admin', 'adminId'),
      titulo: _str(json, 'titulo', 'titulo') ?? '',
      mensaje: _str(json, 'mensaje', 'mensaje') ?? '',
      tipo: tipoNotif,
      estado: estado,
      fechaHora: _dt(json['fecha_hora'] ?? json['fechaHora']) ?? DateTime.now(),
      datosAdicionales: (json['datos_adicionales'] ?? json['datosAdicionales'])
          as Map<String, dynamic>?,

      // comunicado
      escuelaId: _str(json, 'id_escuela', 'escuelaId'),
      autorId: _str(json, 'id_autor', 'autorId'),
      tipoComunicacion: TipoComunicacionDb.fromDb(tipoComStr),
      prioridadComunicado: PrioridadComunicadoDb.fromDb(prioridadStr),
      fechaEnvio: _dt(json['fecha_envio'] ?? json['fechaEnvio']),
      fechaProgramada: _dt(json['fecha_programada'] ?? json['fechaProgramada']),
    );
  }

  // ---------------------
  // To JSON/BD (snake_case)
  // ---------------------
  /// Serializa listo para `supabase.from('notificaciones').insert/update(...)`
  Map<String, dynamic> toJsonDb({
    String?
        destinatariosComunicado, // 'individual' | 'grupo' | 'turno' | 'todos' (si aplica)
  }) {
    return {
      'id': id,
      'id_alumno': alumnoId,
      'id_admin': adminId,
      'titulo': titulo,
      'mensaje': mensaje,

      // claves en snake_case y valores normalizados
      'tipo_notificacion': tipo.dbValue,
      'estado': estado.dbValue,
      'fecha_hora': fechaHora.toIso8601String(),
      'datos_adicionales': datosAdicionales,

      // comunicado (solo si aplica)
      'id_escuela': escuelaId,
      'id_autor': autorId,
      'tipo_comunicado': tipoComunicacion?.dbValue,
      'prioridad_comunicado': prioridadComunicado?.dbValue,
      'fecha_envio': fechaEnvio?.toIso8601String(),
      'fecha_programada': fechaProgramada?.toIso8601String(),

      // opcional para auditoría de targeting
      if (destinatariosComunicado != null)
        'destinatarios_comunicado': destinatariosComunicado,
    };
  }

  // ---------------------
  // Copy
  // ---------------------
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

    // comunicado
    String? escuelaId,
    String? autorId,
    TipoComunicacion? tipoComunicacion,
    PrioridadComunicado? prioridadComunicado,
    DateTime? fechaEnvio,
    DateTime? fechaProgramada,
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

      // comunicado
      escuelaId: escuelaId ?? this.escuelaId,
      autorId: autorId ?? this.autorId,
      tipoComunicacion: tipoComunicacion ?? this.tipoComunicacion,
      prioridadComunicado: prioridadComunicado ?? this.prioridadComunicado,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
    );
  }

  // ---------------------
  // Helpers
  // ---------------------
  bool get esComunicado => tipo == TipoNotificacion.comunicado;

  bool get esAltaPrioridadComunicado =>
      esComunicado &&
      (prioridadComunicado == PrioridadComunicado.alta ||
          prioridadComunicado == PrioridadComunicado.critica);

  @override
  String toString() =>
      'Notificacion(id: $id, alumnoId: $alumnoId, tipo: $tipo, estado: $estado, fechaHora: $fechaHora)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Notificacion && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
