import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fcm_service.dart';
import '../managers/turno_provider.dart';

enum ScannerAccessType { entry, exit, automatic }

/// Tipos válidos en la columna `tipo` de `notificaciones`
/// (alineado al resto del sistema: 'entrada'|'salida'|'retraso'|...)
enum NotificationType { entrada, salida, retraso }

/// Represents a time window for a specific shift
class ShiftWindow {
  final DateTime start;
  final DateTime end;
  final String shiftName;
  final ScannerAccessType type;

  ShiftWindow({
    required this.start,
    required this.end,
    required this.shiftName,
    required this.type,
  });
}

class ScannerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FCMService _fcmService = FCMService();

  static final Map<String, Completer<Map<String, dynamic>>> _processingLocks =
      {};
  static final Map<String, DateTime> _lockTimestamps = {};

  // ⚡ OPTIMIZACIÓN: Cache para turnos para evitar consultas repetidas
  static final Map<String, Map<String, dynamic>> _turnoCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // ⚡ OPTIMIZACIÓN: Cache para estudiantes para consultas repetidas
  static final Map<String, Map<String, dynamic>> _studentCache = {};
  static final Map<String, DateTime> _studentCacheTimestamps = {};
  static const Duration _studentCacheExpiry = Duration(minutes: 2);
  Future<Map<String, dynamic>> processScannedCode({
    required String scannedCode,
    required String adminId,
    required String escuelaIdFromContext,
    required ScannerAccessType accessType,
    bool isDefaultEntryConfig = true,
    TurnoProvider? turnoProvider,
    bool isExtracurricular = false,
    bool isFixedAccess = false,
  }) async {
    try {
      if (scannedCode.trim().isEmpty) {
        return {
          'success': false,
          'error': 'No se detectó ningún código válido',
          'shouldTerminate': true
        };
      }

      // NUEVO: Crear clave única para el procesamiento
      final processKey =
          '${scannedCode.trim()}_${adminId}_$escuelaIdFromContext';

      // NUEVO: Verificar si ya hay un procesamiento en curso para este código
      if (_processingLocks.containsKey(processKey)) {
        debugPrint('🔒 PROCESSING: Already processing $processKey, waiting...');
        try {
          // Esperar a que termine el procesamiento existente
          final result = await _processingLocks[processKey]!.future;
          debugPrint(
              '🔒 PROCESSING: Got result from existing process: ${result['success']}');
          return result;
        } catch (e) {
          debugPrint('🔒 PROCESSING: Error waiting for existing process: $e');
          _processingLocks.remove(processKey);
          _lockTimestamps.remove(processKey);
        }
      }

      // NUEVO: Limpiar locks antiguos (más de 30 segundos)
      _cleanupOldLocks();

      // NUEVO: Crear nuevo lock para este procesamiento
      final completer = Completer<Map<String, dynamic>>();
      _processingLocks[processKey] = completer;
      _lockTimestamps[processKey] = DateTime.now();

      debugPrint('🔒 PROCESSING: Starting new process for $processKey');

      try {
        final result = await _doProcessScannedCode(
          scannedCode: scannedCode,
          adminId: adminId,
          escuelaIdFromContext: escuelaIdFromContext,
          accessType: accessType,
          isDefaultEntryConfig: isDefaultEntryConfig,
          turnoProvider: turnoProvider,
          isExtracurricular: isExtracurricular,
          isFixedAccess: isFixedAccess,
        );

        // NUEVO: Completar el lock con el resultado
        completer.complete(result);
        debugPrint(
            '🔒 PROCESSING: Completed process for $processKey: ${result['success']}');

        return result;
      } catch (e) {
        // NUEVO: Completar el lock con error
        final errorResult = {
          'success': false,
          'error': 'Error interno al procesar el código: $e',
          'shouldTerminate': true
        };
        completer.complete(errorResult);
        rethrow;
      } finally {
        // NUEVO: Limpiar lock después de un delay
        Future.delayed(const Duration(seconds: 5), () {
          _processingLocks.remove(processKey);
          _lockTimestamps.remove(processKey);
        });
      }
    } catch (e) {
      debugPrint('Error processing scanned code: $e');
      return {
        'success': false,
        'error': 'Error interno al procesar el código: $e',
        'shouldTerminate': true
      };
    }
  }

  void _cleanupOldLocks() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _lockTimestamps.entries) {
      if (now.difference(entry.value).inSeconds > 30) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _processingLocks.remove(key);
      _lockTimestamps.remove(key);
    }
  }

  // NUEVO: Método interno que hace el procesamiento real
  Future<Map<String, dynamic>> _doProcessScannedCode({
    required String scannedCode,
    required String adminId,
    required String escuelaIdFromContext,
    required ScannerAccessType accessType,
    bool isDefaultEntryConfig = true,
    TurnoProvider? turnoProvider,
    bool isExtracurricular = false,
    bool isFixedAccess = false,
  }) async {
    final currentTime = DateTime.now();

    debugPrint(
        'ProcessScannedCode: Step 1 - Finding student for matricula: $scannedCode');

    final studentData = await _findStudentByMatricula(scannedCode.trim());

    if (studentData == null) {
      debugPrint(
          'ProcessScannedCode: Student not found with matricula: $scannedCode');
      return {
        'success': false,
        'error': 'Estudiante no encontrado con matrícula: $scannedCode',
        'shouldTerminate': true
      };
    }

    debugPrint('ProcessScannedCode: Student found → ${studentData['nombre']}');

    final String studentId = studentData['id']?.toString() ?? '';
    final String? turnoValue = studentData['id_turno']?.toString();
    final String? escuelaIdAlumno = studentData['id_escuela']?.toString();

    if (studentId.isEmpty || turnoValue == null || escuelaIdAlumno == null) {
      debugPrint('ProcessScannedCode: Incomplete student data');
      return {
        'success': false,
        'error': 'Datos del estudiante incompletos',
        'shouldTerminate': true
      };
    }

    // Validar escuela
    if (escuelaIdFromContext.trim().isNotEmpty &&
        escuelaIdAlumno.trim() != escuelaIdFromContext.trim()) {
      return {
        'success': false,
        'error': 'El alumno pertenece a otra escuela.',
        'shouldTerminate': true,
      };
    }

    debugPrint('ProcessScannedCode: Step 2 - Getting turno data');
    final turnoData = await _getStudentTurno(turnoValue, escuelaIdAlumno);

    if (turnoData == null) {
      debugPrint('ProcessScannedCode: Turno data not found');
      return {
        'success': false,
        'error': 'No se pudo obtener información del turno del estudiante',
        'shouldTerminate': true
      };
    }

    debugPrint('ProcessScannedCode: Step 3 - Validating access time');
    final timeValidation = _validateAccessTime(
      currentTime: currentTime,
      turno: turnoData,
      accessType: accessType,
      isDefaultEntryConfig: isDefaultEntryConfig,
      turnoProvider: turnoProvider,
      escuelaIdFromContext: escuelaIdFromContext,
      isFixedAccess: isFixedAccess,
    );

    // Determinar el tipo de notificación ANTES del check de duplicados
    final ScannerAccessType acType =
        timeValidation['accessType'] as ScannerAccessType;
    final bool isLate = (timeValidation['isLate'] ?? false) as bool;

    final NotificationType expectedNotifType =
        (acType == ScannerAccessType.exit)
            ? NotificationType.salida
            : (isLate ? NotificationType.retraso : NotificationType.entrada);

    debugPrint(
        'ProcessScannedCode: Step 4 - Checking for recent duplicate of type: ${expectedNotifType.name}');

    // Check duplicados con el tipo correcto
    final recentNotification = await _checkRecentNotification(
        studentId, currentTime,
        expectedType: expectedNotifType);

    if (recentNotification != null) {
      debugPrint(
          'ProcessScannedCode: Recent duplicate (${expectedNotifType.name}) detected');
      return {
        'success': false,
        'error':
            'Este alumno ya fue escaneado hace menos de 1 minuto. Espera antes de volver a escanearlo.',
        'reason': 'recentDuplicate',
        'shouldTerminate': true,
      };
    }

    debugPrint('ProcessScannedCode: Step 5 - Creating notification');
    final notificationResult = await _createNotification(
      studentData: studentData,
      adminId: adminId,
      escuelaIdContext: escuelaIdFromContext,
      accessInfo: timeValidation,
      timestamp: currentTime,
      isExtracurricular: isExtracurricular,
    );

    if (notificationResult['success'] != true) {
      final errorMessage = notificationResult['error']?.toString() ??
          'Error desconocido en la creación de notificación';
      debugPrint(
          'ProcessScannedCode: Returning notification error → $errorMessage');
      return {
        'success': false,
        'error': errorMessage,
        'shouldTerminate': true,
      };
    }

    return {
      'success': true,
      'student': {
        'id': studentId,
        'name': studentData['nombre']?.toString() ?? 'Sin nombre',
        'matricula': studentData['matricula']?.toString() ?? '',
        'grupo': studentData['grupos'] is Map
            ? (studentData['grupos']['grupo']?.toString() ?? 'N/A')
            : 'N/A',
        'nivel': studentData['grupos'] is Map
            ? (studentData['grupos']['nivel_educativo']?.toString() ?? 'N/A')
            : 'N/A',
        'turno': turnoData['turno']?.toString() ?? 'Sin turno',
      },
      'access': {
        'type': timeValidation['accessType'],
        'isLate': timeValidation['isLate'],
        'time': currentTime.toIso8601String(),
        'message': timeValidation['message'],
      },
      'notification': notificationResult['notification'],
    };
  }

  /// === DB QUERIES Y VALIDACIONES OPTIMIZADAS ===
  Future<Map<String, dynamic>?> _findStudentByMatricula(
      String matricula) async {
    try {
      final m = matricula.trim();
      if (m.isEmpty) return null;

      // ⚡ OPTIMIZACIÓN: Check cache first
      final cacheKey = 'student_$m';
      final now = DateTime.now();

      if (_studentCache.containsKey(cacheKey) &&
          _studentCacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _studentCacheTimestamps[cacheKey]!;
        if (now.difference(cacheTime) < _studentCacheExpiry) {
          debugPrint('⚡ Cache HIT: Student $m found in cache');
          return _studentCache[cacheKey];
        } else {
          // Cache expired, remove it
          _studentCache.remove(cacheKey);
          _studentCacheTimestamps.remove(cacheKey);
        }
      }

      debugPrint('⚡ Cache MISS: Querying database for student $m');
      final response = await _supabase.from('alumnos').select('''
          id,
          nombre,
          matricula,
          id_grupo,
          id_escuela,
          id_turno,
          grupos!inner(
            grupo,
            nivel_educativo
          ),
          turnos(turno)
        ''').eq('matricula', m).maybeSingle();

      if (response == null) return null;

      // Validación de campos mínimos para el flujo del escáner
      if (response['id'] == null ||
          response['nombre'] == null ||
          response['matricula'] == null ||
          response['id_escuela'] == null ||
          response['id_turno'] == null) {
        debugPrint('Student data incomplete: ${response.keys.toList()}');
        return null;
      }

      // ⚡ OPTIMIZACIÓN: Store in cache
      _studentCache[cacheKey] = response;
      _studentCacheTimestamps[cacheKey] = now;
      debugPrint('⚡ Cache STORED: Student $m cached');

      return response;
    } catch (e) {
      debugPrint('Error finding student: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getStudentTurno(
      String turnoId, String escuelaId) async {
    try {
      if (turnoId.isEmpty || escuelaId.isEmpty) return null;

      // ⚡ OPTIMIZACIÓN: Check cache first
      final cacheKey = 'turno_${turnoId}_$escuelaId';
      final now = DateTime.now();

      if (_turnoCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (now.difference(cacheTime) < _cacheExpiry) {
          debugPrint('⚡ Cache HIT: Turno $turnoId found in cache');
          return _turnoCache[cacheKey];
        } else {
          // Cache expired, remove it
          _turnoCache.remove(cacheKey);
          _cacheTimestamps.remove(cacheKey);
        }
      }

      debugPrint('⚡ Cache MISS: Querying database for turno $turnoId');
      final response = await _supabase
          .from('turnos')
          .select('*')
          .eq('id', turnoId)
          .eq('id_escuela', escuelaId)
          .maybeSingle();

      if (response == null || response['hora_inicio'] == null) return null;

      // ⚡ OPTIMIZACIÓN: Store in cache
      _turnoCache[cacheKey] = response;
      _cacheTimestamps[cacheKey] = now;
      debugPrint('⚡ Cache STORED: Turno $turnoId cached');

      return response;
    } catch (e) {
      debugPrint('Error getting turno: $e');
      return null;
    }
  }

  Map<String, dynamic> _validateAccessTime({
    required DateTime currentTime,
    required Map<String, dynamic> turno,
    required ScannerAccessType accessType,
    required bool isDefaultEntryConfig,
    TurnoProvider? turnoProvider,
    String? escuelaIdFromContext,
    bool isFixedAccess = false, // Nuevo parámetro
  }) {
    // Debug: Log all input parameters
    debugPrint('=== _validateAccessTime DEBUG ===');
    debugPrint('currentTime: $currentTime');
    debugPrint('turno data: $turno');
    debugPrint('accessType: $accessType');
    debugPrint('isDefaultEntryConfig: $isDefaultEntryConfig');

    // Resuelve el tipo real de acceso (fijo/auto) respetando la configuración
    final actualAccess = _getActualAccessType(
      accessType,
      isDefaultEntryConfig,
      currentTime: currentTime,
      turno: turno,
      turnoProvider: turnoProvider,
      escuelaId: escuelaIdFromContext,
    );

    debugPrint('actualAccess resolved to: $actualAccess');

    final String? turnoInicioStr = turno['hora_inicio']?.toString();
    final int tolerancia = turno['tolerancia'] is int
        ? turno['tolerancia']
        : (int.tryParse('${turno['tolerancia'] ?? '0'}') ?? 15);

    debugPrint('turnoInicioStr: $turnoInicioStr');
    debugPrint('tolerancia: $tolerancia');

    // IMPORTANTE: Solo aplicamos validación de tardanza para ENTRADA AUTOMÁTICA
    // Si es SALIDA o ENTRADA FIJA (incluye extracurricular), nunca se considera tardanza
    bool isLate = false;
    String message;

    debugPrint('🕐 LATENESS CHECK: actualAccess=$actualAccess');
    debugPrint('🕐 LATENESS CHECK: accessType=$accessType');
    debugPrint('🕐 LATENESS CHECK: turnoInicioStr=$turnoInicioStr');

    // Solo validamos tardanza para ENTRADA AUTOMÁTICA
    // Las entradas fijas (normal y extracurricular) NUNCA son tarde
    if (actualAccess == ScannerAccessType.entry &&
        !isFixedAccess && // Solo para automático
        turnoInicioStr != null &&
        turnoInicioStr.isNotEmpty) {
      debugPrint('🕐 AUTOMATIC ENTRY MODE: Checking for lateness...');
      // Solo para ENTRADA AUTOMÁTICA validamos tardanza
      try {
        final parts = turnoInicioStr.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          final turnoDt = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            hour,
            minute,
          );

          final lateThreshold = turnoDt.add(Duration(minutes: tolerancia));

          debugPrint('turnoDt: $turnoDt');
          debugPrint('lateThreshold: $lateThreshold');
          debugPrint(
              'currentTime.isAfter(lateThreshold): ${currentTime.isAfter(lateThreshold)}');

          if (currentTime.isAfter(lateThreshold)) {
            isLate = true;
            message = 'Llegada tardía (tolerancia: $tolerancia min)';
            debugPrint(
                'MARKED AS LATE: currentTime ($currentTime) > lateThreshold ($lateThreshold)');
          } else {
            message = 'Llegada a tiempo';
            debugPrint(
                'ON TIME: currentTime ($currentTime) <= lateThreshold ($lateThreshold)');
          }
        } else {
          message = 'Llegada registrada';
          debugPrint('Invalid time format, no lateness check');
        }
      } catch (e) {
        debugPrint('Error parsing turno time: $e');
        message = 'Llegada registrada';
      }
    } else {
      // Para SALIDA, ENTRADA FIJA, o ENTRADA EXTRACURRICULAR
      if (actualAccess == ScannerAccessType.exit) {
        message = 'Salida registrada';
        debugPrint('🕐 EXIT MODE: No lateness check applied');
      } else {
        // Entrada fija o extracurricular - NUNCA tarde
        message = 'Llegada registrada';
        debugPrint(
            '🕐 FIXED ENTRY MODE: No lateness check applied (always on time)');
      }
    }

    debugPrint('Final result: isLate=$isLate, message="$message"');
    debugPrint('=== END _validateAccessTime DEBUG ===');

    return {
      'accessType': actualAccess,
      'isLate': isLate,
      'currentTime': currentTime,
      'message': message,
    };
  }

  ScannerAccessType _getActualAccessType(
    ScannerAccessType accessType,
    bool isDefaultEntryConfig, {
    DateTime? currentTime,
    Map<String, dynamic>? turno,
    TurnoProvider? turnoProvider,
    String? escuelaId,
  }) {
    debugPrint('=== _getActualAccessType DEBUG ===');
    debugPrint('accessType: $accessType');
    debugPrint('isDefaultEntryConfig: $isDefaultEntryConfig');

    // Si es fijo, se respeta literalmente.
    if (accessType == ScannerAccessType.entry ||
        accessType == ScannerAccessType.exit) {
      debugPrint('Fixed access type, returning: $accessType');
      return accessType;
    }

    // Para automático, SIEMPRE respetamos la configuración de isDefaultEntryConfig
    // que viene desde AttendanceControlHeader
    final automaticType =
        isDefaultEntryConfig ? ScannerAccessType.entry : ScannerAccessType.exit;

    debugPrint('🚨 IMPORTANTE: Automatic mode configuration');
    debugPrint('🚨 isDefaultEntryConfig=$isDefaultEntryConfig');
    debugPrint('🚨 Resolved automaticType=$automaticType');
    debugPrint(
        '🚨 This means: ${automaticType == ScannerAccessType.entry ? "ENTRADA (can have lateness)" : "SALIDA (never late)"}');

    return automaticType;
  }

  Future<Map<String, dynamic>> _createNotification({
    required Map<String, dynamic> studentData,
    required String adminId,
    required String escuelaIdContext,
    required Map<String, dynamic> accessInfo,
    required DateTime timestamp,
    bool isExtracurricular =
        false, // Nuevo parámetro para detectar extracurricular
  }) async {
    try {
      debugPrint('_createNotification: Starting notification creation');
      final String studentName =
          studentData['nombre']?.toString() ?? 'Estudiante';
      final String? studentId = studentData['id']?.toString();
      final String? studentSchoolId = studentData['id_escuela']?.toString();

      debugPrint(
          '_createNotification: Basic data → studentName=$studentName, studentId=$studentId, studentSchoolId=$studentSchoolId');

      if (studentId == null || studentId.isEmpty) {
        debugPrint('_createNotification: Invalid student ID');
        return {'success': false, 'error': 'ID del estudiante no válido'};
      }
      if (studentSchoolId == null || studentSchoolId.isEmpty) {
        debugPrint('_createNotification: Invalid student school ID');
        return {'success': false, 'error': 'Escuela del estudiante no válida'};
      }

      debugPrint(
          '_createNotification: Getting admin info for adminId=$adminId');
      final adminInfo = await _getAdminUserInfo(adminId);
      if (adminInfo == null) {
        debugPrint('_createNotification: Admin not found');
        return {
          'success': false,
          'error': 'Usuario administrador no encontrado'
        };
      }
      final String tipoUsuario =
          (adminInfo['tipo']?.toString() ?? '').toLowerCase();
      final String? adminSchoolId = adminInfo['id_escuela']?.toString();
      debugPrint(
          '_createNotification: Admin info → tipoUsuario=$tipoUsuario, adminSchoolId=$adminSchoolId');

      if (tipoUsuario == 'administrador') {
        if (adminSchoolId == null || adminSchoolId.isEmpty) {
          return {
            'success': false,
            'error': 'El administrador no tiene escuela asignada'
          };
        }
        if (adminSchoolId != studentSchoolId) {
          return {
            'success': false,
            'error':
                'La escuela del alumno no coincide con la del administrador'
          };
        }
        if (escuelaIdContext.trim().isNotEmpty &&
            adminSchoolId != escuelaIdContext.trim()) {
          return {
            'success': false,
            'error':
                'La escuela de la sesión no coincide con la del administrador'
          };
        }
      } else {
        if (escuelaIdContext.trim().isNotEmpty &&
            escuelaIdContext.trim() != studentSchoolId) {
          return {
            'success': false,
            'error': 'El alumno pertenece a otra escuela (contexto)'
          };
        }
      }

      debugPrint('_createNotification: Validating student key and tutor');
      final validationResult = await _validateStudentKeyAndTutor(studentId);
      if (validationResult['isValid'] != true) {
        debugPrint(
            '_createNotification: Student key/tutor validation failed → ${validationResult['error']}');
        return {'success': false, 'error': validationResult['error']};
      }
      debugPrint('_createNotification: Student key/tutor validation passed');

      final String? groupId = studentData['id_grupo']?.toString();
      if (groupId != null && groupId.isNotEmpty) {
        final gval = await _validateStudentGroupConsistency(
            studentId, studentSchoolId, groupId);
        if (gval['isValid'] != true) {
          return {'success': false, 'error': gval['error']};
        }
      }

      final String? turnoId = studentData['id_turno']?.toString();
      if (turnoId != null && turnoId.isNotEmpty) {
        final tval =
            await _validateTurnoSchoolConsistency(turnoId, studentSchoolId);
        if (tval['isValid'] != true) {
          return {'success': false, 'error': tval['error']};
        }
      }

      final ScannerAccessType acType =
          accessInfo['accessType'] as ScannerAccessType;
      final bool isLate = (accessInfo['isLate'] ?? false) as bool;
      final String motivoSufijo =
          isExtracurricular ? ' (motivo: extracurricular)' : '';

      final NotificationType notifType = (acType == ScannerAccessType.exit)
          ? NotificationType.salida
          : (isLate ? NotificationType.retraso : NotificationType.entrada);

      final String hora = _formatTime12h(timestamp);
      final String titulo =
          _buildTitle(studentName, acType, isLate, isExtracurricular);
      final String mensaje =
          _buildMessage(studentName, acType, isLate, hora, motivoSufijo);

      // NUEVO: Check de duplicados más estricto con ventana más amplia
      final duplicateWindow =
          timestamp.subtract(const Duration(seconds: 90)); // 90 segundos

      final existingNotifications = await _supabase
          .from('notificaciones')
          .select('id, fecha_registro, tipo_notificacion')
          .eq('id_alumno', studentId)
          .eq('tipo_notificacion', notifType.name)
          .gte('fecha_registro', duplicateWindow.toUtc().toIso8601String())
          .order('fecha_registro', ascending: false);

      if (existingNotifications.isNotEmpty) {
        final latest = existingNotifications.first;
        final existingTime = DateTime.parse(latest['fecha_registro']);
        final timeDiff = timestamp.difference(existingTime).inSeconds;

        if (timeDiff < 60) {
          debugPrint(
              '_createNotification: Found duplicate within ${timeDiff}s');
          return {
            'success': false,
            'error': 'Este alumno ya fue escaneado hace menos de 1 minuto.',
            'duplicateIgnored': true,
            'notification': {
              'id': latest['id'],
              'tipo': latest['tipo_notificacion'],
              'fecha': latest['fecha_registro'],
            },
          };
        }
      }

      debugPrint(
          'NOTIF BUILD → accessType=${acType.name} isLate=$isLate title="$titulo" body="$mensaje"');

      // Insertar notificación
      final inserted = await _supabase
          .from('notificaciones')
          .insert({
            'id_alumno': studentId,
            'id_admin': adminId,
            'titulo': titulo,
            'mensaje': mensaje,
            'tipo_notificacion': notifType.name,
            'estado': 'nueva',
            'fecha_registro': timestamp.toUtc().toIso8601String(),
          })
          .select('id')
          .single();

      final String notificationId = inserted['id']?.toString() ?? '';

      // FCM en background
      _sendFCMInBackground(
        studentId: studentId,
        titulo: titulo,
        mensaje: mensaje,
        notificationId: notificationId,
        notifType: notifType,
        adminSchoolId: adminSchoolId,
        studentSchoolId: studentSchoolId,
        acType: acType,
        isLate: isLate,
        timestamp: timestamp,
      );

      return {
        'success': true,
        'notification': {
          'id': notificationId,
          'titulo': titulo,
          'mensaje': mensaje,
          'tipo': notifType.name,
          'fecha': timestamp.toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return {'success': false, 'error': 'Error al crear la notificación: $e'};
    }
  }

// NUEVO: Helper methods para construir título y mensaje
  String _buildTitle(String studentName, ScannerAccessType acType, bool isLate,
      bool isExtracurricular) {
    if (acType == ScannerAccessType.exit) {
      return isExtracurricular
          ? '$studentName ha salido (extracurricular)'
          : '$studentName ha salido';
    } else {
      if (isLate) {
        return isExtracurricular
            ? '$studentName llegó tarde (extracurricular)'
            : '$studentName llegó tarde';
      } else {
        return isExtracurricular
            ? '$studentName ha llegado (extracurricular)'
            : '$studentName ha llegado';
      }
    }
  }

  String _buildMessage(String studentName, ScannerAccessType acType,
      bool isLate, String hora, String motivoSufijo) {
    if (acType == ScannerAccessType.exit) {
      return '$studentName salió de la escuela a las $hora$motivoSufijo';
    } else {
      if (isLate) {
        return '$studentName llegó tarde a la escuela a las $hora$motivoSufijo';
      } else {
        return '$studentName llegó a la escuela a las $hora$motivoSufijo';
      }
    }
  }

  /// ⚡ OPTIMIZACIÓN: Envío de FCM en background sin bloquear la UI
  void _sendFCMInBackground({
    required String studentId,
    required String titulo,
    required String mensaje,
    required String notificationId,
    required NotificationType notifType,
    required String? adminSchoolId,
    required String studentSchoolId,
    required ScannerAccessType acType,
    required bool isLate,
    required DateTime timestamp,
  }) {
    // Ejecutar en background sin bloquear la UI
    Future.microtask(() async {
      try {
        debugPrint('⚡ FCM: Starting background notification send');
        await _fcmService.sendNotificationToStudentTutors(
          studentId: studentId,
          title: titulo,
          body: mensaje,
          notificationId: notificationId,
          additionalData: {
            'tipo': notifType.name,
            'id_escuela': adminSchoolId ?? studentSchoolId,
            'access_type': acType.name,
            'is_late': isLate.toString(),
            'timestamp': timestamp.toIso8601String(),
          },
        );
        debugPrint('⚡ FCM: Background notification sent successfully');
      } catch (e) {
        debugPrint('⚡ FCM: Background notification error: $e');
      }
    });
  }

  String _formatTime12h(DateTime dateTime) {
    final local = dateTime.toLocal();
    int h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final suffix = (h >= 12) ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:$m $suffix';
  }

  /// === Metadatos UI para indicadores ===

  String getAccessTypeDisplayName(
      ScannerAccessType accessType, bool isDefaultEntryConfig) {
    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntryConfig
            ? 'Modo Automático - Entrada'
            : 'Modo Automático - Salida';
      case ScannerAccessType.entry:
        return 'Entrada Fija';
      case ScannerAccessType.exit:
        return 'Salida Fija';
    }
  }

  Color getAccessTypeColor(
      ScannerAccessType accessType, bool isDefaultEntryConfig) {
    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntryConfig ? Colors.green : Colors.red;
      case ScannerAccessType.entry:
        return Colors.green;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  IconData getAccessTypeIcon(
      ScannerAccessType accessType, bool isDefaultEntryConfig) {
    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntryConfig
            ? Icons.login_rounded
            : Icons.logout_rounded;
      case ScannerAccessType.entry:
        return Icons.login_rounded;
      case ScannerAccessType.exit:
        return Icons.logout_rounded;
    }
  }

  /// === Helpers de validación ===

  /// Obtiene info del usuario y resuelve id_escuela de forma compatible con el esquema:
  /// - Si es ADMIN: admin_access_list por email (activo=true, más reciente)
  /// - Si NO es admin: primer alumno vinculado (alumno_tutores → alumnos.id_escuela)
  Future<Map<String, dynamic>?> _getAdminUserInfo(String adminId) async {
    try {
      // 1) Leer usuario base (¡OJO! usuarios NO tiene id_escuela)
      final userRow = await _supabase
          .from('usuarios')
          .select('id, email, tipo, tipo_administrador')
          .eq('id', adminId)
          .maybeSingle();

      if (userRow == null) {
        debugPrint('Admin user not found with ID: $adminId');
        return null;
      }

      final String email =
          (userRow['email']?.toString() ?? '').trim().toLowerCase();
      final String tipo =
          (userRow['tipo']?.toString() ?? '').trim().toLowerCase();

      String? escuelaId;

      if (tipo == 'administrador' || tipo == 'admin') {
        // 2) Resolver escuela por admin_access_list
        final adminAccess = await _supabase
            .from('admin_access_list')
            .select('id_escuela')
            .eq('email', email)
            .eq('activo', true)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        escuelaId = adminAccess?['id_escuela']?.toString();
      } else {
        // 3) Si no es admin: deducir por vínculo tutor→alumno
        try {
          final resp = await _supabase.from('alumno_tutores').select('''
            alumnos!inner(
              id_escuela
            )
          ''').eq('id_tutor', adminId).limit(1);

          if (resp.isNotEmpty) {
            final alumno = resp[0]['alumnos'] as Map<String, dynamic>?;
            escuelaId = alumno?['id_escuela']?.toString();
          }
        } catch (_) {}
      }

      return {
        'id': userRow['id'],
        'email': email,
        'tipo': userRow['tipo'],
        'tipo_administrador': userRow['tipo_administrador'],
        // devolvemos id_escuela normalizado (puede ser null si no se resuelve)
        'id_escuela': escuelaId,
      };
    } catch (e) {
      debugPrint('Error getting admin user info: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _validateStudentKeyAndTutor(
      String studentId) async {
    try {
      // Tutor registrado
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .maybeSingle();
      if (tutorResponse == null) {
        return {
          'isValid': false,
          'error': 'El alumno aún no ha sido registrado por un familiar',
        };
      }

      // Llave activa vigente
      final now = DateTime.now();
      final keyResponse = await _supabase
          .from('llaves')
          .select('id, fecha_registro, fecha_desactivacion, activo')
          .eq('id_alumno', studentId)
          .eq('activo', true)
          .maybeSingle();

      if (keyResponse == null) {
        return {
          'isValid': false,
          'error': 'El alumno no tiene una llave activa asignada'
        };
      }

      try {
        final from = DateTime.parse(keyResponse['fecha_registro']);
        final to = DateTime.parse(keyResponse['fecha_desactivacion']);
        if (now.isBefore(from) || now.isAfter(to)) {
          return {
            'isValid': false,
            'error': 'La llave del alumno está vencida'
          };
        }
      } catch (e) {
        return {
          'isValid': false,
          'error': 'Error al validar fechas de la llave del alumno'
        };
      }

      return {'isValid': true};
    } catch (e) {
      debugPrint('Error validating student key and tutor: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar registro del alumno: $e'
      };
    }
  }

  Future<Map<String, dynamic>?> _checkRecentNotification(
    String studentId,
    DateTime currentTime, {
    required NotificationType expectedType,
  }) async {
    final window = currentTime.subtract(const Duration(seconds: 60));
    try {
      final r = await _supabase
          .from('notificaciones')
          .select('id, fecha_registro, tipo_notificacion')
          .eq('id_alumno', studentId)
          .eq('tipo_notificacion', expectedType.name) // <--- filtra por tipo
          .gte('fecha_registro', window.toUtc().toIso8601String())
          .order('fecha_registro', ascending: false)
          .limit(1)
          .maybeSingle();

      if (r != null) {
        final tStr = r['fecha_registro']?.toString();
        if (tStr != null && tStr.isNotEmpty) {
          DateTime t = DateTime.parse(tStr);
          if (!tStr.endsWith('Z') && !tStr.contains('+')) t = t.toUtc();
          final diff = currentTime.difference(t).inSeconds;
          if (diff < 60) {
            return {
              'id': r['id'],
              'fecha_registro': r['fecha_registro'],
              'tipo_notificacion': r['tipo_notificacion'],
              'seconds': diff,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('recent by fecha_registro failed: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> _validateStudentGroupConsistency(
      String studentId, String studentSchoolId, String groupId) async {
    try {
      final response = await _supabase
          .from('grupos')
          .select('id_escuela')
          .eq('id', groupId)
          .maybeSingle();
      if (response == null) {
        return {
          'isValid': false,
          'error': 'El grupo del estudiante no existe en el sistema'
        };
      }
      if ((response['id_escuela']?.toString() ?? '') != studentSchoolId) {
        return {
          'isValid': false,
          'error': 'El grupo del estudiante no pertenece a la escuela correcta',
        };
      }
      return {'isValid': true};
    } catch (e) {
      debugPrint('Error validating student group consistency: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar grupo del estudiante: $e'
      };
    }
  }

  Future<Map<String, dynamic>> _validateTurnoSchoolConsistency(
      String turnoId, String studentSchoolId) async {
    try {
      final response = await _supabase
          .from('turnos')
          .select('id_escuela')
          .eq('id', turnoId)
          .maybeSingle();
      if (response == null) {
        return {
          'isValid': false,
          'error': 'El turno del estudiante no existe en el sistema'
        };
      }
      if ((response['id_escuela']?.toString() ?? '') != studentSchoolId) {
        return {
          'isValid': false,
          'error': 'El turno del estudiante no pertenece a la escuela correcta',
        };
      }
      return {'isValid': true};
    } catch (e) {
      debugPrint('Error validating turno school consistency: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar turno del estudiante: $e'
      };
    }
  }
}
