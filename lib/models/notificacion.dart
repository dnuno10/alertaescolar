// notificacion.dart

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

class Notificacion {
  // Core
  final String id;
  final String alumnoId; // id_alumno
  final String? adminId; // id_admin (quien registró acceso manual, opcional)
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final EstadoNotificacion estado;
  final DateTime fechaHora; // fecha_hora
  final Map<String, dynamic>? datosAdicionales; // datos_adicionales (jsonb)

  // Solo para comunicados
  final String? escuelaId; // id_escuela
  final String? autorId; // id_autor (usuario que creó el comunicado)
  final TipoComunicacion? tipoComunicacion; // tipo_comunicacion
  final PrioridadComunicado? prioridadComunicado; // prioridad_comunicado
  final DateTime? fechaEnvio; // fecha_envio (cuando se envió realmente)
  final DateTime? fechaProgramada; // fecha_programada (si se dejó programado)

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

  /// Carga desde un row de Supabase/JSON usando snake_case (alineado a tu BD)
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    // Admite tanto snake_case (BD) como camelCase (si ya lo tenías en memoria)
    String? _str(Map m, String a, String b) => (m[a] ?? m[b])?.toString();

    Map<String, dynamic>? _map(Map m, String a, String b) =>
        (m[a] ?? m[b]) is Map<String, dynamic> ? (m[a] ?? m[b]) : null;

    T? _enum<T>(List<T> values, String? name) {
      if (name == null) return null;
      try {
        // Comparación por .name
        return values.firstWhere(
          (e) => (e as dynamic).name == name,
        );
      } catch (_) {
        return null;
      }
    }

    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final tipoStr = _str(json, 'tipo', 'tipoNotificacion');
    final estadoStr = _str(json, 'estado', 'estadoNotificacion');

    final tipoNotif =
        _enum<TipoNotificacion>(TipoNotificacion.values, tipoStr) ??
            TipoNotificacion.entrada;
    final estado =
        _enum<EstadoNotificacion>(EstadoNotificacion.values, estadoStr) ??
            EstadoNotificacion.nueva;

    final tipoComStr = _str(json, 'tipo_comunicacion', 'tipoComunicacion');
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
      tipoComunicacion:
          _enum<TipoComunicacion>(TipoComunicacion.values, tipoComStr),
      prioridadComunicado:
          _enum<PrioridadComunicado>(PrioridadComunicado.values, prioridadStr),
      fechaEnvio: _dt(json['fecha_envio'] ?? json['fechaEnvio']),
      fechaProgramada: _dt(json['fecha_programada'] ?? json['fechaProgramada']),
    );
  }

  /// Serializa en snake_case listo para `supabase.from('notificaciones').insert/update(...)`
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_alumno': alumnoId,
      'id_admin': adminId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.name,
      'estado': estado.name,
      'fecha_hora': fechaHora.toIso8601String(),
      'datos_adicionales': datosAdicionales,

      // comunicado
      'id_escuela': escuelaId,
      'id_autor': autorId,
      'tipo_comunicacion': tipoComunicacion?.name,
      'prioridad_comunicado': prioridadComunicado?.name,
      'fecha_envio': fechaEnvio?.toIso8601String(),
      'fecha_programada': fechaProgramada?.toIso8601String(),
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

  bool get esComunicado => tipo == TipoNotificacion.comunicado;
  bool get esAltaPrioridadComunicado =>
      esComunicado &&
      (prioridadComunicado == PrioridadComunicado.alta ||
          prioridadComunicado == PrioridadComunicado.critica);

  @override
  String toString() {
    return 'Notificacion(id: $id, alumnoId: $alumnoId, tipo: $tipo, estado: $estado, fechaHora: $fechaHora)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Notificacion && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
