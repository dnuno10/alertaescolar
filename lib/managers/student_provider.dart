import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../models/alumno.dart';

class StudentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<StudentDetails> _students = [];
  List<StudentDetails> _filteredStudents = [];
  StudentDetails? _selectedStudent;

  bool _isLoading = false;
  String? _error;

  // Track the loading mode to prevent unwanted overwrites
  String? _currentLoadingMode; // 'admin', 'user', or null

  // Getters
  List<StudentDetails> get students => _students;
  List<StudentDetails> get filteredStudents => _filteredStudents;
  StudentDetails? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    _error = null;
    // Use Future.microtask to avoid calling during build
    Future.microtask(() => notifyListeners());
  }

  // Get user's school ID based on their students (tutor relationship)
  Future<String?> getUserSchoolId(String userId) async {
    try {
      final response = await _supabase.from('alumno_tutores').select('''
            alumnos!inner(
              id_escuela
            )
          ''').eq('id_tutor', userId).limit(1);

      if (response.isNotEmpty) {
        final alumno = response[0]['alumnos'];
        return alumno['id_escuela'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user school ID: $e');
      return null;
    }
  }

  // Load students for current user (based on tutor relationship)
  Future<void> loadStudentsForUser({
    required String userId,
    String? grupoId,
    String? turnoId,
    bool forceReload = false,
  }) async {
    // Don't override admin students unless forced
    if (_currentLoadingMode == 'admin' && !forceReload) {
      debugPrint(
          'Skipping loadStudentsForUser - admin students already loaded');
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentLoadingMode = 'user';
      Future.microtask(() => notifyListeners());

      // Get students that this user is tutor of
      final response = await _supabase.from('alumno_tutores').select('''
            alumnos!inner(
              id,
              nombre,
              matricula,
              fecha_registro,
              id_grupo,
              id_turno,
              id_escuela,
              grupos!inner(
                id,
                grupo,
                nivel_educativo
              ),
              turnos(
                id,
                turno,
                hora_inicio,
                hora_fin
              ),
              llaves(
                id,
                codigo,
                activo,
                fecha_desactivacion,
                limite_vinculacion
              )
            )
          ''').eq('id_tutor', userId);

      final studentsList = <StudentDetails>[];

      for (final item in response) {
        final alumnoData = item['alumnos'];

        // Add tutor info to the student data
        alumnoData['alumno_tutores'] = [
          {
            'id_tutor': userId,
            'fecha_vinculacion':
                item['fecha_vinculacion'] ?? DateTime.now().toIso8601String(),
            'usuarios': {
              'id': userId,
              'nombre': '', // Will be filled by user provider if needed
              'apellido': '',
              'email': '',
            }
          }
        ];

        studentsList.add(_mapToStudentDetails(alumnoData));
      }

      _students = studentsList;
      _filteredStudents = List.from(_students);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar estudiantes del usuario: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Load all students for a school with complete details
  Future<void> loadStudents({
    String? escuelaId,
    String? userId, // If provided, will get escuelaId from user's students
    String? grupoId,
    String? turnoId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _currentLoadingMode = 'admin';
      Future.microtask(() => notifyListeners());

      String? schoolId = escuelaId;

      // If userId is provided but no escuelaId, get it from user's students
      if (userId != null && schoolId == null) {
        schoolId = await getUserSchoolId(userId);
        if (schoolId == null) {
          throw Exception('No se encontró escuela asociada al usuario');
        }
      }

      // If no schoolId found, throw error
      if (schoolId == null) {
        throw Exception(
            'Se requiere escuelaId o userId para cargar estudiantes');
      }

      // Build query with joins - make some joins optional
      var query = _supabase.from('alumnos').select('''
            id,
            nombre,
            matricula,
            fecha_registro,
            id_grupo,
            id_turno,
            id_escuela,
            grupos(
              id,
              grupo,
              nivel_educativo
            ),
            turnos(
              id,
              turno,
              hora_inicio,
              hora_fin
            ),
            llaves(
              id,
              codigo,
              activo,
              fecha_desactivacion,
              limite_vinculacion
            ),
            alumno_tutores(
              id_tutor,
              fecha_vinculacion,
              usuarios(
                id,
                nombre,
                apellido,
                email
              )
            )
          ''').eq('id_escuela', schoolId);

      // Add filters if provided
      if (grupoId != null) {
        query = query.eq('id_grupo', grupoId);
      }
      if (turnoId != null) {
        query = query.eq('id_turno', turnoId);
      }

      final response = await query.order('nombre');

      _students =
          (response as List).map((item) => _mapToStudentDetails(item)).toList();

      // Initialize filtered students with all students
      _filteredStudents = List.from(_students);
      _error = null;

      debugPrint('Loaded ${_students.length} students from database');
    } catch (e) {
      _error = 'Error al cargar estudiantes: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Load student by ID with complete details
  Future<StudentDetails?> loadStudentById({
    required String studentId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final response = await _supabase.from('alumnos').select('''
            id,
            nombre,
            matricula,
            fecha_registro,
            id_grupo,
            id_turno,
            grupos!inner(
              id,
              grupo,
              nivel_educativo
            ),
            turnos(
              id,
              turno,
              hora_inicio,
              hora_fin
            ),
            llaves(
              id,
              codigo,
              activo,
              fecha_desactivacion,
              limite_vinculacion
            ),
            alumno_tutores(
              id_tutor,
              fecha_vinculacion,
              usuarios!inner(
                id,
                nombre,
                apellido,
                email
              )
            )
          ''').eq('id', studentId).single();

      _selectedStudent = _mapToStudentDetails(response);
      return _selectedStudent;
    } catch (e) {
      _error = 'Error al cargar detalles del estudiante: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Filter students
  void filterStudents({
    String? searchQuery,
    String? grado,
    String? grupo,
    String? status,
    String? turno,
  }) {
    debugPrint(
        'filterStudents called with: searchQuery="$searchQuery", grado="$grado", grupo="$grupo", status="$status", turno="$turno"');
    debugPrint('Total students to filter: ${_students.length}');

    _filteredStudents = _students.where((student) {
      // Search filter
      bool matchesSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        matchesSearch = student.nombre.toLowerCase().contains(query) ||
            student.matricula.toLowerCase().contains(query) ||
            student.id.toLowerCase().contains(query);
      }

      // Grade filter
      bool matchesGrade = true;
      if (grado != null && grado != 'all') {
        matchesGrade = student.nivelEducativo.contains(grado);
      }

      // Group filter
      bool matchesGroup = true;
      if (grupo != null && grupo != 'all') {
        matchesGroup = student.grupo.contains(grupo);
      }

      // Status filter (based on llave activo)
      bool matchesStatus = true;
      if (status != null && status != 'all') {
        final isActive = student.llaveActiva;
        matchesStatus = (status == 'active' && isActive) ||
            (status == 'inactive' && !isActive);
      }

      // Turno filter
      bool matchesTurno = true;
      if (turno != null && turno != 'all') {
        matchesTurno = student.turno?.toLowerCase() == turno.toLowerCase();
      }

      return matchesSearch &&
          matchesGrade &&
          matchesGroup &&
          matchesStatus &&
          matchesTurno;
    }).toList();

    debugPrint('Filtered students result: ${_filteredStudents.length}');
    if (_filteredStudents.isNotEmpty) {
      debugPrint('First filtered student: ${_filteredStudents.first.nombre}');
    }

    notifyListeners();
  }

  // Add new student
  Future<StudentDetails?> addStudent({
    required String nombre,
    required String matricula,
    required String grupoId,
    required String escuelaId,
    required String turnoId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      // Insert student
      final studentResponse = await _supabase
          .from('alumnos')
          .insert({
            'nombre': nombre,
            'matricula': matricula,
            'id_grupo': grupoId,
            'id_escuela': escuelaId,
            'id_turno': turnoId,
          })
          .select()
          .single();

      final studentId = studentResponse['id'];

      // Generate and insert llave
      final llaveCode = await _generateLlaveCode(escuelaId);
      await _supabase.from('llaves').insert({
        'codigo': llaveCode,
        'id_alumno': studentId,
        'id_escuela': escuelaId,
        'activo': true,
      });

      // Reload students to get updated list
      await loadStudents(escuelaId: escuelaId);

      // Find and return the newly created student
      final newStudent = _students.firstWhere((s) => s.id == studentId);
      return newStudent;
    } catch (e) {
      _error = 'Error al agregar estudiante: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Update student
  Future<bool> updateStudent({
    required String studentId,
    String? nombre,
    String? matricula,
    String? grupoId,
    String? turnoId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (matricula != null) updateData['matricula'] = matricula;
      if (grupoId != null) updateData['id_grupo'] = grupoId;
      if (turnoId != null) updateData['id_turno'] = turnoId;

      await _supabase.from('alumnos').update(updateData).eq('id', studentId);

      // Update local data
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        await loadStudentById(studentId: studentId);
        if (_selectedStudent != null) {
          _students[index] = _selectedStudent!;
          _filteredStudents = List.from(_students);
          // Use Future.microtask to avoid calling during build
          Future.microtask(() => notifyListeners());
        }
      }

      return true;
    } catch (e) {
      _error = 'Error al actualizar estudiante: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Deactivate student (deactivate llave)
  Future<bool> deactivateStudent({
    required String studentId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      await _supabase.from('llaves').update({
        'activo': false,
        'fecha_desactivacion': DateTime.now().toIso8601String(),
      }).eq('id_alumno', studentId);

      // Update local data
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = _students[index].copyWith(llaveActiva: false);
        _filteredStudents = List.from(_students);
        // Use Future.microtask to avoid calling during build
        Future.microtask(() => notifyListeners());
      }

      return true;
    } catch (e) {
      _error = 'Error al desactivar estudiante: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Activate student (activate llave)
  Future<bool> activateStudent({
    required String studentId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      await _supabase.from('llaves').update({
        'activo': true,
      }).eq('id_alumno', studentId);

      // Update local data
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = _students[index].copyWith(llaveActiva: true);
        _filteredStudents = List.from(_students);
        // Use Future.microtask to avoid calling during build
        Future.microtask(() => notifyListeners());
      }

      return true;
    } catch (e) {
      _error = 'Error al activar estudiante: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Link tutor to student
  Future<bool> linkTutor({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      await _supabase.from('alumno_tutores').insert({
        'id_alumno': studentId,
        'id_tutor': tutorId,
      });

      // Reload student details
      await loadStudentById(studentId: studentId);

      return true;
    } catch (e) {
      _error = 'Error al vincular tutor: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Unlink tutor from student
  Future<bool> unlinkTutor({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      await _supabase
          .from('alumno_tutores')
          .delete()
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId);

      // Reload student details
      await loadStudentById(studentId: studentId);

      return true;
    } catch (e) {
      _error = 'Error al desvincular tutor: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Get students by grupo
  List<StudentDetails> getStudentsByGrupo(String grupoId) {
    return _students.where((s) => s.grupoId == grupoId).toList();
  }

  // Get students by turno
  List<StudentDetails> getStudentsByTurno(String turnoId) {
    return _students.where((s) => s.turnoId == turnoId).toList();
  }

  // Get available grades
  List<String> getAvailableGrades() {
    final grades = _students
        .map((s) => s.nivelEducativo)
        .where((nivel) => nivel.isNotEmpty)
        .toSet()
        .toList();
    grades.sort();
    return grades;
  }

  // Get available groups
  List<String> getAvailableGroups() {
    final groups = _students
        .map((s) => s.grupo.split(' ').last) // Get the letter part (A, B, C)
        .where((group) => group.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();
    return groups;
  }

  // Get available turnos
  List<String> getAvailableTurnos() {
    final turnos = _students
        .map((s) => s.turno)
        .where((turno) => turno != null && turno.isNotEmpty)
        .toSet()
        .toList();
    turnos.sort();
    return turnos.cast<String>();
  }

  // Convert StudentDetails to Alumno for backward compatibility
  List<Alumno> getAlumnosFromStudents() {
    // Use a local copy to avoid any potential side effects
    final studentsToConvert = List<StudentDetails>.from(_filteredStudents);
    debugPrint(
        'getAlumnosFromStudents: Converting ${studentsToConvert.length} filtered students to Alumno');
    debugPrint('Current _students.length: ${_students.length}');
    debugPrint('Current _filteredStudents.length: ${_filteredStudents.length}');

    final alumnoList = studentsToConvert.map((student) {
      // Handle case where grupo might be "Sin grupo" or similar
      String grupoLetter = 'A'; // Default
      if (student.grupo != 'Sin grupo' && student.grupo.isNotEmpty) {
        final parts = student.grupo.split(' ');
        if (parts.isNotEmpty) {
          grupoLetter = parts.last; // Extract letter part
        }
      }

      return Alumno(
        id: student.id,
        nombre: student.nombre,
        grupo: grupoLetter,
        id_escuela: student.escuelaId,
        id_llave: student.llaveId ?? '',
        vinculado: student.llaveActiva,
        matricula: student.matricula,
        fecha_registro: student.fechaRegistro,
        turno: _getTurnoFromString(student.turno),
      );
    }).toList();

    debugPrint('Converted to ${alumnoList.length} Alumno objects');
    return alumnoList;
  }

  // Helper method to convert turno string to enum
  Turno _getTurnoFromString(String? turnoString) {
    if (turnoString == null) return Turno.matutino;
    final turnoLower = turnoString.toLowerCase();
    if (turnoLower.contains('vespertino') || turnoLower.contains('tarde')) {
      return Turno.vespertino;
    }
    return Turno.matutino;
  }

  // Set selected student
  void setSelectedStudent(StudentDetails? student) {
    _selectedStudent = student;
    // Use Future.microtask to avoid calling during build
    Future.microtask(() => notifyListeners());
  }

  // Clear students list
  void clearStudents() {
    _students.clear();
    _filteredStudents.clear();
    _selectedStudent = null;
    _currentLoadingMode = null;
    // Use Future.microtask to avoid calling during build
    Future.microtask(() => notifyListeners());
  }

  // Helper method to map database response to StudentDetails
  StudentDetails _mapToStudentDetails(Map<String, dynamic> data) {
    final grupo = data['grupos'];
    final turno = data['turnos'];
    final llaves = data['llaves'] as List?;
    final tutores = data['alumno_tutores'] as List?;

    // Get active llave
    final activeLlave = llaves?.firstWhere(
      (llave) => llave['activo'] == true,
      orElse: () => null,
    );

    // Parse tutors - handle case where usuarios might be null
    final tutorsList = tutores
            ?.where((tutorData) => tutorData['usuarios'] != null)
            .map<TutorInfo>((tutorData) {
          final usuario = tutorData['usuarios'];
          return TutorInfo(
            id: usuario['id'],
            nombre: usuario['nombre'] ?? '',
            apellido: usuario['apellido'] ?? '',
            email: usuario['email'] ?? '',
            telefono: null, // telefono is not in usuarios table
            fechaVinculacion: DateTime.parse(tutorData['fecha_vinculacion']),
          );
        }).toList() ??
        [];

    return StudentDetails(
      id: data['id'],
      nombre: data['nombre'] ?? '',
      matricula: data['matricula'] ?? '',
      escuelaId: data['id_escuela'] ?? '',
      grupoId: grupo?['id'] ?? '',
      grupo: grupo?['grupo'] ?? 'Sin grupo',
      nivelEducativo: grupo?['nivel_educativo'] ?? 'Sin nivel',
      turnoId: turno?['id'],
      turno: turno?['turno'],
      horaInicioTurno: turno?['hora_inicio'],
      horaFinTurno: turno?['hora_fin'],
      llaveId: activeLlave?['id'],
      llaveCodigo: activeLlave?['codigo'],
      llaveActiva: activeLlave?['activo'] ?? false,
      fechaRegistro: DateTime.parse(data['fecha_registro']),
      tutores: tutorsList,
    );
  }

  // Helper method to generate llave code
  Future<String> _generateLlaveCode(String escuelaId) async {
    try {
      // Get school code or use default
      final schoolResponse = await _supabase
          .from('escuelas')
          .select('codigo')
          .eq('id', escuelaId)
          .single();

      final schoolCode = schoolResponse['codigo'] ?? 'ESC';

      // Get count of existing llaves for this school
      final countResponse = await _supabase
          .from('llaves')
          .select('id')
          .eq('id_escuela', escuelaId);

      final count = (countResponse as List).length;
      final sequence = (count + 1).toString().padLeft(4, '0');

      return '$schoolCode$sequence${DateTime.now().year}';
    } catch (e) {
      // Fallback code generation
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'ESC${timestamp.toString().substring(8)}';
    }
  }
}

// Data classes for student details
class StudentDetails {
  final String id;
  final String nombre;
  final String matricula;
  final String escuelaId;
  final String grupoId;
  final String grupo;
  final String nivelEducativo;
  final String? turnoId;
  final String? turno;
  final String? horaInicioTurno;
  final String? horaFinTurno;
  final String? llaveId;
  final String? llaveCodigo;
  final bool llaveActiva;
  final DateTime fechaRegistro;
  final List<TutorInfo> tutores;

  const StudentDetails({
    required this.id,
    required this.nombre,
    required this.matricula,
    required this.escuelaId,
    required this.grupoId,
    required this.grupo,
    required this.nivelEducativo,
    this.turnoId,
    this.turno,
    this.horaInicioTurno,
    this.horaFinTurno,
    this.llaveId,
    this.llaveCodigo,
    required this.llaveActiva,
    required this.fechaRegistro,
    required this.tutores,
  });

  StudentDetails copyWith({
    String? id,
    String? nombre,
    String? matricula,
    String? escuelaId,
    String? grupoId,
    String? grupo,
    String? nivelEducativo,
    String? turnoId,
    String? turno,
    String? horaInicioTurno,
    String? horaFinTurno,
    String? llaveId,
    String? llaveCodigo,
    bool? llaveActiva,
    DateTime? fechaRegistro,
    List<TutorInfo>? tutores,
  }) {
    return StudentDetails(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      matricula: matricula ?? this.matricula,
      escuelaId: escuelaId ?? this.escuelaId,
      grupoId: grupoId ?? this.grupoId,
      grupo: grupo ?? this.grupo,
      nivelEducativo: nivelEducativo ?? this.nivelEducativo,
      turnoId: turnoId ?? this.turnoId,
      turno: turno ?? this.turno,
      horaInicioTurno: horaInicioTurno ?? this.horaInicioTurno,
      horaFinTurno: horaFinTurno ?? this.horaFinTurno,
      llaveId: llaveId ?? this.llaveId,
      llaveCodigo: llaveCodigo ?? this.llaveCodigo,
      llaveActiva: llaveActiva ?? this.llaveActiva,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      tutores: tutores ?? this.tutores,
    );
  }

  // Helper getters
  bool get hasActiveLlave => llaveActiva && llaveCodigo != null;
  bool get hasTutores => tutores.isNotEmpty;
  String get gradoGrupo => grupo;
  String get turnoDisplay => turno ?? 'Sin turno';
  String get horaDisplay {
    if (horaInicioTurno != null && horaFinTurno != null) {
      return '$horaInicioTurno - $horaFinTurno';
    }
    return 'Sin horario';
  }
}

class TutorInfo {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final DateTime fechaVinculacion;

  const TutorInfo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    required this.fechaVinculacion,
  });

  String get nombreCompleto => '$nombre $apellido';
}
