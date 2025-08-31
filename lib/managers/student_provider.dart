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

  bool _isLoading = false;
  String? _error;

  /// 'admin' o 'user' para no sobreescribir listas accidentalmente
  String? _currentLoadingMode;

  int _lastConvertedCount = 0;

  // Getters
  List<StudentDetails> get students => _students;
  List<StudentDetails> get filteredStudents => _filteredStudents;
  StudentDetails? get selectedStudent => _selectedStudent;
  List<Grupo> get availableGrupos => _availableGrupos;
  List<turno_model.Turno> get availableTurnos => _availableTurnos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ------------------------------
  // Helpers privados
  // ------------------------------

  /// Encuentra la llave activa de forma segura.
  Map<String, dynamic>? _findActiveLlave(List? llavesRaw) {
    if (llavesRaw == null) return null;
    for (final item in llavesRaw) {
      if (item is Map && (item['activo'] == true)) {
        return Map<String, dynamic>.from(item as Map);
      }
    }
    return null;
  }

  /// Formatea hora (time o timestamp/timestamptz) a `HH:mm`.
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

  // ------------------------------
  // API pública
  // ------------------------------

  void clearError() => _setError(null);

  Future<String?> getUserSchoolId(String userId) async {
    debugPrint('getUserSchoolId: userId=$userId');
    try {
      final resp = await _supabase.from('alumno_tutores').select('''
        alumnos!inner(
          id_escuela
        )
      ''').eq('id_tutor', userId).limit(1);

      if (resp.isNotEmpty) {
        final alumno = resp[0]['alumnos'] as Json;
        return alumno['id_escuela']?.toString();
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

    if (_currentLoadingMode == 'admin' && !forceReload) {
      debugPrint('loadStudentsForUser: skipping (admin list loaded)');
      return;
    }

    try {
      _setLoading(true, mode: 'user');
      _setError(null);

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

      final list = <StudentDetails>[];

      for (final item in response) {
        final alumno = Map<String, dynamic>.from(item['alumnos'] as Map);
        final usuario = Map<String, dynamic>.from(item['usuarios'] as Map);
        final fechaVinc = item['fecha_vinculacion']?.toString() ??
            DateTime.now().toIso8601String();

        // Inyectamos estructura para el mapper "con contactos"
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

      _students = list;
      _filteredStudents = List.from(_students);
      _setError(null);
    } catch (e) {
      _setError('Error al cargar estudiantes del usuario: $e');
      debugPrint('loadStudentsForUser error: $e');
    } finally {
      _setLoading(false);
    }
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

      _selectedStudent =
          _mapToStudentDetailsWithContacts(Map<String, dynamic>.from(response));
    } catch (e) {
      _setError('Error al cargar estudiante: $e');
      debugPrint('loadStudentById error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudents({
    String? escuelaId,
    String? userId,
    String? grupoId,
    String? turnoId,
  }) async {
    debugPrint('loadStudents: escuelaId=$escuelaId userId=$userId');
    try {
      _setLoading(true, mode: 'admin');
      _setError(null);

      String? schoolId = escuelaId;
      if (userId != null && schoolId == null) {
        schoolId = await getUserSchoolId(userId);
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
      ''').eq('id_escuela', schoolId);

      if (grupoId != null) query = query.eq('id_grupo', grupoId);
      if (turnoId != null) query = query.eq('id_turno', turnoId);

      final response = await query.order('nombre');
      _students = [];

      for (final item in response) {
        final sd = await _mapToStudentDetailsWithSeparateContacts(
          Map<String, dynamic>.from(item as Map),
        );
        _students.add(sd);
      }

      _filteredStudents = List.from(_students);
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
      Map<String, dynamic> data) async {
    final grupo = data['grupos'] as Map?;
    final turno = data['turnos'] as Map?;
    final llaves = data['llaves'] as List?;
    final tutoresBasic = data['alumno_tutores'] as List?;

    final activeLlave = _findActiveLlave(llaves);

    final tutorsList = <TutorInfo>[];
    final familyContacts = <Json>[];

    if (tutoresBasic != null && tutoresBasic.isNotEmpty) {
      for (final tb in tutoresBasic) {
        final tutorId = tb['id_tutor']?.toString();
        final fechaVinc = _parseDate(tb['fecha_vinculacion']) ??
            DateTime.now(); // fallback defensivo
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

            final contactsResp = await _supabase
                .from('contactos_familiares')
                .select(
                    'id, id_usuario, nombre, parentesco, telefono, email, fecha_registro')
                .eq('id_usuario', tutorId);

            familyContacts.addAll(List<Json>.from(
                contactsResp.map((e) => Map<String, dynamic>.from(e))));
          }
        } catch (e) {
          debugPrint(
              '_mapToStudentDetailsWithSeparateContacts tutor error: $e');
        }
      }
    }

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
      llaveId: activeLlave?['id']?.toString(),
      llaveCodigo: activeLlave?['codigo']?.toString(),
      llaveActiva: (activeLlave?['activo'] == true),
      fechaRegistro: _parseDate(data['fecha_registro']) ?? DateTime.now(),
      fechaRegistroLlave: _parseDate(
          activeLlave != null ? activeLlave['fecha_registro'] : null),
      fechaDesactivacionLlave: _parseDate(
          activeLlave != null ? activeLlave['fecha_desactivacion'] : null),
      limiteVinculacion: activeLlave?['limite_vinculacion'] is num
          ? (activeLlave?['limite_vinculacion'] as num).toInt()
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

    final activeLlave = _findActiveLlave(llaves);

    final tutorsList = <TutorInfo>[];
    final familyContacts = <Json>[];

    if (tutores != null) {
      for (final t in tutores) {
        final usuario = t['usuarios'];
        if (usuario != null) {
          tutorsList.add(TutorInfo(
            id: usuario['id'].toString(),
            nombre: (usuario['nombre'] ?? '').toString(),
            apellido: (usuario['apellido'] ?? '').toString(),
            email: (usuario['email'] ?? '').toString(),
            telefono: null,
            fechaVinculacion:
                _parseDate(t['fecha_vinculacion']) ?? DateTime.now(),
          ));

          final contacts = usuario['contactos_familiares'] as List?;
          if (contacts != null) {
            familyContacts.addAll(List<Json>.from(
                contacts.map((e) => Map<String, dynamic>.from(e))));
          }
        }
      }
    }

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
      llaveId: activeLlave?['id']?.toString(),
      llaveCodigo: activeLlave?['codigo']?.toString(),
      llaveActiva: (activeLlave?['activo'] == true),
      fechaRegistro: _parseDate(data['fecha_registro']) ?? DateTime.now(),
      fechaRegistroLlave: _parseDate(
          activeLlave != null ? activeLlave['fecha_registro'] : null),
      fechaDesactivacionLlave: _parseDate(
          activeLlave != null ? activeLlave['fecha_desactivacion'] : null),
      limiteVinculacion: activeLlave?['limite_vinculacion'] is num
          ? (activeLlave?['limite_vinculacion'] as num).toInt()
          : null,
      tutores: tutorsList,
      familyContacts: familyContacts,
    );
  }

  // ------------------------------
  // Filtros y catálogos
  // ------------------------------

  Future<void> _loadFilteringData(String escuelaId) async {
    try {
      final gruposResponse = await _supabase
          .from('grupos')
          .select()
          .eq('id_escuela', escuelaId)
          .order('nivel_educativo')
          .order('grupo');

      _availableGrupos =
          (gruposResponse as List).map((item) => Grupo.fromJson(item)).toList();

      final turnosResponse = await _supabase
          .from('turnos')
          .select()
          .eq('id_escuela', escuelaId)
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
    String? grupo, // nombre de grupo
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

      bool matchesGrupo = true;
      if (grupo != null && grupo != 'all') {
        matchesGrupo = s.grupo == grupo;
      }

      bool matchesNivel = true;
      if (nivelEducativo != null && nivelEducativo != 'all') {
        matchesNivel = s.nivelEducativo == nivelEducativo;
      }

      bool matchesStatus = true;
      if (status != null && status != 'all') {
        final isActive = s.llaveActiva;
        matchesStatus = (status == 'active' && isActive) ||
            (status == 'inactive' && !isActive);
      }

      bool matchesTurno = true;
      if (turno != null && turno != 'all') {
        matchesTurno = (s.turno ?? '') == turno;
      }

      return matchesSearch &&
          matchesGrupo &&
          matchesNivel &&
          matchesStatus &&
          matchesTurno;
    }).toList();

    notifyListeners();
  }

  List<String> getAvailableGrupoNames() {
    return _availableGrupos.map((g) => g.grupo).toList();
  }

  List<String> getAvailableNivelesEducativos() {
    final list = _availableGrupos.map((g) => g.nivelEducativo).toSet().toList();
    list.sort();
    return list;
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
      });

      await loadStudentById(studentId: studentId);
      return true;
    } catch (e) {
      _setError('Error al vincular tutor: $e');
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

  /// Conversión al modelo ligero `Alumno` (con tu nuevo esquema).
  List<Alumno> getAlumnosFromStudents() {
    final studentsToConvert = List<StudentDetails>.from(_filteredStudents);
    if (studentsToConvert.length != _lastConvertedCount) {
      _lastConvertedCount = studentsToConvert.length;
    }

    try {
      return studentsToConvert.map((s) {
        // Para UI: puedes seguir mostrando "Nivel - Grupo"
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

  /// Matchea string de turno a tu `TurnoEnum` (con `desconocido`).
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
    _students.clear();
    _filteredStudents.clear();
    _selectedStudent = null;
    _currentLoadingMode = null;
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

      // Paso 1: existencia de la llave
      final keyExists = await _supabase
          .from('llaves')
          .select('id, codigo, id_alumno, id_escuela, activo')
          .eq('codigo', keyCode)
          .maybeSingle();

      if (keyExists == null) {
        throw Exception('Código de estudiante no encontrado');
      }

      // Paso 2: alumno existe
      final alumnoExists = await _supabase
          .from('alumnos')
          .select('id, nombre')
          .eq('id', keyExists['id_alumno'])
          .maybeSingle();
      if (alumnoExists == null) {
        throw Exception('Estudiante asociado al código no encontrado');
      }

      // Paso 3: escuela existe
      final escuelaExists = await _supabase
          .from('escuelas')
          .select('id, nombre')
          .eq('id', keyExists['id_escuela'])
          .maybeSingle();
      if (escuelaExists == null) {
        throw Exception('Escuela asociada al código no encontrada');
      }

      // Paso 4: datos completos
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

      final keyData = keyResponse as Json;
      final alumnoData = keyData['alumnos'] as Json?;
      final escuelaData = keyData['escuelas'] as Json?;

      if (alumnoData == null) {
        throw Exception('Datos del estudiante no disponibles');
      }
      if (escuelaData == null) {
        throw Exception('Datos de la escuela no disponibles');
      }

      final grupoData = alumnoData['grupos'] as Json?;
      final turnoData = alumnoData['turnos'] as Json?;

      // Validaciones de ventana/limite
      final int? limiteV = keyData['limite_vinculacion'] is num
          ? (keyData['limite_vinculacion'] as num).toInt()
          : null;
      if (limiteV == null || limiteV <= 0) {
        throw Exception('Este código ya no permite más registros');
      }

      final now = DateTime.now();
      final fRegistro = _parseDate(keyData['fecha_registro']) ?? now;
      final fDesact = _parseDate(keyData['fecha_desactivacion']);

      if (now.isBefore(fRegistro)) {
        throw Exception('Este código aún no está activo');
      }
      if (fDesact != null && now.isAfter(fDesact)) {
        throw Exception('Este código ha expirado');
      }

      final remainingDays = fDesact?.difference(now).inDays;

      String _fmtIso(dynamic ts) =>
          _parseDate(ts)?.toIso8601String() ?? ts?.toString() ?? '';

      final result = {
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
          'horaInicioTurno': _fmtHora(turnoData?['hora_inicio']),
          'horaFinTurno': _fmtHora(turnoData?['hora_fin']),
          'escuelaId': alumnoData['id_escuela'].toString(),
          'fechaRegistroAlumno': _fmtIso(alumnoData['fecha_registro']),
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
          'nivelesEducativos': {
            'preescolar': escuelaData['preescolar'] ?? false,
            'primaria': escuelaData['primaria'] ?? false,
            'secundaria': escuelaData['secundaria'] ?? false,
            'preparatoria': escuelaData['preparatoria'] ?? false,
          }
        },
        'key': {
          'id': keyData['id'].toString(),
          'codigo': keyData['codigo'],
          'fechaRegistro': _fmtIso(keyData['fecha_registro']),
          'fechaDesactivacion': keyData['fecha_desactivacion'] != null
              ? _fmtIso(keyData['fecha_desactivacion'])
              : null,
          'limiteVinculacion': limiteV,
          'remainingDays': remainingDays,
          'activo': keyData['activo'] == true,
        }
      };

      return result;
    } catch (e) {
      _setError(e.toString());

      // Debug auxiliar no-crítico
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

      final existing = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .eq('id_tutor', tutorId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Ya tienes este estudiante registrado');
      }

      final keyBefore = await _supabase
          .from('llaves')
          .select('id, codigo, limite_vinculacion, activo, id_alumno')
          .eq('id', keyId)
          .single();

      final currentLimit = (keyBefore['limite_vinculacion'] as num).toInt();
      if (currentLimit <= 0) {
        throw Exception('Este código ya no permite más registros');
      }

      final newLimit = currentLimit - 1;

      final updateResult = await _supabase
          .from('llaves')
          .update({'limite_vinculacion': newLimit, 'activo': true})
          .eq('id', keyId)
          .select('id, limite_vinculacion, activo');

      if (updateResult.isEmpty) {
        throw Exception('Error al actualizar la llave - no encontrada');
      }

      final updated = updateResult.first;
      if ((updated['limite_vinculacion'] as num).toInt() != newLimit) {
        throw Exception('Error al actualizar el límite de vinculación');
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
      // Debug estado llave (no crítico)
      try {
        await _supabase
            .from('llaves')
            .select('id, codigo, limite_vinculacion, activo')
            .eq('id', keyId)
            .maybeSingle();
      } catch (_) {}
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
      // Preferimos permitir continuar en caso de falla de red puntual
      return false;
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
    Future.microtask(notifyListeners);
  }
}
