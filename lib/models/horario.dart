enum DiaSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo,
}

class Materia {
  final String id;
  final String nombre;
  final String profesor;
  final String aula;
  final String color;

  const Materia({
    required this.id,
    required this.nombre,
    required this.profesor,
    required this.aula,
    this.color = '#9B5DE5',
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      profesor: json['profesor'] ?? '',
      aula: json['aula'] ?? '',
      color: json['color'] ?? '#9B5DE5',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'profesor': profesor,
      'aula': aula,
      'color': color,
    };
  }
}

class ClaseHorario {
  final String id;
  final String materiaId;
  final String alumnoId;
  final DiaSemana dia;
  final String horaInicio;
  final String horaFin;
  final String aula;

  const ClaseHorario({
    required this.id,
    required this.materiaId,
    required this.alumnoId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });

  factory ClaseHorario.fromJson(Map<String, dynamic> json) {
    return ClaseHorario(
      id: json['id'] ?? '',
      materiaId: json['materiaId'] ?? '',
      alumnoId: json['alumnoId'] ?? '',
      dia: DiaSemana.values.firstWhere(
        (d) => d.name == json['dia'],
        orElse: () => DiaSemana.lunes,
      ),
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      aula: json['aula'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materiaId': materiaId,
      'alumnoId': alumnoId,
      'dia': dia.name,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'aula': aula,
    };
  }

  ClaseHorario copyWith({
    String? id,
    String? materiaId,
    String? alumnoId,
    DiaSemana? dia,
    String? horaInicio,
    String? horaFin,
    String? aula,
  }) {
    return ClaseHorario(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      alumnoId: alumnoId ?? this.alumnoId,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      aula: aula ?? this.aula,
    );
  }

  String get horarioTexto => '$horaInicio - $horaFin';

  String get diaNombre {
    switch (dia) {
      case DiaSemana.lunes:
        return 'Lunes';
      case DiaSemana.martes:
        return 'Martes';
      case DiaSemana.miercoles:
        return 'Miércoles';
      case DiaSemana.jueves:
        return 'Jueves';
      case DiaSemana.viernes:
        return 'Viernes';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }

  @override
  String toString() {
    return 'ClaseHorario(id: $id, materiaId: $materiaId, dia: $diaNombre, horario: $horarioTexto, aula: $aula)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClaseHorario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
