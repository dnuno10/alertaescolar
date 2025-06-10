enum Turno {
  matutino,
  vespertino,
}

class Alumno {
  final String id;
  final String nombre;
  final String grado;
  final String llave;
  final String? fotoUrl;
  final bool activo;
  final Turno turno;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.llave,
    this.fotoUrl,
    this.activo = true,
    required this.turno,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      grado: json['grado'] ?? '',
      llave: json['llave'] ?? '',
      fotoUrl: json['fotoUrl'],
      activo: json['activo'] ?? true,
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
      'llave': llave,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'turno': turno.name,
    };
  }

  Alumno copyWith({
    String? id,
    String? nombre,
    String? grado,
    String? llave,
    String? fotoUrl,
    bool? activo,
    Turno? turno,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      llave: llave ?? this.llave,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      turno: turno ?? this.turno,
    );
  }

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, grado: $grado, llave: $llave, activo: $activo, turno: $turno)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
