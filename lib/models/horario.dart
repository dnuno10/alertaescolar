import '../utils/time_format.dart';

class Materia {
  final String id;
  final String idEscuela;
  final String nombre;
  final String profesor;
  final String color;
  final DateTime fechaRegistro;

  const Materia({
    required this.id,
    required this.idEscuela,
    required this.nombre,
    required this.profesor,
    this.color = '#9B5DE5',
    required this.fechaRegistro,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] ?? '',
      idEscuela: json['id_escuela'] ?? '',
      nombre: json['nombre'] ?? '',
      profesor: json['profesor'] ?? '',
      color: json['color'] ?? '#9B5DE5',
      fechaRegistro: DateTime.parse(
          json['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_escuela': idEscuela,
      'nombre': nombre,
      'profesor': profesor,
      'color': color,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}

class ClaseHorario {
  final String id;
  final String idMateria;
  final String idEscuela;
  final String idGrupo;
  final bool lunes;
  final bool martes;
  final bool miercoles;
  final bool jueves;
  final bool viernes;
  final bool sabado;
  final bool domingo;
  final String horaInicio;
  final String horaFin;
  final String aula;
  final DateTime fechaRegistro;

  const ClaseHorario({
    required this.id,
    required this.idMateria,
    required this.idEscuela,
    required this.idGrupo,
    this.lunes = false,
    this.martes = false,
    this.miercoles = false,
    this.jueves = false,
    this.viernes = false,
    this.sabado = false,
    this.domingo = false,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
    required this.fechaRegistro,
  });

  factory ClaseHorario.fromJson(Map<String, dynamic> json) {
    return ClaseHorario(
      id: json['id'] ?? '',
      idMateria: json['id_materia'] ?? '',
      idEscuela: json['id_escuela'] ?? '',
      idGrupo: json['id_grupo'] ?? '',
      lunes: json['lunes'] ?? false,
      martes: json['martes'] ?? false,
      miercoles: json['miercoles'] ?? false,
      jueves: json['jueves'] ?? false,
      viernes: json['viernes'] ?? false,
      sabado: json['sabado'] ?? false,
      domingo: json['domingo'] ?? false,
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      aula: json['aula'] ?? '',
      fechaRegistro: DateTime.parse(
          json['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_materia': idMateria,
      'id_escuela': idEscuela,
      'id_grupo': idGrupo,
      'lunes': lunes,
      'martes': martes,
      'miercoles': miercoles,
      'jueves': jueves,
      'viernes': viernes,
      'sabado': sabado,
      'domingo': domingo,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'aula': aula,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  String get horaInicioAmPm => TimeFormat.format24to12(horaInicio);
  String get horaFinAmPm => TimeFormat.format24to12(horaFin);

  String get horarioLimpio => '$horaInicioAmPm - $horaFinAmPm';
}
