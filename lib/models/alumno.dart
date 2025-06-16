enum Turno {
  matutino,
  vespertino,
}

class Alumno {
  final String id;
  final String nombre;
  final String grupo;
  final String id_escuela;
  final String id_llave;
  final bool vinculado;
  final String matricula;
  final DateTime fecha_registro;
  final Turno turno;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.grupo,
    required this.id_escuela,
    required this.id_llave,
    this.vinculado = true,
    required this.matricula,
    required this.fecha_registro,
    this.turno = Turno.matutino,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      grupo: json['grupo'] ?? '',
      id_escuela: json['id_escuela'] ?? '',
      id_llave: json['id_llave'] ?? '',
      vinculado: json['vinculado'] ?? true,
      matricula: json['matricula'] ?? '',
      fecha_registro: DateTime.parse(json['fecha_registro']),
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
      'grupo': grupo,
      'id_escuela': id_escuela,
      'id_llave': id_llave,
      'vinculado': vinculado,
      'matricula': matricula,
      'fecha_registro': fecha_registro.toIso8601String(),
      'turno': turno.name,
    };
  }

  Alumno copyWith({
    String? id,
    String? nombre,
    String? grupo,
    String? id_escuela,
    String? id_llave,
    bool? vinculado,
    String? matricula,
    DateTime? fecha_registro,
    Turno? turno,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grupo: grupo ?? this.grupo,
      id_escuela: id_escuela ?? this.id_escuela,
      id_llave: id_llave ?? this.id_llave,
      vinculado: vinculado ?? this.vinculado,
      matricula: matricula ?? this.matricula,
      fecha_registro: fecha_registro ?? this.fecha_registro,
      turno: turno ?? this.turno,
    );
  }

  bool get esMatutino => turno == Turno.matutino;
  bool get esVespertino => turno == Turno.vespertino;

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, matricula: $matricula, grupo: $grupo, turno: $turno, vinculado: $vinculado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
