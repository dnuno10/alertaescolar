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
  final String? fotoUrl;
  final bool activo;
  final DateTime fechaRegistro;
  final DateTime? fechaUltimaConexion;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.tipo = TipoUsuario.padre,
    this.tipoAdministrador,
    this.escuelaId,
    this.fotoUrl,
    this.activo = true,
    required this.fechaRegistro,
    this.fechaUltimaConexion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoUsuario.padre,
      ),
      tipoAdministrador: json['tipoAdministrador'] != null
          ? TipoAdministrador.values.firstWhere(
              (e) => e.name == json['tipoAdministrador'],
              orElse: () => TipoAdministrador.administrativo,
            )
          : null,
      escuelaId: json['escuelaId'],
      fotoUrl: json['fotoUrl'],
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      fechaUltimaConexion: json['fechaUltimaConexion'] != null
          ? DateTime.parse(json['fechaUltimaConexion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'tipo': tipo.name,
      'tipoAdministrador': tipoAdministrador?.name,
      'escuelaId': escuelaId,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fechaUltimaConexion': fechaUltimaConexion?.toIso8601String(),
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
    String? fotoUrl,
    bool? activo,
    DateTime? fechaRegistro,
    DateTime? fechaUltimaConexion,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      tipo: tipo ?? this.tipo,
      tipoAdministrador: tipoAdministrador ?? this.tipoAdministrador,
      escuelaId: escuelaId ?? this.escuelaId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaUltimaConexion: fechaUltimaConexion ?? this.fechaUltimaConexion,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esFamiliar => tipo != TipoUsuario.administrador;
  bool get tieneUltimaConexion => fechaUltimaConexion != null;
  bool get perteneceAEscuela => escuelaId != null;

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
