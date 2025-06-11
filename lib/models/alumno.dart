enum Turno {
  matutino,
  vespertino,
}

class Alumno {
  final String id;
  final String nombre;
  final String grado;
  final String grupo;
  final String escuelaId;
  final String? fotoUrl;
  final String llave;
  final bool activo;
  final DateTime fechaRegistro;
  final List<String> tutoresIds;
  final Turno turno;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.grupo,
    required this.escuelaId,
    this.fotoUrl,
    required this.llave,
    this.activo = true,
    required this.fechaRegistro,
    this.tutoresIds = const [],
    this.turno = Turno.matutino,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      grado: json['grado'] ?? '',
      grupo: json['grupo'] ?? '',
      escuelaId: json['escuelaId'] ?? '',
      fotoUrl: json['fotoUrl'],
      llave: json['llave'] ?? '',
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      tutoresIds: List<String>.from(json['tutoresIds'] ?? []),
      turno: Turno.values.firstWhere(
        (e) => e.name == json['turno'],
        orElse: () => Turno.matutino,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'grado': grado,
      'grupo': grupo,
      'escuelaId': escuelaId,
      'fotoUrl': fotoUrl,
      'llave': llave,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'tutoresIds': tutoresIds,
      'turno': turno.name,
    };
  }

  Alumno copyWith({
    String? id,
    String? nombre,
    String? grado,
    String? grupo,
    String? escuelaId,
    String? fotoUrl,
    String? llave,
    bool? activo,
    DateTime? fechaRegistro,
    List<String>? tutoresIds,
    Turno? turno,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      grupo: grupo ?? this.grupo,
      escuelaId: escuelaId ?? this.escuelaId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      llave: llave ?? this.llave,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      tutoresIds: tutoresIds ?? this.tutoresIds,
      turno: turno ?? this.turno,
    );
  }

  bool get tieneTutores => tutoresIds.isNotEmpty;
  String get gradoCompleto => '$grado$grupo';
  bool get esMatutino => turno == Turno.matutino;
  bool get esVespertino => turno == Turno.vespertino;

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, grado: $grado, grupo: $grupo, turno: $turno, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
