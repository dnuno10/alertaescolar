enum TurnoEnum {
  matutino,
  vespertino,
}

class Alumno {
  final String id;
  final String nombre;
  final String id_grupo;
  final String grupo; // Add this field to store the group name
  final String id_escuela;
  final String id_llave;
  final bool vinculado;
  final String matricula;
  final DateTime fecha_registro;
  final TurnoEnum turno;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.id_grupo,
    required this.grupo, // Add this parameter
    required this.id_escuela,
    required this.id_llave,
    this.vinculado = true,
    required this.matricula,
    required this.fecha_registro,
    this.turno = TurnoEnum.matutino,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      id_grupo: json['id_grupo'] ?? '',
      grupo: json['grupo'] ?? '', // Add this field
      id_escuela: json['id_escuela'] ?? '',
      id_llave: json['id_llave'] ?? '',
      vinculado: json['vinculado'] ?? true,
      matricula: json['matricula'] ?? '',
      fecha_registro: DateTime.parse(json['fecha_registro']),
      turno: TurnoEnum.values.firstWhere(
        (e) => e.name == json['turno'],
        orElse: () => TurnoEnum.matutino,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'id_grupo': id_grupo,
      'grupo': grupo, // Add this field
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
    String? id_grupo,
    String? grupo, // Add this parameter
    String? id_escuela,
    String? id_llave,
    bool? vinculado,
    String? matricula,
    DateTime? fecha_registro,
    TurnoEnum? turno,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      id_grupo: id_grupo ?? this.id_grupo,
      grupo: grupo ?? this.grupo, // Add this field
      id_escuela: id_escuela ?? this.id_escuela,
      id_llave: id_llave ?? this.id_llave,
      vinculado: vinculado ?? this.vinculado,
      matricula: matricula ?? this.matricula,
      fecha_registro: fecha_registro ?? this.fecha_registro,
      turno: turno ?? this.turno,
    );
  }

  bool get esMatutino => turno == TurnoEnum.matutino;
  bool get esVespertino => turno == TurnoEnum.vespertino;

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, matricula: $matricula, id_grupo: $id_grupo, grupo: $grupo, turno: $turno, vinculado: $vinculado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
