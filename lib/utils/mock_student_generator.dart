import '../models/models.dart';

class MockStudentGenerator {
  static List<Alumno> getMockStudents() {
    return [
      Alumno(
        id: '1',
        nombre: 'Ana García López',
        grado: '6° A',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU001',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Alumno(
        id: '2',
        nombre: 'Carlos Mendoza Ruiz',
        grado: '5° B',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU002',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Alumno(
        id: '3',
        nombre: 'María Fernández Castro',
        grado: '4° C',
        grupo: 'C',
        escuelaId: 'ESC001',
        llave: 'STU003',
        activo: false,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Alumno(
        id: '4',
        nombre: 'José Luis Herrera',
        grado: '6° A',
        grupo: 'A',
        escuelaId: 'ESC001',
        llave: 'STU004',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Alumno(
        id: '5',
        nombre: 'Sofia Rodriguez',
        grado: '3° B',
        grupo: 'B',
        escuelaId: 'ESC001',
        llave: 'STU005',
        activo: true,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}
