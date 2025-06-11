import '../models/models.dart';

class MockScheduleService {
  // Simular delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  // Materias disponibles
  static final List<Materia> _materias = [
    Materia(
      id: 'mat_001',
      nombre: 'Matemáticas',
      profesor: 'Prof. María González',
      aula: 'Aula 101',
      color: '#3A86FF',
    ),
    Materia(
      id: 'mat_002',
      nombre: 'Español',
      profesor: 'Prof. Luis Rodríguez',
      aula: 'Aula 102',
      color: '#00C896',
    ),
    Materia(
      id: 'mat_003',
      nombre: 'Ciencias Naturales',
      profesor: 'Prof. Ana Martínez',
      aula: 'Laboratorio',
      color: '#9B5DE5',
    ),
    Materia(
      id: 'mat_004',
      nombre: 'Historia',
      profesor: 'Prof. Carlos López',
      aula: 'Aula 103',
      color: '#FF6B35',
    ),
    Materia(
      id: 'mat_005',
      nombre: 'Educación Física',
      profesor: 'Prof. Roberto Silva',
      aula: 'Gimnasio',
      color: '#FDCB5A',
    ),
    Materia(
      id: 'mat_006',
      nombre: 'Inglés',
      profesor: 'Prof. Sandra Torres',
      aula: 'Aula 104',
      color: '#F72585',
    ),
    Materia(
      id: 'mat_007',
      nombre: 'Arte',
      profesor: 'Prof. Elena Vega',
      aula: 'Taller de Arte',
      color: '#4CC9F0',
    ),
    Materia(
      id: 'mat_008',
      nombre: 'Recreo',
      profesor: '',
      aula: 'Patio',
      color: '#90E0EF',
    ),
  ];

  // Horarios por estudiante
  static final Map<String, List<ClaseHorario>> _schedules = {
    'alumno_001': [
      // Lunes
      ClaseHorario(
        id: 'clase_001',
        materiaId: 'mat_001',
        alumnoId: 'alumno_001',
        dia: DiaSemana.lunes,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Aula 101',
      ),
      ClaseHorario(
        id: 'clase_002',
        materiaId: 'mat_002',
        alumnoId: 'alumno_001',
        dia: DiaSemana.lunes,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Aula 102',
      ),
      ClaseHorario(
        id: 'clase_003',
        materiaId: 'mat_008',
        alumnoId: 'alumno_001',
        dia: DiaSemana.lunes,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_004',
        materiaId: 'mat_003',
        alumnoId: 'alumno_001',
        dia: DiaSemana.lunes,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Laboratorio',
      ),
      ClaseHorario(
        id: 'clase_005',
        materiaId: 'mat_004',
        alumnoId: 'alumno_001',
        dia: DiaSemana.lunes,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Aula 103',
      ),

      // Martes
      ClaseHorario(
        id: 'clase_006',
        materiaId: 'mat_002',
        alumnoId: 'alumno_001',
        dia: DiaSemana.martes,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Aula 102',
      ),
      ClaseHorario(
        id: 'clase_007',
        materiaId: 'mat_001',
        alumnoId: 'alumno_001',
        dia: DiaSemana.martes,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Aula 101',
      ),
      ClaseHorario(
        id: 'clase_008',
        materiaId: 'mat_008',
        alumnoId: 'alumno_001',
        dia: DiaSemana.martes,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_009',
        materiaId: 'mat_006',
        alumnoId: 'alumno_001',
        dia: DiaSemana.martes,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Aula 104',
      ),
      ClaseHorario(
        id: 'clase_010',
        materiaId: 'mat_005',
        alumnoId: 'alumno_001',
        dia: DiaSemana.martes,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Gimnasio',
      ),

      // Miércoles
      ClaseHorario(
        id: 'clase_011',
        materiaId: 'mat_003',
        alumnoId: 'alumno_001',
        dia: DiaSemana.miercoles,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Laboratorio',
      ),
      ClaseHorario(
        id: 'clase_012',
        materiaId: 'mat_001',
        alumnoId: 'alumno_001',
        dia: DiaSemana.miercoles,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Aula 101',
      ),
      ClaseHorario(
        id: 'clase_013',
        materiaId: 'mat_008',
        alumnoId: 'alumno_001',
        dia: DiaSemana.miercoles,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_014',
        materiaId: 'mat_007',
        alumnoId: 'alumno_001',
        dia: DiaSemana.miercoles,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Taller de Arte',
      ),
      ClaseHorario(
        id: 'clase_015',
        materiaId: 'mat_002',
        alumnoId: 'alumno_001',
        dia: DiaSemana.miercoles,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Aula 102',
      ),

      // Jueves
      ClaseHorario(
        id: 'clase_016',
        materiaId: 'mat_004',
        alumnoId: 'alumno_001',
        dia: DiaSemana.jueves,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Aula 103',
      ),
      ClaseHorario(
        id: 'clase_017',
        materiaId: 'mat_006',
        alumnoId: 'alumno_001',
        dia: DiaSemana.jueves,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Aula 104',
      ),
      ClaseHorario(
        id: 'clase_018',
        materiaId: 'mat_008',
        alumnoId: 'alumno_001',
        dia: DiaSemana.jueves,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_019',
        materiaId: 'mat_001',
        alumnoId: 'alumno_001',
        dia: DiaSemana.jueves,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Aula 101',
      ),
      ClaseHorario(
        id: 'clase_020',
        materiaId: 'mat_003',
        alumnoId: 'alumno_001',
        dia: DiaSemana.jueves,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Laboratorio',
      ),

      // Viernes
      ClaseHorario(
        id: 'clase_021',
        materiaId: 'mat_005',
        alumnoId: 'alumno_001',
        dia: DiaSemana.viernes,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Gimnasio',
      ),
      ClaseHorario(
        id: 'clase_022',
        materiaId: 'mat_007',
        alumnoId: 'alumno_001',
        dia: DiaSemana.viernes,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Taller de Arte',
      ),
      ClaseHorario(
        id: 'clase_023',
        materiaId: 'mat_008',
        alumnoId: 'alumno_001',
        dia: DiaSemana.viernes,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_024',
        materiaId: 'mat_002',
        alumnoId: 'alumno_001',
        dia: DiaSemana.viernes,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Aula 102',
      ),
      ClaseHorario(
        id: 'clase_025',
        materiaId: 'mat_006',
        alumnoId: 'alumno_001',
        dia: DiaSemana.viernes,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Aula 104',
      ),
    ],
    'alumno_002': [
      // Horario similar pero para secundaria
      // Lunes
      ClaseHorario(
        id: 'clase_101',
        materiaId: 'mat_001',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '07:00',
        horaFin: '08:00',
        aula: 'Aula 101',
      ),
      ClaseHorario(
        id: 'clase_102',
        materiaId: 'mat_002',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '08:00',
        horaFin: '09:00',
        aula: 'Aula 102',
      ),
      ClaseHorario(
        id: 'clase_103',
        materiaId: 'mat_006',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '09:00',
        horaFin: '10:00',
        aula: 'Aula 104',
      ),
      ClaseHorario(
        id: 'clase_104',
        materiaId: 'mat_008',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '10:00',
        horaFin: '10:30',
        aula: 'Patio',
      ),
      ClaseHorario(
        id: 'clase_105',
        materiaId: 'mat_003',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '10:30',
        horaFin: '11:30',
        aula: 'Laboratorio',
      ),
      ClaseHorario(
        id: 'clase_106',
        materiaId: 'mat_004',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '11:30',
        horaFin: '12:30',
        aula: 'Aula 103',
      ),
      ClaseHorario(
        id: 'clase_107',
        materiaId: 'mat_005',
        alumnoId: 'alumno_002',
        dia: DiaSemana.lunes,
        horaInicio: '12:30',
        horaFin: '13:30',
        aula: 'Gimnasio',
      ),
    ],
  };

  Future<List<ClaseHorario>> getStudentSchedule(String studentId) async {
    await _simulateNetworkDelay();

    final schedule = _schedules[studentId] ?? [];
    return List.from(schedule);
  }

  Future<List<ClaseHorario>> getScheduleByDay(
      String studentId, DiaSemana day) async {
    await _simulateNetworkDelay();

    final allSchedule = _schedules[studentId] ?? [];
    return allSchedule.where((clase) => clase.dia == day).toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
  }

  Future<List<Materia>> getMaterias() async {
    await _simulateNetworkDelay();
    return List.from(_materias);
  }

  Map<DiaSemana, List<ClaseHorario>> organizeScheduleByDay(
      List<ClaseHorario> schedule) {
    final Map<DiaSemana, List<ClaseHorario>> organized = {};

    for (final dia in DiaSemana.values) {
      organized[dia] = schedule.where((clase) => clase.dia == dia).toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    return organized;
  }
}
