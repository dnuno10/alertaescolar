import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import '../models/models.dart';
import '../models/turno.dart' as turno_model;

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
  final DateTime?
      fechaRegistroLlave; // This should come from llaves.fecha_registro
  final DateTime?
      fechaDesactivacionLlave; // This should come from llaves.fecha_desactivacion
  final int?
      limiteVinculacion; // This should come from llaves.limite_vinculacion_dias
  final List<TutorInfo> tutores;
  final List<Map<String, dynamic>> familyContacts; // Add this field

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
    this.fechaRegistroLlave,
    this.fechaDesactivacionLlave,
    this.limiteVinculacion,
    required this.tutores,
    this.familyContacts = const [], // Add this parameter
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
    DateTime? fechaRegistroLlave,
    DateTime? fechaDesactivacionLlave,
    int? limiteVinculacion,
    List<TutorInfo>? tutores,
    List<Map<String, dynamic>>? familyContacts, // Add this parameter
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
      fechaRegistroLlave: fechaRegistroLlave ?? this.fechaRegistroLlave,
      fechaDesactivacionLlave:
          fechaDesactivacionLlave ?? this.fechaDesactivacionLlave,
      limiteVinculacion: limiteVinculacion ?? this.limiteVinculacion,
      tutores: tutores ?? this.tutores,
      familyContacts: familyContacts ?? this.familyContacts, // Add this line
    );
  }

  // Helper getters
  bool get hasActiveLlave => llaveActiva && llaveCodigo != null;
  bool get hasTutores => tutores.isNotEmpty;
  String get gradoGrupo => '$nivelEducativo - $grupo';
  String get turnoDisplay => turno ?? 'Sin turno';
  String get horaDisplay {
    if (horaInicioTurno != null && horaFinTurno != null) {
      return '$horaInicioTurno - $horaFinTurno';
    }
    return 'Sin horario';
  }

  // Helper method to get remaining time in a more readable format
  String get tiempoRestanteFormateado {
    if (fechaRegistroLlave == null) {
      return 'Información no disponible';
    }

    final now = DateTime.now();

    if (limiteVinculacion == null || limiteVinculacion == 0) {
      return 'Sin límite de tiempo';
    }

    final expirationDate =
        fechaRegistroLlave!.add(Duration(days: limiteVinculacion!));

    if (expirationDate.isBefore(now)) {
      return 'Expirado';
    }

    final difference = expirationDate.difference(now);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 día restante'
          : '${difference.inDays} días restantes';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hora restante'
          : '${difference.inHours} horas restantes';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minuto restante'
          : '${difference.inMinutes} minutos restantes';
    } else {
      return 'Menos de 1 minuto restante';
    }
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

class StudentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<StudentDetails> _students = [];
  List<StudentDetails> _filteredStudents = [];
  StudentDetails? _selectedStudent;

  // Add filtering data
  List<Grupo> _availableGrupos = [];
  List<turno_model.Turno> _availableTurnos = [];

  bool _isLoading = false;
  String? _error;

  // Track the loading mode to prevent unwanted overwrites
  String? _currentLoadingMode; // 'admin', 'user', or null

  // Track conversion count to reduce logging
  int _lastConvertedCount = 0;

  // Getters
  List<StudentDetails> get students => _students;
  List<StudentDetails> get filteredStudents => _filteredStudents;
  StudentDetails? get selectedStudent => _selectedStudent;
  List<Grupo> get availableGrupos => _availableGrupos;
  List<turno_model.Turno> get availableTurnos => _availableTurnos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    debugPrint('clearError: Clearing error message');
    _error = null;
    // Use Future.microtask to avoid calling during build
    Future.microtask(() => notifyListeners());
  }

  // Get user's school ID based on their students (tutor relationship)
  Future<String?> getUserSchoolId(String userId) async {
    debugPrint('getUserSchoolId: Starting for userId: $userId');
    try {
      final response = await _supabase.from('alumno_tutores').select('''
            alumnos!inner(
              id_escuela
            )
          ''').eq('id_tutor', userId).limit(1);

      debugPrint(
          'getUserSchoolId: Response received, length: ${response.length}');
      if (response.isNotEmpty) {
        final alumno = response[0]['alumnos'];
        final schoolId = alumno['id_escuela'];
        debugPrint('getUserSchoolId: Found school ID: $schoolId');
        return schoolId;
      }
      debugPrint('getUserSchoolId: No school found for user');
      return null;
    } catch (e) {
      debugPrint('getUserSchoolId: Error getting user school ID: $e');
      debugPrint('getUserSchoolId: Error type: ${e.runtimeType}');
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
    debugPrint(
        'loadStudentsForUser: Starting for userId: $userId, grupoId: $grupoId, turnoId: $turnoId, forceReload: $forceReload');

    // Don't override admin students unless forced
    if (_currentLoadingMode == 'admin' && !forceReload) {
      debugPrint(
          'loadStudentsForUser: Skipping - admin students already loaded');
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentLoadingMode = 'user';
      debugPrint(
          'loadStudentsForUser: Set loading state, mode: $_currentLoadingMode');
      Future.microtask(() => notifyListeners());

      // Get students that this user is tutor of - including family contacts
      debugPrint(
          'loadStudentsForUser: Querying database for tutor relationships with family contacts');
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
                fecha_registro,
                fecha_desactivacion,
                limite_vinculacion
              )
            ),
            usuarios!inner(
              id,
              nombre,
              apellido,
              email,
              contactos_familiares(
                id,
                id_usuario,
                nombre,
                parentesco,
                telefono,
                email,
                fecha_registro
              )
            ),
            fecha_vinculacion
          ''').eq('id_tutor', userId);

      debugPrint(
          'loadStudentsForUser: Query response received, length: ${response.length}');
      final studentsList = <StudentDetails>[];

      for (final item in response) {
        try {
          final alumnoData = item['alumnos'];
          final tutorData = item['usuarios'];
          final fechaVinculacion = item['fecha_vinculacion'];
          debugPrint(
              'loadStudentsForUser: Processing student: ${alumnoData['nombre']}');

          // Add tutor info and family contacts to the student data
          alumnoData['alumno_tutores'] = [
            {
              'id_tutor': userId,
              'fecha_vinculacion':
                  fechaVinculacion ?? DateTime.now().toIso8601String(),
              'usuarios': {
                'id': userId,
                'nombre': tutorData['nombre'] ?? '',
                'apellido': tutorData['apellido'] ?? '',
                'email': tutorData['email'] ?? '',
                'contactos_familiares': tutorData['contactos_familiares'] ?? [],
              }
            }
          ];

          final studentDetails = _mapToStudentDetailsWithContacts(alumnoData);
          studentsList.add(studentDetails);
          debugPrint(
              'loadStudentsForUser: Added student: ${studentDetails.nombre} with ${studentDetails.familyContacts.length} family contacts');
        } catch (e) {
          debugPrint('loadStudentsForUser: Error processing student item: $e');
          debugPrint('loadStudentsForUser: Item data: $item');
        }
      }

      _students = studentsList;
      _filteredStudents = List.from(_students);
      _error = null;
      debugPrint(
          'loadStudentsForUser: Successfully loaded ${_students.length} students with family contacts');
    } catch (e) {
      _error = 'Error al cargar estudiantes del usuario: $e';
      debugPrint('loadStudentsForUser: Error: $_error');
      debugPrint('loadStudentsForUser: Error type: ${e.runtimeType}');
      debugPrint('loadStudentsForUser: Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      debugPrint('loadStudentsForUser: Finished, setting loading to false');
      Future.microtask(() => notifyListeners());
    }
  }

  // Load a specific student by ID
  Future<void> loadStudentById({required String studentId}) async {
    debugPrint('loadStudentById: Starting for studentId: $studentId');

    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      debugPrint('loadStudentById: Querying database with family contacts');
      final response = await _supabase.from('alumnos').select('''
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
            fecha_registro,
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
              email,
              contactos_familiares(
                id,
                id_usuario,
                nombre,
                parentesco,
                telefono,
                email,
                fecha_registro
              )
            )
          )
        ''').eq('id', studentId).single();

      debugPrint(
          'loadStudentById: Database response received for student: ${response['nombre']}');
      _selectedStudent = _mapToStudentDetailsWithContacts(response);

      debugPrint(
          'loadStudentById: Successfully loaded student: ${_selectedStudent?.nombre} with ${_selectedStudent?.familyContacts.length ?? 0} family contacts');
    } catch (e) {
      _error = 'Error al cargar estudiante: $e';
      debugPrint('loadStudentById: Error: $_error');
      debugPrint('loadStudentById: Error type: ${e.runtimeType}');
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Load all students for a school with complete details including filtering data
  Future<void> loadStudents({
    String? escuelaId,
    String? userId, // If provided, will get escuelaId from user's students
    String? grupoId,
    String? turnoId,
  }) async {
    debugPrint(
        'loadStudents: Starting with escuelaId: $escuelaId, userId: $userId, grupoId: $grupoId, turnoId: $turnoId');

    try {
      _isLoading = true;
      _error = null;
      _currentLoadingMode = 'admin';
      debugPrint('loadStudents: Set loading state, mode: $_currentLoadingMode');
      Future.microtask(() => notifyListeners());

      String? schoolId = escuelaId;

      if (userId != null && schoolId == null) {
        debugPrint('loadStudents: Getting school ID from user ID');
        schoolId = await getUserSchoolId(userId);
        if (schoolId == null) {
          debugPrint('loadStudents: No school found for user');
          throw Exception('No se encontró escuela asociada al usuario');
        }
        debugPrint('loadStudents: Found school ID: $schoolId');
      }

      if (schoolId == null) {
        debugPrint('loadStudents: No school ID provided');
        throw Exception(
            'Se requiere escuelaId o userId para cargar estudiantes');
      }

      debugPrint('loadStudents: Loading filtering data for school: $schoolId');
      await _loadFilteringData(schoolId);

      debugPrint(
          'loadStudents: Building query for students WITHOUT family contacts first');
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
              fecha_registro,
              fecha_desactivacion,
              limite_vinculacion
            ),
            alumno_tutores(
              id_tutor,
              fecha_vinculacion
            )
          ''').eq('id_escuela', schoolId);

      if (grupoId != null) {
        debugPrint('loadStudents: Adding grupo filter: $grupoId');
        query = query.eq('id_grupo', grupoId);
      }
      if (turnoId != null) {
        debugPrint('loadStudents: Adding turno filter: $turnoId');
        query = query.eq('id_turno', turnoId);
      }

      debugPrint('loadStudents: Executing query for students');
      final response = await query.order('nombre');
      debugPrint(
          'loadStudents: Query response received, length: ${response.length}');

      _students = [];

      // Process each student and then load their tutors and family contacts separately
      for (int i = 0; i < response.length; i++) {
        try {
          final item = response[i];
          debugPrint(
              'loadStudents: Processing student ${i + 1}/${response.length}: ${item['nombre']}');

          // First create basic student details
          final studentDetails =
              await _mapToStudentDetailsWithSeparateContacts(item);
          _students.add(studentDetails);
        } catch (e) {
          debugPrint('loadStudents: Error processing student at index $i: $e');
          debugPrint('loadStudents: Student data: ${response[i]}');
        }
      }

      _filteredStudents = List.from(_students);
      _error = null;

      debugPrint(
          'loadStudents: Successfully loaded ${_students.length} students from database with family contacts');
    } catch (e) {
      _error = 'Error al cargar estudiantes: $e';
      debugPrint('loadStudents: Error: $_error');
      debugPrint('loadStudents: Error type: ${e.runtimeType}');
      debugPrint('loadStudents: Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      debugPrint('loadStudents: Finished, setting loading to false');
      Future.microtask(() => notifyListeners());
    }
  }

  // New method that loads tutors and family contacts separately
  Future<StudentDetails> _mapToStudentDetailsWithSeparateContacts(
      Map<String, dynamic> data) async {
    debugPrint(
        '_mapToStudentDetailsWithSeparateContacts: Processing student: ${data['nombre']}');

    try {
      final grupo = data['grupos'];
      final turno = data['turnos'];
      final llaves = data['llaves'] as List?;
      final tutoresBasic = data['alumno_tutores'] as List?;

      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Student data - grupo: ${grupo?['grupo']}, turno: ${turno?['turno']}, llaves count: ${llaves?.length}, tutores count: ${tutoresBasic?.length}');

      // Get active llave
      final activeLlave = llaves?.firstWhere(
        (llave) => llave['activo'] == true,
        orElse: () => null,
      );
      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Active llave found: ${activeLlave != null}');

      // Load tutors and family contacts separately
      final tutorsList = <TutorInfo>[];
      final familyContacts = <Map<String, dynamic>>[];

      if (tutoresBasic != null && tutoresBasic.isNotEmpty) {
        debugPrint(
            '_mapToStudentDetailsWithSeparateContacts: Loading tutors and family contacts separately');

        for (final tutorBasic in tutoresBasic) {
          final tutorId = tutorBasic['id_tutor'];
          final fechaVinculacion = tutorBasic['fecha_vinculacion'];

          debugPrint(
              '_mapToStudentDetailsWithSeparateContacts: Loading data for tutor: $tutorId');

          try {
            // Load tutor details
            final tutorResponse = await _supabase
                .from('usuarios')
                .select('id, nombre, apellido, email')
                .eq('id', tutorId)
                .maybeSingle();

            debugPrint(
                '_mapToStudentDetailsWithSeparateContacts: Tutor data loaded: ${tutorResponse?['nombre']} ${tutorResponse?['apellido']}');

            // Only add tutor info if tutor data was found
            if (tutorResponse != null) {
              tutorsList.add(TutorInfo(
                id: tutorResponse['id'],
                nombre: tutorResponse['nombre'] ?? '',
                apellido: tutorResponse['apellido'] ?? '',
                email: tutorResponse['email'] ?? '',
                telefono: null,
                fechaVinculacion: DateTime.parse(fechaVinculacion),
              ));

              // Load family contacts for this tutor
              final contactsResponse = await _supabase
                  .from('contactos_familiares')
                  .select(
                      'id, id_usuario, nombre, parentesco, telefono, email, fecha_registro')
                  .eq('id_usuario', tutorId);

              debugPrint(
                  '_mapToStudentDetailsWithSeparateContacts: Found ${contactsResponse.length} family contacts for tutor ${tutorResponse['nombre']}');

              for (final contact in contactsResponse) {
                debugPrint(
                    '_mapToStudentDetailsWithSeparateContacts: Contact: ${contact['nombre']} (${contact['parentesco']})');
              }

              familyContacts
                  .addAll(List<Map<String, dynamic>>.from(contactsResponse));
            } else {
              debugPrint(
                  '_mapToStudentDetailsWithSeparateContacts: Tutor not found in users table: $tutorId');
            }
          } catch (e) {
            debugPrint(
                '_mapToStudentDetailsWithSeparateContacts: Error loading tutor $tutorId: $e');
          }
        }
      }

      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Processed ${tutorsList.length} tutors and ${familyContacts.length} family contacts');

      final studentDetails = StudentDetails(
        id: data['id'],
        nombre: data['nombre'] ?? '',
        matricula: data['matricula'] ?? '',
        escuelaId: data['id_escuela'] ?? '',
        grupoId: grupo?['id'] ?? '',
        grupo: grupo?['grupo'] ?? 'Sin grupo',
        nivelEducativo: grupo?['nivel_educativo'] ?? 'Sin nivel',
        turnoId: turno?['id'],
        turno: turno?['turno'] ?? 'Sin turno',
        horaInicioTurno: turno?['hora_inicio'],
        horaFinTurno: turno?['hora_fin'],
        llaveId: activeLlave?['id'],
        llaveCodigo: activeLlave?['codigo'],
        llaveActiva: activeLlave?['activo'] ?? false,
        fechaRegistro: DateTime.parse(data['fecha_registro']),
        fechaRegistroLlave: activeLlave != null
            ? DateTime.parse(activeLlave['fecha_registro'])
            : null,
        fechaDesactivacionLlave: activeLlave?['fecha_desactivacion'] != null
            ? DateTime.parse(activeLlave['fecha_desactivacion'])
            : null,
        limiteVinculacion: activeLlave?['limite_vinculacion']?.toInt(),
        tutores: tutorsList,
        familyContacts: familyContacts,
      );

      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Successfully created StudentDetails for: ${studentDetails.nombre}');
      return studentDetails;
    } catch (e) {
      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Error creating StudentDetails: $e');
      debugPrint(
          '_mapToStudentDetailsWithSeparateContacts: Error type: ${e.runtimeType}');
      debugPrint('_mapToStudentDetailsWithSeparateContacts: Data: $data');
      rethrow;
    }
  }

  // Updated mapping method that gets family contacts from the nested query response
  StudentDetails _mapToStudentDetailsWithContacts(Map<String, dynamic> data) {
    debugPrint(
        '_mapToStudentDetailsWithContacts: Processing student: ${data['nombre']}');

    try {
      final grupo = data['grupos'];
      final turno = data['turnos'];
      final llaves = data['llaves'] as List?;
      final tutores = data['alumno_tutores'] as List?;

      debugPrint(
          '_mapToStudentDetailsWithContacts: Student data - grupo: ${grupo?['grupo']}, turno: ${turno?['turno']}, llaves count: ${llaves?.length}, tutores count: ${tutores?.length}');

      // DEBUG: Let's see the actual tutor data structure
      if (tutores != null && tutores.isNotEmpty) {
        debugPrint(
            '_mapToStudentDetailsWithContacts: Raw tutores data: $tutores');
        for (int i = 0; i < tutores.length; i++) {
          debugPrint(
              '_mapToStudentDetailsWithContacts: Tutor $i: ${tutores[i]}');
          final tutorData = tutores[i];
          debugPrint(
              '_mapToStudentDetailsWithContacts: Tutor $i has usuarios key: ${tutorData.containsKey('usuarios')}');
          if (tutorData.containsKey('usuarios')) {
            debugPrint(
                '_mapToStudentDetailsWithContacts: Tutor $i usuarios value: ${tutorData['usuarios']}');
            debugPrint(
                '_mapToStudentDetailsWithContacts: Tutor $i usuarios type: ${tutorData['usuarios'].runtimeType}');
          }
        }
      }

      // Get active llave
      final activeLlave = llaves?.firstWhere(
        (llave) => llave['activo'] == true,
        orElse: () => null,
      );
      debugPrint(
          '_mapToStudentDetailsWithContacts: Active llave found: ${activeLlave != null}');

      // Parse tutors and their family contacts
      final tutorsList = <TutorInfo>[];
      final familyContacts = <Map<String, dynamic>>[];

      if (tutores != null) {
        for (final tutorData in tutores) {
          debugPrint(
              '_mapToStudentDetailsWithContacts: Processing tutorData: $tutorData');
          final usuario = tutorData['usuarios'];
          debugPrint(
              '_mapToStudentDetailsWithContacts: Usuario extracted: $usuario');
          debugPrint(
              '_mapToStudentDetailsWithContacts: Usuario type: ${usuario.runtimeType}');

          if (usuario != null) {
            debugPrint(
                '_mapToStudentDetailsWithContacts: Processing tutor: ${usuario['nombre']} ${usuario['apellido']}');

            // Add tutor info
            tutorsList.add(TutorInfo(
              id: usuario['id'],
              nombre: usuario['nombre'] ?? '',
              apellido: usuario['apellido'] ?? '',
              email: usuario['email'] ?? '',
              telefono: null,
              fechaVinculacion: DateTime.parse(tutorData['fecha_vinculacion']),
            ));

            // Extract family contacts from this tutor
            final tutorContacts = usuario['contactos_familiares'] as List?;
            debugPrint(
                '_mapToStudentDetailsWithContacts: Tutor contacts: $tutorContacts');
            debugPrint(
                '_mapToStudentDetailsWithContacts: Tutor contacts type: ${tutorContacts.runtimeType}');

            if (tutorContacts != null) {
              debugPrint(
                  '_mapToStudentDetailsWithContacts: Found ${tutorContacts.length} family contacts for tutor ${usuario['nombre']}');
              for (int i = 0; i < tutorContacts.length; i++) {
                debugPrint(
                    '_mapToStudentDetailsWithContacts: Contact $i: ${tutorContacts[i]}');
              }
              familyContacts
                  .addAll(List<Map<String, dynamic>>.from(tutorContacts));
            } else {
              debugPrint(
                  '_mapToStudentDetailsWithContacts: No family contacts found for tutor ${usuario['nombre']}');
            }
          } else {
            debugPrint(
                '_mapToStudentDetailsWithContacts: WARNING - usuario is null for tutorData: $tutorData');
          }
        }
      }

      debugPrint(
          '_mapToStudentDetailsWithContacts: Processed ${tutorsList.length} tutors and ${familyContacts.length} family contacts');

      final studentDetails = StudentDetails(
        id: data['id'],
        nombre: data['nombre'] ?? '',
        matricula: data['matricula'] ?? '',
        escuelaId: data['id_escuela'] ?? '',
        grupoId: grupo?['id'] ?? '',
        grupo: grupo?['grupo'] ?? 'Sin grupo',
        nivelEducativo: grupo?['nivel_educativo'] ?? 'Sin nivel',
        turnoId: turno?['id'],
        turno: turno?['turno'] ?? 'Sin turno',
        horaInicioTurno: turno?['hora_inicio'],
        horaFinTurno: turno?['hora_fin'],
        llaveId: activeLlave?['id'],
        llaveCodigo: activeLlave?['codigo'],
        llaveActiva: activeLlave?['activo'] ?? false,
        fechaRegistro: DateTime.parse(data['fecha_registro']),
        fechaRegistroLlave: activeLlave != null
            ? DateTime.parse(activeLlave['fecha_registro'])
            : null,
        fechaDesactivacionLlave: activeLlave?['fecha_desactivacion'] != null
            ? DateTime.parse(activeLlave['fecha_desactivacion'])
            : null,
        limiteVinculacion: activeLlave?['limite_vinculacion']?.toInt(),
        tutores: tutorsList,
        familyContacts: familyContacts,
      );

      debugPrint(
          '_mapToStudentDetailsWithContacts: Successfully created StudentDetails for: ${studentDetails.nombre}');
      return studentDetails;
    } catch (e) {
      debugPrint(
          '_mapToStudentDetailsWithContacts: Error creating StudentDetails: $e');
      debugPrint(
          '_mapToStudentDetailsWithContacts: Error type: ${e.runtimeType}');
      debugPrint('_mapToStudentDetailsWithContacts: Data: $data');
      rethrow;
    }
  }

  // Load filtering data (grupos and turnos)
  Future<void> _loadFilteringData(String escuelaId) async {
    debugPrint('_loadFilteringData: Starting for escuelaId: $escuelaId');

    try {
      // Load grupos
      debugPrint('_loadFilteringData: Loading grupos');
      final gruposResponse = await _supabase
          .from('grupos')
          .select()
          .eq('id_escuela', escuelaId)
          .order('nivel_educativo')
          .order('grupo');

      debugPrint(
          '_loadFilteringData: Grupos response received, length: ${gruposResponse.length}');
      _availableGrupos =
          (gruposResponse as List).map((item) => Grupo.fromJson(item)).toList();

      // Load turnos
      debugPrint('_loadFilteringData: Loading turnos');
      final turnosResponse = await _supabase
          .from('turnos')
          .select()
          .eq('id_escuela', escuelaId)
          .order('turno');

      debugPrint(
          '_loadFilteringData: Turnos response received, length: ${turnosResponse.length}');
      _availableTurnos = (turnosResponse as List)
          .map((item) => turno_model.Turno.fromJson(item))
          .toList();

      debugPrint(
          '_loadFilteringData: Successfully loaded ${_availableGrupos.length} grupos and ${_availableTurnos.length} turnos for filtering');
    } catch (e) {
      debugPrint('_loadFilteringData: Error loading filtering data: $e');
      debugPrint('_loadFilteringData: Error type: ${e.runtimeType}');
      // Don't throw error here, just log it
    }
  }

  // Updated filter method with correct parameters
  void filterStudents({
    String? searchQuery,
    String? grupo, // Now filtering by actual grupo name
    String? nivelEducativo,
    String? status,
    String? turno,
  }) {
    debugPrint(
        'filterStudents called with: searchQuery="$searchQuery", grupo="$grupo", nivelEducativo="$nivelEducativo", status="$status", turno="$turno"');
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

      // Grupo filter (exact match with grupo name)
      bool matchesGrupo = true;
      if (grupo != null && grupo != 'all') {
        matchesGrupo = student.grupo == grupo;
      }

      // Nivel educativo filter
      bool matchesNivelEducativo = true;
      if (nivelEducativo != null && nivelEducativo != 'all') {
        matchesNivelEducativo = student.nivelEducativo == nivelEducativo;
      }

      // Status filter (based on llave activo)
      bool matchesStatus = true;
      if (status != null && status != 'all') {
        final isActive = student.llaveActiva;
        matchesStatus = (status == 'active' && isActive) ||
            (status == 'inactive' && !isActive);
      }

      // Turno filter (exact match with turno name)
      bool matchesTurno = true;
      if (turno != null && turno != 'all') {
        matchesTurno = student.turno == turno;
      }

      return matchesSearch &&
          matchesGrupo &&
          matchesNivelEducativo &&
          matchesStatus &&
          matchesTurno;
    }).toList();

    debugPrint('Filtered students result: ${_filteredStudents.length}');
    if (_filteredStudents.isNotEmpty) {
      debugPrint('First filtered student: ${_filteredStudents.first.nombre}');
    }

    notifyListeners();
  }

  // Get available grupos names
  List<String> getAvailableGrupoNames() {
    return _availableGrupos.map((grupo) => grupo.grupo).toList();
  }

  // Get available niveles educativos
  List<String> getAvailableNivelesEducativos() {
    return _availableGrupos
        .map((grupo) => grupo.nivelEducativo)
        .toSet()
        .toList()
      ..sort();
  }

  // Get available turno names
  List<String> getAvailableTurnoNames() {
    return _availableTurnos.map((turno) => turno.turno).toList();
  }

  // Update student
  Future<bool> updateStudent({
    required String studentId,
    String? nombre,
    String? matricula,
    String? grupoId,
    String? turnoId,
  }) async {
    debugPrint('updateStudent: Starting for studentId: $studentId');
    debugPrint(
        'updateStudent: Parameters - nombre: $nombre, matricula: $matricula, grupoId: $grupoId, turnoId: $turnoId');

    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (matricula != null) updateData['matricula'] = matricula;
      if (grupoId != null) updateData['id_grupo'] = grupoId;
      if (turnoId != null) updateData['id_turno'] = turnoId;

      debugPrint('updateStudent: Update data: $updateData');

      await _supabase.from('alumnos').update(updateData).eq('id', studentId);
      debugPrint('updateStudent: Database update successful');

      // Update local data
      final index = _students.indexWhere((s) => s.id == studentId);
      debugPrint('updateStudent: Found student at index: $index');

      if (index != -1) {
        await loadStudentById(studentId: studentId);
        if (_selectedStudent != null) {
          _students[index] = _selectedStudent!;
          _filteredStudents = List.from(_students);
          debugPrint('updateStudent: Local data updated successfully');
          // Use Future.microtask to avoid calling during build
          Future.microtask(() => notifyListeners());
        }
      }

      debugPrint('updateStudent: Operation completed successfully');
      return true;
    } catch (e) {
      _error = 'Error al actualizar estudiante: $e';
      debugPrint('updateStudent: Error: $_error');
      debugPrint('updateStudent: Error type: ${e.runtimeType}');
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
    // Reduced logging - only log when there are changes or errors
    if (studentsToConvert.length != _lastConvertedCount) {
      debugPrint(
          'getAlumnosFromStudents: Converting ${studentsToConvert.length} filtered students to Alumno');
      _lastConvertedCount = studentsToConvert.length;
    }

    try {
      final alumnoList = studentsToConvert.map((student) {
        // Combine educational level and group name for display
        final displayGroup =
            student.nivelEducativo.isNotEmpty && student.grupo.isNotEmpty
                ? '${student.nivelEducativo} - ${student.grupo}'
                : student.grupo;

        return Alumno(
          id: student.id,
          nombre: student.nombre,
          id_grupo: student.grupoId, // Use the actual id_grupo from database
          grupo: displayGroup, // Use combined educational level and group name
          id_escuela: student.escuelaId,
          id_llave: student.llaveId ?? '',
          vinculado: student.llaveActiva,
          matricula: student.matricula,
          fecha_registro: student.fechaRegistro,
          turno: _getTurnoEnumFromString(student.turno),
        );
      }).toList();

      return alumnoList;
    } catch (e) {
      debugPrint('getAlumnosFromStudents: Error converting students: $e');
      debugPrint('getAlumnosFromStudents: Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Helper method to convert turno string to enum
  TurnoEnum _getTurnoEnumFromString(String? turnoString) {
    if (turnoString == null) return TurnoEnum.matutino;
    final turnoLower = turnoString.toLowerCase();
    if (turnoLower.contains('vespertino') || turnoLower.contains('tarde')) {
      return TurnoEnum.vespertino;
    }
    return TurnoEnum.matutino;
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

  // Load family contacts for a specific student
  Future<List<Map<String, dynamic>>> loadFamilyContactsForStudent(
      String studentId) async {
    debugPrint(
        'loadFamilyContactsForStudent: Starting for studentId: $studentId');

    try {
      // Get all tutors for this student and their family contacts
      final response = await _supabase.from('alumno_tutores').select('''
          usuarios!inner(
            contactos_familiares(
              id,
              id_usuario,
              nombre,
              parentesco,
              telefono,
              email,
              fecha_registro
            )
          )
        ''').eq('id_alumno', studentId);

      debugPrint(
          'loadFamilyContactsForStudent: Response received, tutor count: ${response.length}');

      final familyContacts = <Map<String, dynamic>>[];

      for (final tutorData in response) {
        final usuario = tutorData['usuarios'];
        final contacts = usuario['contactos_familiares'] as List?;

        if (contacts != null) {
          debugPrint(
              'loadFamilyContactsForStudent: Found ${contacts.length} contacts for tutor');
          familyContacts.addAll(List<Map<String, dynamic>>.from(contacts));
        }
      }

      debugPrint(
          'loadFamilyContactsForStudent: Total family contacts found: ${familyContacts.length}');
      return familyContacts;
    } catch (e) {
      debugPrint(
          'loadFamilyContactsForStudent: Error loading family contacts: $e');
      debugPrint('loadFamilyContactsForStudent: Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Updated method to validate student key code with complete data and better error handling
  Future<Map<String, dynamic>?> validateStudentKeyCode(String keyCode) async {
    debugPrint(
        'validateStudentKeyCode: Starting validation for code: $keyCode');

    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      // First check if the key exists at all
      debugPrint('validateStudentKeyCode: Step 1 - Checking if key exists');
      final keyExistsResponse = await _supabase
          .from('llaves')
          .select('id, codigo, id_alumno, id_escuela, activo')
          .eq('codigo', keyCode)
          .maybeSingle();

      if (keyExistsResponse == null) {
        debugPrint('validateStudentKeyCode: Key not found in database');
        throw Exception('Código de estudiante no encontrado');
      }

      debugPrint(
          'validateStudentKeyCode: Key found: ${keyExistsResponse['id']}');
      debugPrint(
          'validateStudentKeyCode: Key alumno ID: ${keyExistsResponse['id_alumno']}');
      debugPrint(
          'validateStudentKeyCode: Key escuela ID: ${keyExistsResponse['id_escuela']}');

      // Check if alumno exists
      debugPrint('validateStudentKeyCode: Step 2 - Checking if alumno exists');
      final alumnoResponse = await _supabase
          .from('alumnos')
          .select('id, nombre')
          .eq('id', keyExistsResponse['id_alumno'])
          .maybeSingle();

      if (alumnoResponse == null) {
        debugPrint('validateStudentKeyCode: Alumno not found for key');
        throw Exception('Estudiante asociado al código no encontrado');
      }

      debugPrint(
          'validateStudentKeyCode: Alumno found: ${alumnoResponse['nombre']}');

      // Check if escuela exists
      debugPrint('validateStudentKeyCode: Step 3 - Checking if escuela exists');
      final escuelaResponse = await _supabase
          .from('escuelas')
          .select('id, nombre')
          .eq('id', keyExistsResponse['id_escuela'])
          .maybeSingle();

      if (escuelaResponse == null) {
        debugPrint('validateStudentKeyCode: Escuela not found for key');
        throw Exception('Escuela asociada al código no encontrada');
      }

      debugPrint(
          'validateStudentKeyCode: Escuela found: ${escuelaResponse['nombre']}');

      // Now get comprehensive data with left joins instead of inner joins
      debugPrint('validateStudentKeyCode: Step 4 - Getting comprehensive data');
      final keyResponse = await _supabase.from('llaves').select('''
            id,
            codigo,
            id_alumno,
            id_escuela,
            fecha_registro,
            fecha_desactivacion,
            limite_vinculacion,
            activo,
            alumnos(
              id,
              nombre,
              matricula,
              id_grupo,
              id_turno,
              id_escuela,
              fecha_registro,
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
              )
            ),
            escuelas(
              id,
              nombre,
              codigo,
              tipo,
              direccion,
              telefono,
              email,
              descripcion,
              preescolar,
              primaria,
              secundaria,
              preparatoria
            )
          ''').eq('codigo', keyCode).single();

      debugPrint('validateStudentKeyCode: Comprehensive data retrieved');

      final keyData = keyResponse;
      final alumnoData = keyData['alumnos'];
      final escuelaData = keyData['escuelas'];

      if (alumnoData == null) {
        debugPrint(
            'validateStudentKeyCode: Alumno data is null in comprehensive query');
        throw Exception('Datos del estudiante no disponibles');
      }

      if (escuelaData == null) {
        debugPrint(
            'validateStudentKeyCode: Escuela data is null in comprehensive query');
        throw Exception('Datos de la escuela no disponibles');
      }

      final grupoData = alumnoData['grupos'];
      final turnoData = alumnoData['turnos'];

      debugPrint(
          'validateStudentKeyCode: Key found for student: ${alumnoData['nombre']}');

      // Validate limite_vinculacion > 0
      final limiteVinculacion = keyData['limite_vinculacion'] as int?;
      if (limiteVinculacion == null || limiteVinculacion <= 0) {
        debugPrint(
            'validateStudentKeyCode: No more registrations allowed, limit: $limiteVinculacion');
        throw Exception('Este código ya no permite más registros');
      }

      debugPrint(
          'validateStudentKeyCode: Limit validation passed, remaining: $limiteVinculacion');

      // Validate dates
      final now = DateTime.now();
      final fechaRegistro = DateTime.parse(keyData['fecha_registro']);
      final fechaDesactivacion = keyData['fecha_desactivacion'] != null
          ? DateTime.parse(keyData['fecha_desactivacion'])
          : null;

      if (now.isBefore(fechaRegistro)) {
        debugPrint('validateStudentKeyCode: Key not yet active');
        throw Exception('Este código aún no está activo');
      }

      if (fechaDesactivacion != null && now.isAfter(fechaDesactivacion)) {
        debugPrint('validateStudentKeyCode: Key has expired');
        throw Exception('Este código ha expirado');
      }

      debugPrint('validateStudentKeyCode: Date validation passed');

      // Calculate remaining days for the key
      final remainingDays = fechaDesactivacion?.difference(now).inDays;

      // Format time fields properly for timestamptz
      String? formatTime(dynamic timeField) {
        if (timeField == null) return null;
        try {
          // Parse the timestamptz field
          final dateTime = DateTime.parse(timeField.toString());
          return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          debugPrint('validateStudentKeyCode: Error formatting time: $e');
          return null;
        }
      }

      // Format date fields properly for timestamptz
      String formatTimestamptz(dynamic timestampField) {
        try {
          final dateTime = DateTime.parse(timestampField.toString());
          return dateTime.toIso8601String();
        } catch (e) {
          debugPrint('validateStudentKeyCode: Error formatting timestamp: $e');
          return timestampField.toString();
        }
      }

      // Return comprehensive student data for confirmation
      final validationResult = {
        'isValid': true,
        'keyId': keyData['id'],
        'limiteVinculacion': limiteVinculacion,
        'student': {
          'id': alumnoData['id'],
          'nombre': alumnoData['nombre'],
          'matricula': alumnoData['matricula'],
          'grupo': grupoData?['grupo'] ?? 'Sin grupo',
          'nivelEducativo': grupoData?['nivel_educativo'] ?? 'Sin nivel',
          'turno': turnoData?['turno'] ?? 'Sin turno',
          'horaInicioTurno': formatTime(turnoData?['hora_inicio']),
          'horaFinTurno': formatTime(turnoData?['hora_fin']),
          'escuelaId': alumnoData['id_escuela'],
          'fechaRegistroAlumno': alumnoData['fecha_registro'],
        },
        'school': {
          'id': escuelaData['id'],
          'nombre': escuelaData['nombre'],
          'codigo': escuelaData['codigo'],
          'tipo': escuelaData['tipo'],
          'direccion': escuelaData['direccion'],
          'telefono': escuelaData['telefono'],
          'email': escuelaData['email'],
          'descripcion': escuelaData['descripcion'],
          'nivelesEducativos': {
            'preescolar': escuelaData['preescolar'] ?? false,
            'primaria': escuelaData['primaria'] ?? false,
            'secundaria': escuelaData['secundaria'] ?? false,
            'preparatoria': escuelaData['preparatoria'] ?? false,
          }
        },
        'key': {
          'id': keyData['id'],
          'codigo': keyData['codigo'],
          'fechaRegistro': formatTimestamptz(keyData['fecha_registro']),
          'fechaDesactivacion': keyData['fecha_desactivacion'] != null
              ? formatTimestamptz(keyData['fecha_desactivacion'])
              : null,
          'limiteVinculacion': limiteVinculacion,
          'remainingDays': remainingDays,
          'activo': keyData['activo'],
        }
      };

      debugPrint('validateStudentKeyCode: Validation successful');
      return validationResult;
    } catch (e) {
      _error = e.toString();
      debugPrint('validateStudentKeyCode: Error: $_error');
      debugPrint('validateStudentKeyCode: Error type: ${e.runtimeType}');

      // Additional debugging: Let's check what keys exist
      try {
        debugPrint(
            'validateStudentKeyCode: DEBUG - Checking all keys with similar codes');
        final allKeysResponse = await _supabase
            .from('llaves')
            .select('id, codigo')
            .ilike('codigo',
                '%${keyCode.substring(0, math.min(keyCode.length, 5))}%')
            .limit(10);

        debugPrint(
            'validateStudentKeyCode: Found ${allKeysResponse.length} similar keys:');
        for (final key in allKeysResponse) {
          debugPrint(
              'validateStudentKeyCode: - ${key['codigo']} (${key['id']})');
        }

        // Also check exact match but without case sensitivity
        final exactMatchResponse = await _supabase
            .from('llaves')
            .select('id, codigo, id_alumno, id_escuela')
            .ilike('codigo', keyCode)
            .maybeSingle();

        if (exactMatchResponse != null) {
          debugPrint(
              'validateStudentKeyCode: Found exact match (case insensitive): $exactMatchResponse');
        } else {
          debugPrint(
              'validateStudentKeyCode: No exact match found even with case insensitive search');
        }
      } catch (debugError) {
        debugPrint('validateStudentKeyCode: Debug query failed: $debugError');
      }

      return null;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Method to register student with validated key
  Future<bool> registerStudentWithKey({
    required String keyId,
    required String studentId,
    required String tutorId,
  }) async {
    debugPrint('registerStudentWithKey: Starting registration');
    debugPrint(
        'registerStudentWithKey: keyId: $keyId, studentId: $studentId, tutorId: $tutorId');

    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      // Check if tutor is already linked to this student
      debugPrint('registerStudentWithKey: Checking for existing relationship');
      final existingRelation = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId)
          .maybeSingle();

      if (existingRelation != null) {
        debugPrint(
            'registerStudentWithKey: Tutor already linked to this student');
        throw Exception('Ya tienes este estudiante registrado');
      }

      debugPrint(
          'registerStudentWithKey: No existing relationship found, proceeding');

      // Get current key data before updating
      debugPrint('registerStudentWithKey: Getting current key data');
      final currentKeyData = await _supabase
          .from('llaves')
          .select('id, codigo, limite_vinculacion, activo, id_alumno')
          .eq('id', keyId)
          .single();

      final currentLimit = currentKeyData['limite_vinculacion'] as int;
      final currentActivo = currentKeyData['activo'] as bool;

      debugPrint('registerStudentWithKey: Current key data:');
      debugPrint('  - ID: ${currentKeyData['id']}');
      debugPrint('  - Código: ${currentKeyData['codigo']}');
      debugPrint('  - Limite actual: $currentLimit');
      debugPrint('  - Activo actual: $currentActivo');
      debugPrint('  - Alumno ID: ${currentKeyData['id_alumno']}');

      // Validate that we can still register
      if (currentLimit <= 0) {
        debugPrint('registerStudentWithKey: Limit already exhausted');
        throw Exception('Este código ya no permite más registros');
      }

      final newLimit = currentLimit - 1;
      debugPrint('registerStudentWithKey: Will update to new limit: $newLimit');

      // Update key: reduce limite_vinculacion by 1 and set activo to true
      debugPrint('registerStudentWithKey: Updating key in database');

      final updateResult = await _supabase
          .from('llaves')
          .update({
            'limite_vinculacion': newLimit,
            'activo': true,
          })
          .eq('id', keyId)
          .select('id, limite_vinculacion, activo');

      debugPrint('registerStudentWithKey: Key update result: $updateResult');

      if (updateResult.isEmpty) {
        debugPrint(
            'registerStudentWithKey: No rows were updated - key not found?');
        throw Exception('Error al actualizar la llave - llave no encontrada');
      }

      final updatedKey = updateResult.first;
      debugPrint('registerStudentWithKey: Updated key data:');
      debugPrint('  - Nuevo limite: ${updatedKey['limite_vinculacion']}');
      debugPrint('  - Nuevo activo: ${updatedKey['activo']}');

      // Verify the update was successful
      if (updatedKey['limite_vinculacion'] != newLimit) {
        debugPrint('registerStudentWithKey: Limite was not updated correctly');
        throw Exception('Error al actualizar el límite de vinculación');
      }

      if (updatedKey['activo'] != true) {
        debugPrint('registerStudentWithKey: Activo was not set to true');
        throw Exception('Error al activar la llave');
      }

      debugPrint('registerStudentWithKey: Key updated successfully');

      // Insert tutor-student relationship
      debugPrint('registerStudentWithKey: Creating tutor-student relationship');
      final relationshipResult = await _supabase.from('alumno_tutores').insert({
        'id_alumno': studentId,
        'id_tutor': tutorId,
        'fecha_vinculacion': DateTime.now().toIso8601String(),
      }).select('id, id_alumno, id_tutor, fecha_vinculacion');

      debugPrint(
          'registerStudentWithKey: Relationship creation result: $relationshipResult');

      if (relationshipResult.isEmpty) {
        debugPrint('registerStudentWithKey: Failed to create relationship');
        throw Exception('Error al crear la relación tutor-estudiante');
      }

      debugPrint('registerStudentWithKey: Relationship created successfully');

      // Reload user's students to include the new one
      debugPrint('registerStudentWithKey: Reloading user students');
      await loadStudentsForUser(userId: tutorId, forceReload: true);

      debugPrint('registerStudentWithKey: Registration completed successfully');
      debugPrint('registerStudentWithKey: Final summary:');
      debugPrint('  - Limite reducido de $currentLimit a $newLimit');
      debugPrint('  - Activo cambiado de $currentActivo a true');
      debugPrint('  - Relación tutor-estudiante creada');

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('registerStudentWithKey: Error: $_error');
      debugPrint('registerStudentWithKey: Error type: ${e.runtimeType}');

      // Additional debugging: Check current key state after error
      try {
        debugPrint('registerStudentWithKey: Checking key state after error');
        final errorCheckData = await _supabase
            .from('llaves')
            .select('id, codigo, limite_vinculacion, activo')
            .eq('id', keyId)
            .maybeSingle();

        if (errorCheckData != null) {
          debugPrint('registerStudentWithKey: Current key state after error:');
          debugPrint('  - Limite: ${errorCheckData['limite_vinculacion']}');
          debugPrint('  - Activo: ${errorCheckData['activo']}');
        }
      } catch (debugError) {
        debugPrint('registerStudentWithKey: Debug query failed: $debugError');
      }

      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Method to verify key state after registration
  Future<Map<String, dynamic>?> getKeyState(String keyId) async {
    debugPrint('getKeyState: Checking state for keyId: $keyId');

    try {
      final response = await _supabase
          .from('llaves')
          .select('id, codigo, limite_vinculacion, activo, id_alumno')
          .eq('id', keyId)
          .maybeSingle();

      if (response != null) {
        debugPrint('getKeyState: Current state:');
        debugPrint('  - ID: ${response['id']}');
        debugPrint('  - Código: ${response['codigo']}');
        debugPrint('  - Limite: ${response['limite_vinculacion']}');
        debugPrint('  - Activo: ${response['activo']}');
        debugPrint('  - Alumno ID: ${response['id_alumno']}');
      } else {
        debugPrint('getKeyState: Key not found');
      }

      return response;
    } catch (e) {
      debugPrint('getKeyState: Error: $e');
      return null;
    }
  }

  // New method to check if user already has this student registered
  Future<bool> checkIfUserAlreadyHasStudent({
    required String studentId,
    required String tutorId,
  }) async {
    debugPrint(
        'checkIfUserAlreadyHasStudent: Checking for studentId: $studentId, tutorId: $tutorId');

    try {
      final existingRelation = await _supabase
          .from('alumno_tutores')
          .select('id, fecha_vinculacion')
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId)
          .maybeSingle();

      final hasStudent = existingRelation != null;

      debugPrint(
          'checkIfUserAlreadyHasStudent: User already has student: $hasStudent');
      if (hasStudent) {
        debugPrint(
            'checkIfUserAlreadyHasStudent: Existing relationship found with fecha_vinculacion: ${existingRelation['fecha_vinculacion']}');
      }

      return hasStudent;
    } catch (e) {
      debugPrint(
          'checkIfUserAlreadyHasStudent: Error checking relationship: $e');
      return false; // In case of error, allow the process to continue
    }
  }

  void clearAllData() {
    _students.clear();
    _filteredStudents.clear();
    _selectedStudent = null;
    _availableGrupos.clear();
    _availableTurnos.clear();
    _isLoading = false;
    _error = null;
    _currentLoadingMode = null;
    _lastConvertedCount = 0;
    Future.microtask(() => notifyListeners());
  }
}
