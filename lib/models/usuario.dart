enum TipoUsuario { padre, madre, tutor, familiar, administrador }

enum TipoAdministrador {
  director,
  subdirector,
  secretario,
  personalSeguridad,
  maestro,
  administrativo
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

  // -------- Helpers de parseo seguro --------
  static String _asString(dynamic v) => v?.toString() ?? '';
  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static TipoUsuario _parseTipoUsuario(dynamic raw) {
    final s = (raw?.toString() ?? 'padre').trim().toLowerCase();
    return TipoUsuario.values.firstWhere(
      (e) => e.name == s,
      orElse: () => TipoUsuario.padre,
    );
  }

  static TipoAdministrador? _parseTipoAdministrador(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim().toLowerCase();
    if (s.isEmpty) return null;
    return TipoAdministrador.values.firstWhere(
      (e) => e.name == s,
      orElse: () => TipoAdministrador.administrativo,
    );
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

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final emailNorm = _asString(json['email']).trim().toLowerCase();
    final escuelaStr =
        _asNullableString(json['id_escuela']); // admite int/string

    return Usuario(
      id: _asString(json['id']),
      nombre: _asString(json['nombre']),
      apellido: _asString(json['apellido']),
      email: emailNorm,
      telefono: _asNullableString(json['telefono']),
      tipo: _parseTipoUsuario(json['tipo']),
      tipoAdministrador: _parseTipoAdministrador(json['tipo_administrador']),
      escuelaId: escuelaStr,
      fechaRegistro: _parseFecha(json['fecha_registro']),
    );
  }

  Map<String, dynamic> toJson() {
    final fechaUtc =
        fechaRegistro.isUtc ? fechaRegistro : fechaRegistro.toUtc();
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email.trim().toLowerCase(),
      'telefono': telefono,
      'tipo': tipo.name,
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

  String get nombreCompleto =>
      [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esFamiliar => !esAdministrador;
  bool get perteneceAEscuela => (escuelaId?.trim().isNotEmpty ?? false);

  @override
  String toString() {
    return 'Usuario(id: $id, nombreCompleto: $nombreCompleto, email: $email, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
