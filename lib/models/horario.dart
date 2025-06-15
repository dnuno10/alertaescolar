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
  final String escuelaId;

  const Materia({
    required this.id,
    required this.nombre,
    required this.profesor,
    required this.aula,
    required this.escuelaId,
    this.color = '#9B5DE5',
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      profesor: json['profesor'] ?? '',
      aula: '', // El aula está en horarios, no en materias
      escuelaId: json['id_escuela'] ?? '',
      color: json['color'] ?? '#9B5DE5',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'profesor': profesor,
      'aula': aula,
      'escuelaId': escuelaId,
      'color': color,
    };
  }

  /// Validates the materia data
  /// Returns true if all validations pass, or throws an exception with the error message
  bool validate() {
    if (id.isEmpty) {
      throw Exception('El ID de la materia no puede estar vacío');
    }

    if (nombre.isEmpty) {
      throw Exception('El nombre de la materia no puede estar vacío');
    }

    if (escuelaId.isEmpty) {
      throw Exception('La materia debe estar asociada a una escuela');
    }

    return true;
  }

  /// Validates that this materia belongs to the specified school
  bool belongsToSchool(String schoolId) {
    return escuelaId == schoolId;
  }
}

class ClaseHorario {
  final String id;
  final String materiaId;
  final String escuelaId;
  final String grupo;
  final DiaSemana dia;
  final String horaInicio;
  final String horaFin;
  final String aula;

  const ClaseHorario({
    required this.id,
    required this.materiaId,
    required this.escuelaId,
    required this.grupo,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });

  factory ClaseHorario.fromJson(Map<String, dynamic> json) {
    return ClaseHorario(
      id: json['id'] ?? '',
      materiaId: json['materiaId'] ?? '',
      escuelaId: json['escuelaId'] ?? '',
      grupo: json['grupo'] ?? '',
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
      'escuelaId': escuelaId,
      'grupo': grupo,
      'dia': dia.name,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'aula': aula,
    };
  }

  ClaseHorario copyWith({
    String? id,
    String? materiaId,
    String? escuelaId,
    String? grupo,
    DiaSemana? dia,
    String? horaInicio,
    String? horaFin,
    String? aula,
  }) {
    return ClaseHorario(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      escuelaId: escuelaId ?? this.escuelaId,
      grupo: grupo ?? this.grupo,
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

  /// Validates the horario data
  /// Returns true if all validations pass, or throws an exception with the error message
  bool validate() {
    if (id.isEmpty) {
      throw Exception('El ID del horario no puede estar vacío');
    }

    if (materiaId.isEmpty) {
      throw Exception('El horario debe estar asociado a una materia');
    }

    if (escuelaId.isEmpty) {
      throw Exception('El horario debe estar asociado a una escuela');
    }

    if (grupo.isEmpty) {
      throw Exception('El horario debe estar asociado a un grupo');
    }

    if (horaInicio.isEmpty || horaFin.isEmpty) {
      throw Exception('El horario debe tener hora de inicio y fin');
    }

    // Basic time format validation (could be expanded)
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(horaInicio)) {
      throw Exception('El formato de la hora de inicio no es válido (HH:MM)');
    }

    if (!timeRegex.hasMatch(horaFin)) {
      throw Exception('El formato de la hora de fin no es válido (HH:MM)');
    }

    // Validate that end time is after start time
    final start = _parseTimeString(horaInicio);
    final end = _parseTimeString(horaFin);
    if (end.compareTo(start) <= 0) {
      throw Exception('La hora de fin debe ser posterior a la hora de inicio');
    }

    return true;
  }

  /// Helper method to parse a time string into a DateTime for comparison
  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Validates that this clase horario belongs to the specified school
  bool belongsToSchool(String schoolId) {
    return escuelaId == schoolId;
  }

  /// Validates that this clase horario is for the specified group
  bool belongsToGroup(String groupId) {
    return grupo == groupId;
  }

  /// Validates that this clase horario is consistent with the provided subject
  bool isConsistentWithSubject(Materia materia) {
    // Make sure the subject ID matches
    if (materiaId != materia.id) {
      return false;
    }

    // Make sure both belong to the same school
    if (escuelaId != materia.escuelaId) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'ClaseHorario(id: $id, materiaId: $materiaId, escuelaId: $escuelaId, grupo: $grupo, dia: $diaNombre, horario: $horarioTexto, aula: $aula)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClaseHorario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
