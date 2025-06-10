import '../models/models.dart';

class MockStudentService {
  // Simular delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // Lista de alumnos mock
  static final List<Alumno> _students = [
    Alumno(
      id: 'alumno_001',
      nombre: 'Carlos Alberto González',
      grado: '5° Primaria',
      llave: 'ESC001-2024',
      activo: true,
    ),
    Alumno(
      id: 'alumno_002',
      nombre: 'Ana Sofía González',
      grado: '2° Secundaria',
      llave: 'ESC002-2024',
      activo: true,
    ),
  ];

  Future<List<Alumno>> getStudents() async {
    await _simulateNetworkDelay();
    return List.from(_students);
  }

  Future<Alumno> getStudentById(String id) async {
    await _simulateNetworkDelay();

    final student = _students.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Alumno no encontrado'),
    );

    return student;
  }

  Future<Alumno> addStudent(Alumno student) async {
    await _simulateNetworkDelay();

    // Generar nuevo ID
    final newId = 'alumno_${DateTime.now().millisecondsSinceEpoch}';
    final newStudent = student.copyWith(
      id: newId,
      llave: 'ESC${newId.substring(7)}-2024',
    );

    _students.add(newStudent);
    return newStudent;
  }

  Future<Alumno> updateStudent(Alumno student) async {
    await _simulateNetworkDelay();

    final index = _students.indexWhere((s) => s.id == student.id);
    if (index == -1) {
      throw Exception('Alumno no encontrado');
    }

    _students[index] = student;
    return student;
  }

  Future<void> removeStudent(String studentId) async {
    await _simulateNetworkDelay();

    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) {
      throw Exception('Alumno no encontrado');
    }

    _students.removeAt(index);
  }

  Future<List<Asistencia>> getStudentAttendance(
    String studentId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await _simulateNetworkDelay();

    // Generar asistencias mock para los últimos 7 días
    final now = DateTime.now();
    final attendances = <Asistencia>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);

      // Skip weekends
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      EstadoAsistencia estado;
      DateTime? entryTime;
      DateTime? exitTime;

      // Simular diferentes estados
      if (i == 0) {
        // Hoy - presente
        estado = EstadoAsistencia.presente;
        entryTime = DateTime(date.year, date.month, date.day, 7, 45);
        exitTime = DateTime(date.year, date.month, date.day, 14, 30);
      } else if (i == 1) {
        // Ayer - tarde
        estado = EstadoAsistencia.tarde;
        entryTime = DateTime(date.year, date.month, date.day, 8, 15);
        exitTime = DateTime(date.year, date.month, date.day, 14, 30);
      } else if (i == 3) {
        // Ausente
        estado = EstadoAsistencia.ausente;
      } else {
        // Presente normal
        estado = EstadoAsistencia.presente;
        entryTime = DateTime(date.year, date.month, date.day, 7, 30);
        exitTime = DateTime(date.year, date.month, date.day, 14, 30);
      }

      attendances.add(Asistencia(
        id: 'asistencia_${studentId}_${date.millisecondsSinceEpoch}',
        alumnoId: studentId,
        fecha: date,
        horaEntrada: entryTime,
        horaSalida: exitTime,
        estado: estado,
        observaciones: estado == EstadoAsistencia.tarde
            ? 'Llegada tardía por tráfico'
            : estado == EstadoAsistencia.ausente
                ? 'Falta justificada - cita médica'
                : null,
      ));
    }

    return attendances;
  }
}
