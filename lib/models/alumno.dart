class Alumno {
  final String id;
  final String nombre;
  final String grado;
  final String llave;
  final String? fotoUrl;
  final bool activo;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.llave,
    this.fotoUrl,
    this.activo = true,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      grado: json['grado'] ?? '',
      llave: json['llave'] ?? '',
      fotoUrl: json['fotoUrl'],
      activo: json['activo'] ?? true,
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
    };
  }

  Alumno copyWith({
    String? id,
    String? nombre,
    String? grado,
    String? llave,
    String? fotoUrl,
    bool? activo,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      llave: llave ?? this.llave,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, grado: $grado, llave: $llave, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
