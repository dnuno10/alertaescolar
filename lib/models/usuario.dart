enum TipoUsuario { padre, madre, tutor, familiar, admin }

class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final TipoUsuario tipo;
  final List<String> alumnosIds;
  final String? fotoUrl;
  final bool activo;
  final DateTime fechaRegistro;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.tipo = TipoUsuario.padre,
    this.alumnosIds = const [],
    this.fotoUrl,
    this.activo = true,
    required this.fechaRegistro,
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
      alumnosIds: List<String>.from(json['alumnosIds'] ?? []),
      fotoUrl: json['fotoUrl'],
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
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
      'alumnosIds': alumnosIds,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    TipoUsuario? tipo,
    List<String>? alumnosIds,
    String? fotoUrl,
    bool? activo,
    DateTime? fechaRegistro,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      tipo: tipo ?? this.tipo,
      alumnosIds: alumnosIds ?? this.alumnosIds,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
  bool get tieneAlumnos => alumnosIds.isNotEmpty;

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
