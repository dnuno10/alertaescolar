enum TipoUsuario { padre, madre, tutor, familiar, administrador }

enum TipoAdministrador {
  director,
  subdirector,
  secretario,
  personalSeguridad,
  maestro,
  administrativo,
}

class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final TipoUsuario tipo;
  final TipoAdministrador? tipoAdministrador;
  final String? escuelaId;
  final DateTime fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.tipo = TipoUsuario.padre,
    this.tipoAdministrador,
    this.escuelaId,
    required this.fechaRegistro,
  });

  static String _asString(dynamic v) => v?.toString() ?? '';
  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static TipoUsuario _parseTipoUsuario(dynamic raw) {
    final s = (raw?.toString() ?? '').trim().toLowerCase();
    // Acepta alias comunes
    switch (s) {
      case 'padre':
        return TipoUsuario.padre;
      case 'madre':
        return TipoUsuario.madre;
      case 'tutor':
        return TipoUsuario.tutor;
      case 'familiar':
        return TipoUsuario.familiar;
      case 'administrador':
      case 'admin':
        return TipoUsuario.administrador;
      default:
        // valor por defecto seguro
        return TipoUsuario.padre;
    }
  }

  static TipoAdministrador? _parseTipoAdministrador(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim().toLowerCase();
    if (s.isEmpty) return null;
    switch (s) {
      case 'director':
        return TipoAdministrador.director;
      case 'subdirector':
        return TipoAdministrador.subdirector;
      case 'secretario':
        return TipoAdministrador.secretario;
      case 'personalseguridad':
      case 'personal_seguridad':
      case 'seguridad':
        return TipoAdministrador.personalSeguridad;
      case 'maestro':
      case 'docente':
        return TipoAdministrador.maestro;
      case 'administrativo':
      case 'admin':
        return TipoAdministrador.administrativo;
      default:
        return TipoAdministrador.administrativo;
    }
  }

  static DateTime _parseFecha(dynamic raw) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return DateTime.now().toUtc();
    try {
      final dt = DateTime.parse(s);
      return dt.isUtc ? dt : dt.toUtc();
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }

  /// Crea un Usuario desde el JSON/row de la BD (snake_case).
  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Normaliza email
    final emailNorm = _asString(json['email']).trim().toLowerCase();

    // `id_escuela` puede venir numérico o string
    final escuelaStr = json.containsKey('id_escuela')
        ? _asNullableString(json['id_escuela'])
        : _asNullableString(json['escuelaId']); // fallback

    return Usuario(
      id: _asString(json['id']),
      nombre: _asString(json['nombre']),
      apellido: _asString(json['apellido']),
      email: emailNorm,
      telefono: _asNullableString(json['telefono']),
      tipo: _parseTipoUsuario(json['tipo']),
      tipoAdministrador: _parseTipoAdministrador(json['tipo_administrador']),
      escuelaId: escuelaStr,
      fechaRegistro:
          _parseFecha(json['fecha_registro'] ?? json['fechaRegistro']),
    );
  }

  /// Serializa a mapa listo para escribir en la BD (snake_case).
  Map<String, dynamic> toJson() {
    final fechaUtc =
        fechaRegistro.isUtc ? fechaRegistro : fechaRegistro.toUtc();
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email.trim().toLowerCase(),
      'telefono': telefono,
      'tipo': tipo.name, // guarda exactamente los enums en minúsculas
      'tipo_administrador': tipoAdministrador?.name,
      'id_escuela': escuelaId,
      'fecha_registro': fechaUtc.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    TipoUsuario? tipo,
    TipoAdministrador? tipoAdministrador,
    String? escuelaId,
    DateTime? fechaRegistro,
  }) {
    final newEmail = (email ?? this.email).trim().toLowerCase();
    final newFecha = (fechaRegistro ?? this.fechaRegistro);
    final fechaUtc = newFecha.isUtc ? newFecha : newFecha.toUtc();

    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: newEmail,
      telefono: telefono ?? this.telefono,
      tipo: tipo ?? this.tipo,
      tipoAdministrador: tipoAdministrador ?? this.tipoAdministrador,
      escuelaId: escuelaId ?? this.escuelaId,
      fechaRegistro: fechaUtc,
    );
  }

  // ---------- Helpers de dominio ----------
  String get nombreCompleto =>
      [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esFamiliar => !esAdministrador;
  bool get perteneceAEscuela => (escuelaId?.trim().isNotEmpty ?? false);

  @override
  String toString() {
    return 'Usuario(id: $id, nombreCompleto: $nombreCompleto, email: $email, tipo: $tipo, escuelaId: $escuelaId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Usuario && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
