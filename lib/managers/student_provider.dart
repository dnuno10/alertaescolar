import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import '../models/models.dart';
import '../models/turno.dart' as turno_model;

/// Alias breve para JSON
typedef Json = Map<String, dynamic>;

/// ------------------------------
/// Data classes
/// ------------------------------
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
  final DateTime? fechaRegistroLlave;
  final DateTime? fechaDesactivacionLlave;
  final int? limiteVinculacion;
  final List<TutorInfo> tutores;
  final List<Json> familyContacts;

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
    this.familyContacts = const [],
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
    List<Json>? familyContacts,
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
      familyContacts: familyContacts ?? this.familyContacts,
    );
  }

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

  String get tiempoRestanteFormateado {
    if (fechaRegistroLlave == null) return 'Información no disponible';
    final now = DateTime.now();

    if (limiteVinculacion == null || limiteVinculacion == 0) {
      return 'Sin límite de tiempo';
    }

    final expirationDate =
        fechaRegistroLlave!.add(Duration(days: limiteVinculacion!));

    if (expirationDate.isBefore(now)) return 'Expirado';

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

/// ------------------------------
/// Provider
/// ------------------------------
class StudentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<StudentDetails> _students = [];
  List<StudentDetails> _filteredStudents = [];
  StudentDetails? _selectedStudent;

  // Filtros auxiliares
  List<Grupo> _availableGrupos = [];
  List<turno_model.Turno> _availableTurnos = [];
  List<String> _availableNivelesEducativos = [];

  bool _isLoading = false;
  String? _error;

  /// 'admin' o 'user' para no sobreescribir listas accidentalmente
  String? _currentLoadingMode;

  int _lastConvertedCount = 0;

  // --- Realtime (canales)
  RealtimeChannel? _chAlumnos;
  RealtimeChannel? _chLlaves;
  RealtimeChannel? _chVinculos;

  // Contexto actual para recargar según modo
  String? _currentSchoolId;

  // Helper para ordenar estudiantes: activos primero, después inactivos, luego por nombre
  void _sortStudentsByActiveStatus(List<StudentDetails> students) {
    students.sort((a, b) {
      final aActive = a.hasTutores && _isLlaveVigenteFor(a);
      final bActive = b.hasTutores && _isLlaveVigenteFor(b);

      // Si uno es activo y el otro no, el activo va primero
      if (aActive && !bActive) return -1;
      if (!aActive && bActive) return 1;

      // Si ambos tienen el mismo estado, ordenar por nombre
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
  }

  // Getters
  List<StudentDetails> get students => _students;
  List<StudentDetails> get filteredStudents => _filteredStudents;
  StudentDetails? get selectedStudent => _selectedStudent;
  List<Grupo> get availableGrupos => _availableGrupos;
  List<turno_model.Turno> get availableTurnos => _availableTurnos;
  List<String> get availableNivelesEducativos => _availableNivelesEducativos;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ------------------------------
  // Helpers privados
  // ------------------------------

  String? _normalizeUuid(String? raw) {
    final s = (raw ?? '').trim();
    return s.isEmpty ? null : s;
  }

  final Map<String, String> _adminEscuelaCacheByUserId = {};

  // NUEVO: grupos por nivel educativo
  List<Grupo> getGruposByNivelEducativo(String nivelEducativo) {
    if (nivelEducativo.trim().isEmpty) return const [];
    return _availableGrupos
        .where((g) => g.nivelEducativo == nivelEducativo)
        .toList();
  }

  // ===== Etiquetas legibles (id -> nombre) =====

  String grupoLabelById(String? id) {
    if (id == null || id.isEmpty) return 'Sin grupo';
    final g = _availableGrupos.firstWhere(
      (x) => x.id == id,
      orElse: () => Grupo(
          id: '',
          idEscuela: '',
          grupo: 'Sin grupo',
          nivelEducativo: 'Sin nivel',
          fechaRegistro: DateTime.now()),
    );
    if (g.id.isEmpty) return 'Sin grupo';
    // Ej: "Primaria - 3°B"
    return '${g.nivelEducativo} - ${g.grupo}';
  }

  String turnoLabelById(String? id) {
    if (id == null || id.isEmpty) return 'Sin turno';
    final t = _availableTurnos.firstWhere(
      (x) => x.id == id,
      orElse: () => turno_model.Turno(
          id: '',
          turno: 'Sin turno',
          horaInicio: '',
          horaFin: '',
          fechaRegistro: DateTime.now(),
          idEscuela: '',
          tolerancia: 15),
    );
    return t.turno;
  }

  String alumnoLabelById(String? id) {
    if (id == null || id.isEmpty) return 'Sin estudiante';
    final s = _students.firstWhere(
      (x) => x.id == id,
      orElse: () => StudentDetails(
        id: '',
        nombre: 'Sin estudiante',
        matricula: '',
        escuelaId: '',
        grupoId: '',
        grupo: 'Sin grupo',
        nivelEducativo: 'Sin nivel',
        llaveActiva: false,
        fechaRegistro: DateTime.now(),
        tutores: const [],
      ),
    );
    // Ej: "María López (AE1234)"
    return s.matricula.isNotEmpty ? '${s.nombre} (${s.matricula})' : s.nombre;
  }

// ===== Ítems listos para DropdownButtonFormField =====

  List<DropdownMenuItem<String>> gruposDropdownItems() {
    return _availableGrupos
        .map((g) => DropdownMenuItem<String>(
              value: g.id,
              child: Text('${g.nivelEducativo} - ${g.grupo}'),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> turnosDropdownItems() {
    return _availableTurnos
        .map((t) => DropdownMenuItem<String>(
              value: t.id,
              child: Text(t.turno),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> alumnosDropdownItems() {
    // Usa _filteredStudents para respetar búsqueda/filtros activos
    return _filteredStudents
        .map((s) => DropdownMenuItem<String>(
              value: s.id,
              child: Text(s.matricula.isNotEmpty
                  ? '${s.nombre} (${s.matricula})'
                  : s.nombre),
            ))
        .toList();
  }

  // NUEVO: nombres de grupo por nivel educativo
  List<String> getGrupoNamesByNivelEducativo(String nivelEducativo) {
    final names = getGruposByNivelEducativo(nivelEducativo)
        .map((g) => g.grupo)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  Future<String?> getAdminEscuelaUuidByUserId(String userId) async {
    if (_adminEscuelaCacheByUserId.containsKey(userId)) {
      return _adminEscuelaCacheByUserId[userId];
    }

    try {
      final userRow = await _supabase
          .from('usuarios')
          .select('email')
          .eq('id', userId)
          .maybeSingle();

      final email = (userRow?['email']?.toString() ?? '').trim().toLowerCase();
      if (email.isEmpty) {
        debugPrint('getAdminEscuelaUuidByUserId: email vacío para $userId');
        return null;
      }

      final adminRow = await _supabase
          .from('admin_access_list')
          .select('id_escuela')
          .ilike('email', email)
          .maybeSingle();

      final escuelaUuid = _normalizeUuid(adminRow?['id_escuela']?.toString());

      if (escuelaUuid != null) {
        _adminEscuelaCacheByUserId[userId] = escuelaUuid;
      } else {
        debugPrint(
            'getAdminEscuelaUuidByUserId: no match en admin_access_list para $email');
      }

      return escuelaUuid;
    } catch (e) {
      debugPrint('getAdminEscuelaUuidByUserId error: $e');
      return null;
    }
  }

  String? _fmtHora(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) return s;
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(s)) return s.substring(0, 5);
    try {
      final dt = DateTime.parse(s);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value, {String? mode}) {
    _isLoading = value;
    if (mode != null) _currentLoadingMode = mode;
    Future.microtask(notifyListeners);
  }

  void _setError(String? err) {
    _error = err;
    Future.microtask(notifyListeners);
  }

  void _disposeRealtime() {
    _chAlumnos?.unsubscribe();
    _chLlaves?.unsubscribe();
    _chVinculos?.unsubscribe();
    _chAlumnos = _chLlaves = _chVinculos = null;
  }

  /// Verifica si un estudiante específico está vinculado a un usuario específico
  Future<bool> _isStudentLinkedToUser(String studentId, String userId) async {
    try {
      final result = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .eq('id_tutor', userId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      debugPrint('Error checking student link: $e');
      return false;
    }
  }

  /// Verifica si una llave específica pertenece a un alumno vinculado a un usuario específico
  Future<bool> _isKeyLinkedToUser(String keyId, String userId) async {
    try {
      final result = await _supabase
          .from('llaves')
          .select('id_alumno')
          .eq('id', keyId)
          .maybeSingle();

      if (result == null) return false;

      final studentId = result['id_alumno']?.toString();
      if (studentId == null) return false;

      return await _isStudentLinkedToUser(studentId, userId);
    } catch (e) {
      debugPrint('Error checking key link: $e');
      return false;
    }
  }

  void _startRealtimeForUser(String userId) {
    _disposeRealtime();

    // Para padres de familia: Solo escuchar cambios específicos a sus estudiantes vinculados
    _chAlumnos = _supabase.channel('alumnos_user_$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'alumnos',
        callback: (payload) async {
          // Solo recargar si el cambio afecta a un alumno vinculado a este usuario
          final alumnoId = payload.newRecord['id']?.toString() ??
              payload.oldRecord['id']?.toString();
          if (alumnoId != null &&
              await _isStudentLinkedToUser(alumnoId, userId)) {
            debugPrint('Realtime: Alumno $alumnoId changed for user $userId');
            await loadStudentsForUser(userId: userId, forceReload: true);
          }
        },
      )
      ..subscribe();

    _chLlaves = _supabase.channel('llaves_user_$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'llaves',
        callback: (payload) async {
          // Solo recargar si la llave pertenece a un alumno vinculado a este usuario
          final llaveId = payload.newRecord['id']?.toString() ??
              payload.oldRecord['id']?.toString();
          if (llaveId != null && await _isKeyLinkedToUser(llaveId, userId)) {
            debugPrint('Realtime: Llave $llaveId changed for user $userId');
            await loadStudentsForUser(userId: userId, forceReload: true);
          }
        },
      )
      ..subscribe();

    _chVinculos = _supabase.channel('alumno_tutores_user_$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'alumno_tutores',
        // Filtro por tutor ↓ (reduce ruido)
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_tutor',
          value: userId,
        ),
        callback: (payload) async {
          debugPrint('Realtime: Vínculo alumno-tutor changed for user $userId');
          await loadStudentsForUser(userId: userId, forceReload: true);
        },
      )
      ..subscribe();
  }

  void _startRealtimeForSchool(String schoolId) {
    _disposeRealtime();

    _chAlumnos = _supabase.channel('alumnos_school_$schoolId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'alumnos',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: schoolId,
        ),
        callback: (payload) async {
          // Solo recargar si estamos en modo administrador
          if (_currentLoadingMode == 'admin') {
            debugPrint(
                'Realtime: Alumno changed in school $schoolId (admin mode)');
            await loadStudents(escuelaId: schoolId);
          } else {
            debugPrint('Realtime: Ignoring alumno change - not in admin mode');
          }
        },
      )
      ..subscribe();

    _chLlaves = _supabase.channel('llaves_school_$schoolId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'llaves',
        callback: (payload) async {
          // Solo recargar si estamos en modo administrador
          if (_currentLoadingMode == 'admin') {
            debugPrint(
                'Realtime: Llave changed in school $schoolId (admin mode)');
            await loadStudents(escuelaId: schoolId);
          } else {
            debugPrint('Realtime: Ignoring llave change - not in admin mode');
          }
        },
      )
      ..subscribe();

    _chVinculos = _supabase.channel('alumno_tutores_school_$schoolId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'alumno_tutores',
        callback: (payload) async {
          // Solo recargar si estamos en modo administrador
          if (_currentLoadingMode == 'admin') {
            debugPrint(
                'Realtime: Vínculo changed in school $schoolId (admin mode)');
            await loadStudents(escuelaId: schoolId);
          } else {
            debugPrint('Realtime: Ignoring vínculo change - not in admin mode');
          }
        },
      )
      ..subscribe();
  }

  // ------------------------------
  // 🚀 API pública (NUEVO: métodos explícitos)
  // ------------------------------

  Future<void> startRealtimeForTutor(String userId) async {
    _startRealtimeForUser(userId);
  }

  Future<void> startRealtimeForSchool(String schoolId) async {
    _startRealtimeForSchool(schoolId);
  }

  // ------------------------------
  // API pública existente
  // ------------------------------

  void clearError() => _setError(null);

  Future<String?> getUserSchoolId(String userId) async {
    debugPrint('getUserSchoolId: userId=$userId');
    try {
      final resp = await _supabase.from('alumno_tutores').select('''
            alumnos!inner(id_escuela)
          ''').eq('id_tutor', userId).limit(1);

      if (resp.isNotEmpty) {
        final alumno = resp[0]['alumnos'] as Json?;
        final id = _normalizeUuid(alumno?['id_escuela']?.toString());
        return id;
      }
      return null;
    } catch (e) {
      debugPrint('getUserSchoolId error: $e');
      return null;
    }
  }

  Future<void> loadStudentsForUser({
    required String userId,
    String? grupoId,
    String? turnoId,
    bool forceReload = false,
  }) async {
    debugPrint('loadStudentsForUser: userId=$userId, force=$forceReload');

    // Cambiar a contexto de usuario y limpiar datos admin si es necesario
    switchToUserContext(userId);

    // Solo skipear si estamos en loading para evitar llamadas concurrentes
    if (_isLoading && _currentLoadingMode == 'user' && !forceReload) {
      debugPrint('loadStudentsForUser: skipping (already loading user data)');
      return;
    }

    try {
      _setLoading(true, mode: 'user');
      _setError(null);

      // Base query: alumnos vinculados al tutor
      var query = _supabase.from('alumno_tutores').select('''
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

      // Filtros opcionales sobre campos del alumno (cuando apliquen)
      if (grupoId != null && grupoId.isNotEmpty) {
        query = query.eq('alumnos.id_grupo', grupoId);
      }
      if (turnoId != null && turnoId.isNotEmpty) {
        query = query.eq('alumnos.id_turno', turnoId);
      }

      final response = await query;

      // VALIDACIÓN ADICIONAL: Verificar que la respuesta solo contenga vínculos del usuario correcto
      debugPrint(
          'loadStudentsForUser: Found ${response.length} student links for user $userId');

      // Mapear a StudentDetails
      final list = <StudentDetails>[];
      for (final item in response) {
        final alumno = Map<String, dynamic>.from(item['alumnos'] as Map);
        final usuario = Map<String, dynamic>.from(item['usuarios'] as Map);
        final fechaVinc = item['fecha_vinculacion']?.toString() ??
            DateTime.now().toIso8601String();

        // VALIDACIÓN DE SEGURIDAD: Asegurar que el tutor ID coincida
        if (usuario['id']?.toString() != userId) {
          debugPrint(
              'WARNING: Skipping student ${alumno['id']} - tutor mismatch. Expected: $userId, Got: ${usuario['id']}');
          continue;
        }

        // Incrustar datos de vínculo/usuario para el mapper existente
        alumno['alumno_tutores'] = [
          {
            'id_tutor': userId,
            'fecha_vinculacion': fechaVinc,
            'usuarios': {
              'id': usuario['id'],
              'nombre': usuario['nombre'] ?? '',
              'apellido': usuario['apellido'] ?? '',
              'email': usuario['email'] ?? '',
              'contactos_familiares': usuario['contactos_familiares'] ?? [],
            }
          }
        ];

        final sd = _mapToStudentDetailsWithContacts(alumno);
        list.add(sd);
      }

      // Ordenar por nombre (case-insensitive)
      list.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // VALIDACIÓN FINAL: Asegurar que todos los estudiantes pertenecen al usuario
      final validatedList = list.where((student) {
        final belongsToUser =
            student.tutores.any((tutor) => tutor.id == userId);
        if (!belongsToUser) {
          debugPrint(
              'WARNING: Removing student ${student.id} (${student.nombre}) - no valid tutor link for user $userId');
          return false;
        }
        return true;
      }).toList();

      debugPrint(
          'loadStudentsForUser: Final count after validation: ${validatedList.length}/${list.length}');

      // Publicar en estado
      _students = validatedList;
      _filteredStudents = List.from(_students);

      // Ordenar: primero activos, después inactivos
      _sortStudentsByActiveStatus(
          _filteredStudents); // Resolver escuela (primero por tutor, fallback admin)
      String? resolvedSchool = _normalizeUuid(await getUserSchoolId(userId)) ??
          _normalizeUuid(await getAdminEscuelaUuidByUserId(userId));

      _currentSchoolId = resolvedSchool;
      debugPrint('loadStudentsForUser: resolved schoolId = $_currentSchoolId');

      // Para padres de familia: SIEMPRE usar filtros específicos por usuario
      // No importa si conocemos la escuela, evitamos contaminación cruzada
      _startRealtimeForUser(userId);

      _setError(null);
    } catch (e) {
      _setError('Error al cargar estudiantes del usuario: $e');
      debugPrint('loadStudentsForUser error: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool _isLlaveVigenteFor(StudentDetails s) {
    if (s.fechaRegistroLlave == null) return false;
    final now = DateTime.now();
    final start = s.fechaRegistroLlave!;
    final end = s.fechaDesactivacionLlave;
    final startOk = !now.isBefore(start);
    final endOk = (end == null) || !now.isAfter(end);
    return startOk && endOk;
  }

  Future<List<StudentDetails>> getFilteredBy({
    String? escuelaId,
    String? searchQuery,
    String? grupo,
    String? nivelEducativo,
    String? status,
    String? turno,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _supabase.from('alumnos').select('''
    id, nombre, matricula, id_grupo, id_turno, id_escuela,
    grupos(id, grupo, nivel_educativo),
    turnos(id, turno, hora_inicio, hora_fin),
    llaves(id, codigo, activo, fecha_registro, fecha_desactivacion, limite_vinculacion),
    alumno_tutores(id_tutor, fecha_vinculacion)
  ''');

    if (escuelaId != null) query = query.eq('id_escuela', escuelaId);

    if (grupo != null && grupo != 'all') query = query.eq('id_grupo', grupo);
    if (nivelEducativo != null && nivelEducativo != 'all') {
      query = query.eq('grupos.nivel_educativo', nivelEducativo);
    }
    if (turno != null && turno != 'all') query = query.eq('id_turno', turno);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('nombre', '%$searchQuery%');
      // podrías extender a matricula también
    }

    final response =
        await query.order('nombre').range(offset, offset + limit - 1);

    final students = <StudentDetails>[];
    for (final item in response) {
      students.add(await _mapToStudentDetailsWithSeparateContacts(
        Map<String, dynamic>.from(item as Map),
      ));
    }
    return students;
  }

  Future<void> loadStudentById({required String studentId}) async {
    debugPrint('loadStudentById: $studentId');
    try {
      _setLoading(true);
      _setError(null);

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

      final full = _mapToStudentDetailsWithContacts(
        Map<String, dynamic>.from(response),
      );

      setSelectedStudent(full);
    } catch (e) {
      _setError('Error al cargar estudiante: $e');
      debugPrint('loadStudentById error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudents(
      {String? escuelaId,
      String? userId,
      String? grupoId,
      String? turnoId,
      int limit = 50, // Número de registros por página
      int offset = 0, // Desde dónde empezar
      bool append = false // true = acumular, false = reemplazar
      }) async {
    debugPrint(
        'loadStudents (ADMIN MODE): escuelaId=$escuelaId userId=$userId offset=$offset limit=$limit append=$append');

    // Solo skipear si estamos cargando en modo admin para evitar llamadas concurrentes
    if (_isLoading && _currentLoadingMode == 'admin') {
      debugPrint('loadStudents: skipping (already loading admin data)');
      return;
    }

    // Cambiar a contexto de admin y limpiar datos user si es necesario
    if (escuelaId != null) {
      switchToAdminContext(escuelaId);
    }

    try {
      _setLoading(true, mode: 'admin');
      _setError(null);

      String? schoolId = _normalizeUuid(escuelaId);

      if (userId != null && schoolId == null) {
        schoolId = _normalizeUuid(await getUserSchoolId(userId));
        if (schoolId == null) {
          schoolId = _normalizeUuid(await getAdminEscuelaUuidByUserId(userId));
          if (schoolId != null) {
            debugPrint('loadStudents: escuela resuelta por ADMIN ($schoolId)');
          }
        } else {
          debugPrint('loadStudents: escuela resuelta por TUTOR ($schoolId)');
        }

        if (schoolId == null) {
          throw Exception('No se encontró escuela asociada al usuario');
        }
      }

      if (schoolId == null) {
        throw Exception(
            'Se requiere escuelaId o userId para cargar estudiantes');
      }

      await _loadFilteringData(schoolId);

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
    ''');

      if (schoolId.trim().isEmpty) {
        throw Exception('El id_escuela resuelto está vacío');
      }

      query = query.eq('id_escuela', schoolId);

      if (grupoId != null) query = query.eq('id_grupo', grupoId);
      if (turnoId != null) query = query.eq('id_turno', turnoId);

      // 👇 Paginación real
      final response =
          await query.order('nombre').range(offset, offset + limit - 1);

      if (!append) _students = [];

      for (final item in response) {
        final sd = await _mapToStudentDetailsWithSeparateContacts(
          Map<String, dynamic>.from(item as Map),
        );
        _students.add(sd);
      }

      _filteredStudents = List.from(_students);

      // Ordenar: primero activos, después inactivos
      _sortStudentsByActiveStatus(_filteredStudents);
      _currentSchoolId = schoolId;

      debugPrint(
          'loadStudents (ADMIN MODE): Loaded ${response.length} students (total now ${_students.length}) for school $schoolId [offset=$offset, limit=$limit, append=$append]');

      if (!append) {
        // Solo iniciar realtime la primera vez (no en scroll infinito)
        _startRealtimeForSchool(schoolId);
      }

      _setError(null);
    } catch (e) {
      _setError('Error al cargar estudiantes: $e');
      debugPrint('loadStudents error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------
  // Mappers
  // ------------------------------
  Future<StudentDetails> _mapToStudentDetailsWithSeparateContacts(
    Map<String, dynamic> data,
  ) async {
    final grupo = data['grupos'] as Map?;
    final turno = data['turnos'] as Map?;
    final llaves = data['llaves'] as List?;
    final tutoresBasic = data['alumno_tutores'] as List?;

    Map<String, dynamic>? latestKey;
    if (llaves != null && llaves.isNotEmpty) {
      for (final raw in llaves) {
        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);
          if (latestKey == null) {
            latestKey = m;
          } else {
            final a = _parseDate(latestKey['fecha_registro']) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final b = _parseDate(m['fecha_registro']) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            if (b.isAfter(a)) latestKey = m;
          }
        }
      }
    }

    final tutorsList = <TutorInfo>[];
    final familyContacts = <Json>[];

    if (tutoresBasic != null && tutoresBasic.isNotEmpty) {
      for (final tb in tutoresBasic) {
        final tutorId = tb['id_tutor']?.toString();
        final fechaVinc = _parseDate(tb['fecha_vinculacion']) ?? DateTime.now();
        if (tutorId == null) continue;

        try {
          final tutorResp = await _supabase
              .from('usuarios')
              .select('id, nombre, apellido, email')
              .eq('id', tutorId)
              .maybeSingle();

          if (tutorResp != null) {
            tutorsList.add(TutorInfo(
              id: tutorResp['id'].toString(),
              nombre: (tutorResp['nombre'] ?? '').toString(),
              apellido: (tutorResp['apellido'] ?? '').toString(),
              email: (tutorResp['email'] ?? '').toString(),
              telefono: null,
              fechaVinculacion: fechaVinc,
            ));

            try {
              final contactsResp = await _supabase
                  .from('contactos_familiares')
                  .select(
                      'id, id_usuario, nombre, parentesco, telefono, email, fecha_registro')
                  .eq('id_usuario', tutorId);
              familyContacts.addAll(List<Json>.from(
                  contactsResp.map((e) => Map<String, dynamic>.from(e))));
            } catch (_) {}
          } else {
            tutorsList.add(TutorInfo(
              id: tutorId,
              nombre: '',
              apellido: '',
              email: '',
              telefono: null,
              fechaVinculacion: fechaVinc,
            ));
          }
        } catch (_) {
          tutorsList.add(TutorInfo(
            id: tutorId,
            nombre: '',
            apellido: '',
            email: '',
            telefono: null,
            fechaVinculacion: fechaVinc,
          ));
        }
      }
    }

    final now = DateTime.now();
    final hasKey = latestKey != null;
    final fRegL = hasKey ? _parseDate(latestKey['fecha_registro']) : null;
    final fDesL = hasKey ? _parseDate(latestKey['fecha_desactivacion']) : null;

    final vigente = hasKey &&
        fRegL != null &&
        !now.isBefore(fRegL) &&
        (fDesL == null || !now.isAfter(fDesL));

    return StudentDetails(
      id: data['id'].toString(),
      nombre: (data['nombre'] ?? '').toString(),
      matricula: (data['matricula'] ?? '').toString(),
      escuelaId: (data['id_escuela'] ?? '').toString(),
      grupoId: (grupo?['id'] ?? '').toString(),
      grupo: (grupo?['grupo'] ?? 'Sin grupo').toString(),
      nivelEducativo: (grupo?['nivel_educativo'] ?? 'Sin nivel').toString(),
      turnoId: turno?['id']?.toString(),
      turno: turno?['turno']?.toString() ?? 'Sin turno',
      horaInicioTurno: _fmtHora(turno?['hora_inicio']),
      horaFinTurno: _fmtHora(turno?['hora_fin']),
      llaveId: latestKey?['id']?.toString(),
      llaveCodigo: latestKey?['codigo']?.toString(),
      llaveActiva: vigente,
      fechaRegistro: _parseDate(data['fecha_registro']) ?? DateTime.now(),
      fechaRegistroLlave: fRegL,
      fechaDesactivacionLlave: fDesL,
      limiteVinculacion: latestKey?['limite_vinculacion'] is num
          ? (latestKey?['limite_vinculacion'] as num).toInt()
          : null,
      tutores: tutorsList,
      familyContacts: familyContacts,
    );
  }

  StudentDetails _mapToStudentDetailsWithContacts(Map<String, dynamic> data) {
    final grupo = data['grupos'] as Map?;
    final turno = data['turnos'] as Map?;
    final llaves = data['llaves'] as List?;
    final tutores = data['alumno_tutores'] as List?;

    Map<String, dynamic>? latestKey;
    if (llaves != null && llaves.isNotEmpty) {
      for (final raw in llaves) {
        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);
          if (latestKey == null) {
            latestKey = m;
          } else {
            final a = _parseDate(latestKey['fecha_registro']) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final b = _parseDate(m['fecha_registro']) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            if (b.isAfter(a)) latestKey = m;
          }
        }
      }
    }

    final tutorsList = <TutorInfo>[];
    final familyContacts = <Json>[];

    if (tutores != null) {
      for (final t in tutores) {
        final usuario = t['usuarios'];
        final fechaVinc = _parseDate(t['fecha_vinculacion']) ?? DateTime.now();

        if (usuario != null) {
          tutorsList.add(TutorInfo(
            id: usuario['id'].toString(),
            nombre: (usuario['nombre'] ?? '').toString(),
            apellido: (usuario['apellido'] ?? '').toString(),
            email: (usuario['email'] ?? '').toString(),
            telefono: null,
            fechaVinculacion: fechaVinc,
          ));

          final contacts = usuario['contactos_familiares'] as List?;
          if (contacts != null) {
            familyContacts.addAll(List<Json>.from(
                contacts.map((e) => Map<String, dynamic>.from(e))));
          }
        } else {
          final idTutor = t['id_tutor']?.toString() ?? '';
          tutorsList.add(TutorInfo(
            id: idTutor,
            nombre: '',
            apellido: '',
            email: '',
            telefono: null,
            fechaVinculacion: fechaVinc,
          ));
        }
      }
    }

    final now = DateTime.now();
    final hasKey = latestKey != null;
    final fRegL = hasKey ? _parseDate(latestKey['fecha_registro']) : null;
    final fDesL = hasKey ? _parseDate(latestKey['fecha_desactivacion']) : null;

    final vigente = hasKey &&
        fRegL != null &&
        !now.isBefore(fRegL) &&
        (fDesL == null || !now.isAfter(fDesL));

    return StudentDetails(
      id: data['id'].toString(),
      nombre: (data['nombre'] ?? '').toString(),
      matricula: (data['matricula'] ?? '').toString(),
      escuelaId: (data['id_escuela'] ?? '').toString(),
      grupoId: (grupo?['id'] ?? '').toString(),
      grupo: (grupo?['grupo'] ?? 'Sin grupo').toString(),
      nivelEducativo: (grupo?['nivel_educativo'] ?? 'Sin nivel').toString(),
      turnoId: turno?['id']?.toString(),
      turno: turno?['turno']?.toString() ?? 'Sin turno',
      horaInicioTurno: _fmtHora(turno?['hora_inicio']),
      horaFinTurno: _fmtHora(turno?['hora_fin']),
      llaveId: latestKey?['id']?.toString(),
      llaveCodigo: latestKey?['codigo']?.toString(),
      llaveActiva: vigente,
      fechaRegistro: _parseDate(data['fecha_registro']) ?? DateTime.now(),
      fechaRegistroLlave: fRegL,
      fechaDesactivacionLlave: fDesL,
      limiteVinculacion: latestKey?['limite_vinculacion'] is num
          ? (latestKey?['limite_vinculacion'] as num).toInt()
          : null,
      tutores: tutorsList,
      familyContacts: familyContacts,
    );
  }

  // ------------------------------
  // Filtros y catálogos
  // ------------------------------
  Future<void> _loadFilteringData(String escuelaId) async {
    final eid = _normalizeUuid(escuelaId);
    if (eid == null) {
      debugPrint('_loadFilteringData: escuelaId vacío, skip');
      return;
    }

    try {
      final nivelesResponse = await _supabase
          .from('niveles_educativos')
          .select('nombre')
          .eq('id_escuela', eid)
          .order('nombre');

      _availableNivelesEducativos = (nivelesResponse as List)
          .map((row) => (row['nombre'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      final gruposResponse = await _supabase
          .from('grupos')
          .select()
          .eq('id_escuela', eid)
          .order('nivel_educativo')
          .order('grupo');

      _availableGrupos =
          (gruposResponse as List).map((item) => Grupo.fromJson(item)).toList();

      final turnosResponse = await _supabase
          .from('turnos')
          .select()
          .eq('id_escuela', eid)
          .order('turno');

      _availableTurnos = (turnosResponse as List)
          .map((item) => turno_model.Turno.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('_loadFilteringData error: $e');
    }
  }

  void filterStudents({
    String? searchQuery,
    String? grupo,
    String? nivelEducativo,
    String? status,
    String? turno,
  }) {
    _filteredStudents = _students.where((s) {
      bool matchesSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        matchesSearch = s.nombre.toLowerCase().contains(q) ||
            s.matricula.toLowerCase().contains(q) ||
            s.id.toLowerCase().contains(q);
      }

      final matchesGrupo =
          (grupo == null || grupo == 'all') ? true : s.grupo == grupo;
      final matchesNivel = (nivelEducativo == null || nivelEducativo == 'all')
          ? true
          : s.nivelEducativo == nivelEducativo;

      bool matchesStatus = true;
      if (status != null && status != 'all') {
        final consideredActive = s.hasTutores && _isLlaveVigenteFor(s);
        matchesStatus = (status == 'active' && consideredActive) ||
            (status == 'inactive' && !consideredActive);
      }

      final matchesTurno =
          (turno == null || turno == 'all') ? true : (s.turno ?? '') == turno;

      return matchesSearch &&
          matchesGrupo &&
          matchesNivel &&
          matchesStatus &&
          matchesTurno;
    }).toList();

    // Ordenar: primero activos, después inactivos, luego por nombre
    _sortStudentsByActiveStatus(_filteredStudents);
    notifyListeners();
  }

  List<String> getAvailableGrupoNames() {
    return _availableGrupos.map((g) => g.grupo).toList();
  }

  List<String> getAvailableNivelesEducativos() {
    return List<String>.from(_availableNivelesEducativos);
  }

  List<String> getAvailableTurnoNames() {
    return _availableTurnos.map((t) => t.turno).toList();
  }

  // ------------------------------
  // Mutaciones
  // ------------------------------
  Future<bool> updateStudent({
    required String studentId,
    String? nombre,
    String? matricula,
    String? grupoId,
    String? turnoId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (matricula != null) data['matricula'] = matricula;
      if (grupoId != null) data['id_grupo'] = grupoId;
      if (turnoId != null) data['id_turno'] = turnoId;

      await _supabase.from('alumnos').update(data).eq('id', studentId);

      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) {
        await loadStudentById(studentId: studentId);
        if (_selectedStudent != null) {
          _students[idx] = _selectedStudent!;
          _filteredStudents = List.from(_students);
          _sortStudentsByActiveStatus(_filteredStudents);
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError('Error al actualizar estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deactivateStudent({required String studentId}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase.from('llaves').update({
        'activo': false,
        'fecha_desactivacion': DateTime.now().toIso8601String(),
      }).eq('id_alumno', studentId);

      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) {
        _students[idx] = _students[idx].copyWith(llaveActiva: false);
        _filteredStudents = List.from(_students);
        _sortStudentsByActiveStatus(_filteredStudents);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Error al desactivar estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> activateStudent({required String studentId}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('llaves')
          .update({'activo': true}).eq('id_alumno', studentId);

      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) {
        _students[idx] = _students[idx].copyWith(llaveActiva: true);
        _filteredStudents = List.from(_students);
        _sortStudentsByActiveStatus(_filteredStudents);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Error al activar estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> linkTutor({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase.from('alumno_tutores').insert({
        'id_alumno': studentId,
        'id_tutor': tutorId,
        'fecha_vinculacion': DateTime.now().toIso8601String(),
      }).select('id');

      await loadStudentsForUser(userId: tutorId, forceReload: true);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> unlinkTutor({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('alumno_tutores')
          .delete()
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId);

      await loadStudentById(studentId: studentId);
      return true;
    } catch (e) {
      _setError('Error al desvincular tutor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------
  // Queries derivadas
  // ------------------------------
  List<StudentDetails> getStudentsByGrupo(String grupoId) {
    return _students.where((s) => s.grupoId == grupoId).toList();
  }

  List<StudentDetails> getStudentsByTurno(String turnoId) {
    return _students.where((s) => s.turnoId == turnoId).toList();
  }

  List<String> getAvailableGrades() {
    final grades = _students
        .map((s) => s.nivelEducativo)
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    grades.sort();
    return grades;
  }

  List<String> getAvailableGroups() {
    final groups = _students
        .map((s) => s.grupo.split(' ').last)
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();
    return groups;
  }

  List<String> getAvailableTurnos() {
    final turnos = _students
        .map((s) => s.turno)
        .where((t) => (t ?? '').isNotEmpty)
        .map((t) => t!)
        .toSet()
        .toList();
    turnos.sort();
    return turnos;
  }

  List<Alumno> getAlumnosFromStudents() {
    final studentsToConvert = List<StudentDetails>.from(_filteredStudents);
    if (studentsToConvert.length != _lastConvertedCount) {
      _lastConvertedCount = studentsToConvert.length;
    }

    try {
      return studentsToConvert.map((s) {
        final displayGroup = s.nivelEducativo.isNotEmpty && s.grupo.isNotEmpty
            ? '${s.nivelEducativo} - ${s.grupo}'
            : s.grupo;

        return Alumno(
          id: s.id,
          nombre: s.nombre,
          idGrupo: s.grupoId,
          grupo: displayGroup,
          idEscuela: s.escuelaId,
          matricula: s.matricula,
          fechaRegistro: s.fechaRegistro,
          idTurno: s.turnoId ?? '',
          turno: _mapTurnoEnumFromString(s.turno),
          idLlave: s.llaveId,
          vinculado: s.llaveActiva,
        );
      }).toList();
    } catch (e) {
      debugPrint('getAlumnosFromStudents error: $e');
      return [];
    }
  }

  TurnoEnum _mapTurnoEnumFromString(String? turnoString) {
    if (turnoString == null || turnoString.trim().isEmpty) {
      return TurnoEnum.desconocido;
    }
    final tl = turnoString.toLowerCase();
    if (tl.contains('vespertino') || tl.contains('tarde')) {
      return TurnoEnum.vespertino;
    }
    if (tl.contains('matutino') ||
        tl.contains('mañana') ||
        tl.contains('manana')) {
      return TurnoEnum.matutino;
    }
    return TurnoEnum.desconocido;
  }

  void setSelectedStudent(StudentDetails? student) {
    _selectedStudent = student;
    Future.microtask(notifyListeners);
  }

  void clearStudents() {
    _disposeRealtime();
    _students.clear();
    _filteredStudents.clear();
    _selectedStudent = null;
    _availableGrupos.clear();
    _availableTurnos.clear();
    _isLoading = false;
    _error = null;
    _currentLoadingMode = null;
    _currentSchoolId = null;
    _lastConvertedCount = 0;
    Future.microtask(notifyListeners);
  }

  Future<List<Json>> loadFamilyContactsForStudent(String studentId) async {
    try {
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

      final familyContacts = <Json>[];
      for (final t in response) {
        final usuario = t['usuarios'];
        final contacts = usuario?['contactos_familiares'] as List?;
        if (contacts != null) {
          familyContacts.addAll(List<Json>.from(
              contacts.map((e) => Map<String, dynamic>.from(e))));
        }
      }
      return familyContacts;
    } catch (e) {
      debugPrint('loadFamilyContactsForStudent error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> validateStudentKeyCode(String keyCode) async {
    debugPrint('validateStudentKeyCode: code=$keyCode');
    try {
      _setLoading(true);
      _setError(null);

      final keyExists = await _supabase
          .from('llaves')
          .select('id, codigo, id_alumno, activo')
          .eq('codigo', keyCode)
          .maybeSingle();

      if (keyExists == null) {
        _setError('Código de estudiante no encontrado');
        return null;
      }

      final alumnoWithSchool = await _supabase.from('alumnos').select('''
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
        ),
        escuelas(
          id,
          nombre,
          codigo,
          tipo,
          direccion,
          telefono,
          email,
          fecha_registro,
          descripcion,
          sitio_web
        )
      ''').eq('id', keyExists['id_alumno']).maybeSingle();

      if (alumnoWithSchool == null) {
        _setError('Estudiante asociado al código no encontrado');
        return null;
      }

      final keyData = await _supabase.from('llaves').select('''
        id,
        codigo,
        id_alumno,
        fecha_registro,
        fecha_desactivacion,
        limite_vinculacion,
        activo
      ''').eq('codigo', keyCode).single();

      final now = DateTime.now();
      final int? limiteV = keyData['limite_vinculacion'] is num
          ? (keyData['limite_vinculacion'] as num).toInt()
          : null;

      if (limiteV == null || limiteV <= 0) {
        _setError('Este código ya no permite más registros');
        return null;
      }

      DateTime? pDate(dynamic v) {
        if (v == null) return null;
        try {
          return DateTime.parse(v.toString());
        } catch (_) {
          return null;
        }
      }

      String fmtIso(dynamic ts) =>
          pDate(ts)?.toIso8601String() ?? ts?.toString() ?? '';

      final fRegistro = pDate(keyData['fecha_registro']) ?? now;
      final fDesact = pDate(keyData['fecha_desactivacion']);

      if (now.isBefore(fRegistro)) {
        _setError('Este código aún no está activo');
        return null;
      }
      if (fDesact != null && now.isAfter(fDesact)) {
        _setError('Este código ha expirado');
        return null;
      }

      final remainingDays = fDesact?.difference(now).inDays;

      final alumnoData = Map<String, dynamic>.from(alumnoWithSchool);
      final grupoData = alumnoData['grupos'] as Map?;
      final turnoData = alumnoData['turnos'] as Map?;
      final escuelaData = alumnoData['escuelas'] as Map?;

      if (escuelaData == null) {
        _setError('Datos de la escuela no disponibles');
        return null;
      }

      String? fmtHoraLocal(dynamic v) {
        if (v == null) return null;
        final s = v.toString();
        if (RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) return s;
        if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(s)) {
          return s.substring(0, 5);
        }
        try {
          final dt = DateTime.parse(s);
          return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          return null;
        }
      }

      return {
        'isValid': true,
        'keyId': keyData['id'].toString(),
        'limiteVinculacion': limiteV,
        'student': {
          'id': alumnoData['id'].toString(),
          'nombre': alumnoData['nombre'],
          'matricula': alumnoData['matricula'],
          'grupo': (grupoData?['grupo'] ?? 'Sin grupo').toString(),
          'nivelEducativo':
              (grupoData?['nivel_educativo'] ?? 'Sin nivel').toString(),
          'turno': (turnoData?['turno'] ?? 'Sin turno').toString(),
          'horaInicioTurno': fmtHoraLocal(turnoData?['hora_inicio']),
          'horaFinTurno': fmtHoraLocal(turnoData?['hora_fin']),
          'escuelaId': alumnoData['id_escuela'].toString(),
          'fechaRegistroAlumno': fmtIso(alumnoData['fecha_registro']),
        },
        'school': {
          'id': escuelaData['id'].toString(),
          'nombre': escuelaData['nombre'],
          'codigo': escuelaData['codigo'],
          'tipo': escuelaData['tipo'],
          'direccion': escuelaData['direccion'],
          'telefono': escuelaData['telefono'],
          'email': escuelaData['email'],
          'descripcion': escuelaData['descripcion'],
          'sitio_web': escuelaData['sitio_web'],
          'nivelesEducativos': {
            'preescolar': false,
            'primaria': false,
            'secundaria': false,
            'preparatoria': false,
          },
        },
        'key': {
          'id': keyData['id'].toString(),
          'codigo': keyData['codigo'],
          'fechaRegistro': fmtIso(keyData['fecha_registro']),
          'fechaDesactivacion': keyData['fecha_desactivacion'] != null
              ? fmtIso(keyData['fecha_desactivacion'])
              : null,
          'limiteVinculacion': limiteV,
          'remainingDays': remainingDays,
          'activo': keyData['activo'] == true,
        }
      };
    } catch (e) {
      _setError(e.toString());
      try {
        final like = '%${keyCode.substring(0, math.min(keyCode.length, 5))}%';
        await _supabase
            .from('llaves')
            .select('id, codigo')
            .ilike('codigo', like)
            .limit(5);
      } catch (_) {}
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerStudentWithKey({
    required String keyId,
    required String studentId,
    required String tutorId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final keyRow = await _supabase.from('llaves').select('''
        id, codigo, id_alumno, fecha_registro, fecha_desactivacion,
        limite_vinculacion, activo
      ''').eq('id', keyId).maybeSingle();

      if (keyRow == null) {
        _setError('Código de estudiante no encontrado');
        return false;
      }

      if (keyRow['id_alumno']?.toString() != studentId) {
        _setError('El código no corresponde a este estudiante');
        return false;
      }

      final String codigo = keyRow['codigo']?.toString() ?? '';
      final reval = await validateStudentKeyCode(codigo);
      if (reval == null || reval['isValid'] != true) {
        if (_error == null) {
          _setError('No fue posible validar el código');
        }
        return false;
      }

      final existing = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId)
          .maybeSingle();
      if (existing != null) {
        _setError('Ya tienes este estudiante registrado');
        return false;
      }

      final keyBefore = await _supabase
          .from('llaves')
          .select('id, limite_vinculacion')
          .eq('id', keyId)
          .single();

      final currentLimit =
          (keyBefore['limite_vinculacion'] as num?)?.toInt() ?? 0;
      if (currentLimit <= 0) {
        _setError('Este código ya no permite más registros');
        return false;
      }

      final newLimit = currentLimit - 1;

      final updateResult = await _supabase
          .from('llaves')
          .update({
            'limite_vinculacion': newLimit,
          })
          .eq('id', keyId)
          .select('id, limite_vinculacion, activo')
          .maybeSingle();

      if (updateResult == null ||
          (updateResult['limite_vinculacion'] as num).toInt() != newLimit) {
        _setError('No fue posible actualizar el límite de la llave');
        return false;
      }

      await _supabase.from('alumno_tutores').insert({
        'id_alumno': studentId,
        'id_tutor': tutorId,
        'fecha_vinculacion': DateTime.now().toIso8601String(),
      }).select('id');

      await loadStudentsForUser(userId: tutorId, forceReload: true);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getKeyState(String keyId) async {
    try {
      final resp = await _supabase
          .from('llaves')
          .select('id, codigo, limite_vinculacion, activo, id_alumno')
          .eq('id', keyId)
          .maybeSingle();
      return resp;
    } catch (e) {
      debugPrint('getKeyState error: $e');
      return null;
    }
  }

  Future<bool> checkIfUserAlreadyHasStudent({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      final existing = await _supabase
          .from('alumno_tutores')
          .select('id, fecha_vinculacion')
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId)
          .maybeSingle();
      return existing != null;
    } catch (e) {
      debugPrint('checkIfUserAlreadyHasStudent error: $e');
      rethrow;
    }
  }

  void clearAllData() {
    _disposeRealtime();
    _students.clear();
    _filteredStudents.clear();
    _selectedStudent = null;
    _availableGrupos.clear();
    _availableTurnos.clear();
    _isLoading = false;
    _error = null;
    _currentLoadingMode = null;
    _currentSchoolId = null;
    _lastConvertedCount = 0;
    Future.microtask(notifyListeners);
  }

  /// Cambia el contexto de carga y limpia datos previos para evitar contaminación
  void switchToUserContext(String userId) {
    debugPrint('Switching to USER context for userId: $userId');
    if (_currentLoadingMode == 'admin') {
      debugPrint('Clearing admin data before loading user data');
      _students.clear();
      _filteredStudents.clear();
      _selectedStudent = null;
      _currentLoadingMode = null;
      Future.microtask(notifyListeners);
    }
  }

  /// Cambia el contexto de carga y limpia datos previos para evitar contaminación
  void switchToAdminContext(String schoolId) {
    debugPrint('Switching to ADMIN context for schoolId: $schoolId');
    if (_currentLoadingMode == 'user') {
      debugPrint('Clearing user data before loading admin data');
      _students.clear();
      _filteredStudents.clear();
      _selectedStudent = null;
      _currentLoadingMode = null;
      Future.microtask(notifyListeners);
    }
  }

  @override
  void dispose() {
    _disposeRealtime();
    super.dispose();
  }
}
