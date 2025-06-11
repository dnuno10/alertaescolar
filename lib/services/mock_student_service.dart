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
      grado: '5°',
      grupo: 'A',
      escuelaId: 'escuela_001',
      llave: 'ESC001-2024',
      activo: true,
      fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
      turno: Turno.matutino,
      tutoresIds: ['tutor_001', 'tutor_002'],
    ),
    Alumno(
      id: 'alumno_002',
      nombre: 'Ana Sofía González',
      grado: '2°',
      grupo: 'B',
      escuelaId: 'escuela_001',
      llave: 'ESC002-2024',
      activo: true,
      fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
      turno: Turno.vespertino,
      tutoresIds: ['tutor_003'],
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
      fechaRegistro: DateTime.now(),
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
}
