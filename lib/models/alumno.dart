enum TurnoEnum {
  matutino,
  vespertino,
  desconocido, // fallback en caso de que no se pueda mapear
}

class Alumno {
  final String id;
  final String nombre;
  final String idGrupo;
  final String grupo; // viene de la tabla grupos (join)
  final String idEscuela;
  final String matricula;
  final DateTime fechaRegistro;
  final String idTurno; // FK a tabla turnos
  final TurnoEnum turno; // se deriva de turnos.turno
  final String? idLlave; // FK opcional de llaves.id
  final bool vinculado; // viene de llaves.activo

  const Alumno({
    required this.id,
    required this.nombre,
    required this.idGrupo,
    required this.grupo,
    required this.idEscuela,
    required this.matricula,
    required this.fechaRegistro,
    required this.idTurno,
    this.turno = TurnoEnum.desconocido,
    this.idLlave,
    this.vinculado = false,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      idGrupo: json['id_grupo'] ?? '',
      grupo: json['grupo'] ?? '',
      idEscuela: json['id_escuela'] ?? '',
      matricula: json['matricula'] ?? '',
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      idTurno: json['id_turno'] ?? '',
      turno: _mapTurno(json['turno']),
      idLlave: json['id_llave'], // puede venir de un join con llaves
      vinculado: json['vinculado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'id_grupo': idGrupo,
      'grupo': grupo,
      'id_escuela': idEscuela,
      'matricula': matricula,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'id_turno': idTurno,
      'turno': turno.name,
      'id_llave': idLlave,
      'vinculado': vinculado,
    };
  }

  Alumno copyWith({
    String? id,
    String? nombre,
    String? idGrupo,
    String? grupo,
    String? idEscuela,
    String? matricula,
    DateTime? fechaRegistro,
    String? idTurno,
    TurnoEnum? turno,
    String? idLlave,
    bool? vinculado,
  }) {
    return Alumno(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      idGrupo: idGrupo ?? this.idGrupo,
      grupo: grupo ?? this.grupo,
      idEscuela: idEscuela ?? this.idEscuela,
      matricula: matricula ?? this.matricula,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idTurno: idTurno ?? this.idTurno,
      turno: turno ?? this.turno,
      idLlave: idLlave ?? this.idLlave,
      vinculado: vinculado ?? this.vinculado,
    );
  }

  static TurnoEnum _mapTurno(dynamic value) {
    if (value == null) return TurnoEnum.desconocido;
    final val = value.toString().toLowerCase();
    if (val.contains('vespertino')) return TurnoEnum.vespertino;
    if (val.contains('matutino')) return TurnoEnum.matutino;
    return TurnoEnum.desconocido;
  }

  @override
  String toString() {
    return 'Alumno(id: $id, nombre: $nombre, matricula: $matricula, idGrupo: $idGrupo, grupo: $grupo, turno: $turno, vinculado: $vinculado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alumno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
