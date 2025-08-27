import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fcm_service.dart';

enum ScannerAccessType { entry, exit, automatic }

enum NotificationType { entrada, salida, retraso }

class ScannerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FCMService _fcmService = FCMService();

  /// Process a scanned QR code with complete validation and notification creation
  ///
  /// Comprehensive validation includes:
  /// 1. Basic input validation (non-empty code)
  /// 2. Student existence validation by matricula
  /// 3. Student data completeness (turno, escuela, grupo, etc.)
  /// 4. Admin user existence and school assignment validation
  /// 5. School association validation (student belongs to admin's school)
  /// 6. Student-tutor relationship validation (student registered by family)
  /// 7. Student key validation (active and not expired)
  /// 8. Data consistency validation (group and turno belong to same school)
  /// 9. Student status validation (if 'activo' field exists)
  /// 10. Duplicate scan prevention (no recent notifications within 2 minutes)
  /// 11. Time-based access validation and tardiness detection
  ///
  /// Returns a map with success status and student data or error message
  Future<Map<String, dynamic>> processScannedCode({
    required String scannedCode,
    required String adminId,
    required ScannerAccessType accessType,
    bool isDefaultEntryConfig = true,
  }) async {
    try {
      // Step 1: Validate that a value was captured
      if (scannedCode.trim().isEmpty) {
        return {
          'success': false,
          'error': 'No se detectó ningún código válido',
          'shouldTerminate': true,
        };
      }

      // Step 2: Find student by matricula
      final studentData = await _findStudentByMatricula(scannedCode.trim());
      if (studentData == null) {
        return {
          'success': false,
          'error': 'Estudiante no encontrado con matrícula: $scannedCode',
          'shouldTerminate': true,
        };
      }

      // Step 3: Get student's turno information for time validation
      final String? turnoValue = studentData['id_turno']?.toString();
      final String? escuelaId = studentData['id_escuela']?.toString();

      if (turnoValue == null || escuelaId == null) {
        return {
          'success': false,
          'error':
              'Datos del estudiante incompletos (turno o escuela faltante)',
          'shouldTerminate': true,
        };
      }

      final turnoData = await _getStudentTurno(turnoValue, escuelaId);
      if (turnoData == null) {
        return {
          'success': false,
          'error': 'No se pudo obtener información del turno del estudiante',
          'shouldTerminate': true,
        };
      }

      // Step 4: Determine access type and validate timing
      final currentTime = DateTime.now();
      final timeValidation = _validateAccessTime(
        currentTime: currentTime,
        turno: turnoData,
        accessType: accessType,
        isDefaultEntryConfig: isDefaultEntryConfig,
      );

      // Step 5: Create notification with appropriate type and content
      final notificationResult = await _createNotification(
        studentData: studentData,
        adminId: adminId,
        accessInfo: timeValidation,
        timestamp: currentTime,
      );

      if (!notificationResult['success']) {
        return notificationResult;
      }

      // Step 6: Return success with complete student and access information
      return {
        'success': true,
        'student': {
          'id': studentData['id']?.toString() ?? '',
          'name': studentData['nombre']?.toString() ?? 'Sin nombre',
          'matricula': studentData['matricula']?.toString() ?? '',
          'grupo': studentData['grupos'] != null && studentData['grupos'] is Map
              ? (studentData['grupos']['grupo']?.toString() ?? 'N/A')
              : 'N/A',
          'nivel': studentData['grupos'] != null && studentData['grupos'] is Map
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
    } catch (e) {
      debugPrint('Error processing scanned code: $e');
      return {
        'success': false,
        'error': 'Error interno al procesar el código: $e',
        'shouldTerminate': true,
      };
    }
  }

  /// Find student by matricula with related data
  Future<Map<String, dynamic>?> _findStudentByMatricula(
      String matricula) async {
    try {
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
        )
      ''').eq('matricula', matricula).maybeSingle();

      print('Response from findStudentByMatricula: $response');

      if (response == null) {
        return null;
      }

      // Validate essential student fields
      if (response['id'] == null ||
          response['nombre'] == null ||
          response['matricula'] == null ||
          response['id_escuela'] == null ||
          response['id_turno'] == null) {
        debugPrint('Student data incomplete: missing required fields');
        debugPrint('Available fields: ${response.keys.toList()}');
        return null;
      }

      return response;
    } catch (e) {
      debugPrint('Error finding student: $e');
      return null;
    }
  }

  /// Get turno information for time validation using turno ID
  Future<Map<String, dynamic>?> _getStudentTurno(
      String turnoId, String escuelaId) async {
    try {
      if (turnoId.isEmpty || escuelaId.isEmpty) {
        debugPrint('Invalid turno ID or escuela parameters');
        return null;
      }

      final response = await _supabase
          .from('turnos')
          .select('*')
          .eq('id', turnoId) // Use turno ID instead of enum
          .eq('id_escuela', escuelaId)
          .maybeSingle();

      if (response == null) {
        debugPrint('No turno found for ID: $turnoId in school: $escuelaId');
        return null;
      }

      // Validate essential turno fields
      if (response['hora_inicio'] == null) {
        debugPrint('Turno data incomplete: missing hora_inicio');
        return null;
      }

      return response;
    } catch (e) {
      debugPrint('Error getting turno: $e');
      return null;
    }
  }

  /// Validate access time and determine notification type
  Map<String, dynamic> _validateAccessTime({
    required DateTime currentTime,
    required Map<String, dynamic> turno,
    required ScannerAccessType accessType,
    required bool isDefaultEntryConfig,
  }) {
    final String? turnoInicioStr = turno['hora_inicio']?.toString();
    final int tolerancia = turno['tolerancia'] is int
        ? turno['tolerancia']
        : (int.tryParse(turno['tolerancia']?.toString() ?? '0') ?? 0);

    if (turnoInicioStr == null || turnoInicioStr.isEmpty) {
      // If we can't get turno time, default to not late
      return {
        'accessType': _getActualAccessType(accessType, isDefaultEntryConfig),
        'isLate': false,
        'turnoDateTime': currentTime,
        'lateThreshold': currentTime,
        'currentTime': currentTime,
        'message': 'Horario de turno no disponible',
      };
    }

    // Parse turno time - handle different formats
    try {
      DateTime turnoDateTime;

      // Check if it's a full datetime string (PostgreSQL time format)
      if (turnoInicioStr.contains(':') && turnoInicioStr.length > 5) {
        // Handle formats like "06:30:00+00", "06:30:00", etc.
        String timeOnly =
            turnoInicioStr.split('+')[0]; // Remove timezone if present
        timeOnly = timeOnly.split('T')[0]; // Remove date part if present

        final timeParts = timeOnly.split(':');
        if (timeParts.length >= 2) {
          final turnoHour = int.parse(timeParts[0]);
          final turnoMinute = int.parse(timeParts[1]);

          // Create turno datetime for today
          turnoDateTime = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            turnoHour,
            turnoMinute,
          );
        } else {
          throw FormatException('Invalid time format: $turnoInicioStr');
        }
      } else {
        // Handle simple HH:mm format
        final turnoTimeParts = turnoInicioStr.split(':');
        if (turnoTimeParts.length != 2) {
          throw FormatException('Invalid time format: $turnoInicioStr');
        }

        final turnoHour = int.parse(turnoTimeParts[0]);
        final turnoMinute = int.parse(turnoTimeParts[1]);

        // Create turno datetime for today
        turnoDateTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          turnoHour,
          turnoMinute,
        );
      }

      // Add tolerance to get the late threshold
      final lateThreshold = turnoDateTime.add(Duration(minutes: tolerancia));

      // Determine actual access type
      final actualAccessType =
          _getActualAccessType(accessType, isDefaultEntryConfig);

      // Determine if it's late (only for entries)
      bool isLate = false;
      String message = '';

      if (actualAccessType == ScannerAccessType.entry &&
          currentTime.isAfter(lateThreshold)) {
        isLate = true;
        message = 'Llegada tardía (tolerancia: $tolerancia min)';
      } else if (actualAccessType == ScannerAccessType.entry) {
        message = 'Llegada a tiempo';
      } else {
        message = 'Salida registrada';
      }

      debugPrint('Turno start time: ${_formatTime(turnoDateTime)}');
      debugPrint('Late threshold: ${_formatTime(lateThreshold)}');
      debugPrint('Current time: ${_formatTime(currentTime)}');
      debugPrint('Is late: $isLate');

      return {
        'accessType': actualAccessType,
        'isLate': isLate,
        'turnoDateTime': turnoDateTime,
        'lateThreshold': lateThreshold,
        'currentTime': currentTime,
        'message': message,
      };
    } catch (e) {
      debugPrint('Error parsing turno time: $e');
      debugPrint('Turno time string was: $turnoInicioStr');
      return {
        'accessType': _getActualAccessType(accessType, isDefaultEntryConfig),
        'isLate': false,
        'turnoDateTime': currentTime,
        'lateThreshold': currentTime,
        'currentTime': currentTime,
        'message': 'Error al validar horario',
      };
    }
  }

  /// Helper method to determine actual access type
  ScannerAccessType _getActualAccessType(
      ScannerAccessType accessType, bool isDefaultEntryConfig) {
    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntryConfig
            ? ScannerAccessType.entry
            : ScannerAccessType.exit;
      case ScannerAccessType.entry:
      case ScannerAccessType.exit:
        return accessType;
    }
  }

  /// Create notification with proper type and content and comprehensive validation
  Future<Map<String, dynamic>> _createNotification({
    required Map<String, dynamic> studentData,
    required String adminId,
    required Map<String, dynamic> accessInfo,
    required DateTime timestamp,
  }) async {
    try {
      final String studentName =
          studentData['nombre']?.toString() ?? 'Estudiante';
      final String? studentId = studentData['id']?.toString();
      final String? studentSchoolId = studentData['id_escuela']?.toString();

      if (studentId == null || studentId.isEmpty) {
        return {
          'success': false,
          'error': 'ID del estudiante no válido',
        };
      }

      if (studentSchoolId == null || studentSchoolId.isEmpty) {
        return {
          'success': false,
          'error': 'Escuela del estudiante no válida',
        };
      }

      // Step 1: Validate admin user and school association
      final adminInfo = await _getAdminUserInfo(adminId);
      if (adminInfo == null) {
        return {
          'success': false,
          'error': 'Usuario administrador no encontrado',
        };
      }

      final String? adminSchoolId = adminInfo['id_escuela']?.toString();
      final String? userType = adminInfo['tipo']?.toString();

      // Validate admin has school assigned (if is admin type)
      if (userType == 'administrador' &&
          (adminSchoolId == null || adminSchoolId.isEmpty)) {
        return {
          'success': false,
          'error': 'El administrador no tiene escuela asignada',
        };
      }

      // Validate student belongs to admin's school
      if (userType == 'administrador' && adminSchoolId != studentSchoolId) {
        return {
          'success': false,
          'error': 'La escuela del alumno escaneado no pertenece a la actual',
        };
      }

      // Step 2: Validate student has tutor registration and valid key
      debugPrint('Validating student registration for ID: $studentId');
      final validationResult = await _validateStudentKeyAndTutor(studentId);
      debugPrint('Validation result: $validationResult');

      if (!validationResult['isValid']) {
        debugPrint('Student validation failed: ${validationResult['error']}');
        return {
          'success': false,
          'error': validationResult['error'],
        };
      }

      debugPrint(
          'Student validation passed, proceeding with notification creation');

      // Step 3: Validate data consistency - group belongs to same school
      final String? groupId = studentData['id_grupo']?.toString();
      if (groupId != null) {
        final groupValidation = await _validateStudentGroupConsistency(
            studentId, studentSchoolId, groupId);
        if (!groupValidation['isValid']) {
          return {
            'success': false,
            'error': groupValidation['error'],
          };
        }
      }

      // Step 4: Validate turno belongs to same school
      final String? turnoId = studentData['id_turno']?.toString();
      if (turnoId != null) {
        final turnoValidation =
            await _validateTurnoSchoolConsistency(turnoId, studentSchoolId);
        if (!turnoValidation['isValid']) {
          return {
            'success': false,
            'error': turnoValidation['error'],
          };
        }
      }

      // Step 5: Additional validation - check if student is active (if field exists)
      if (studentData['activo'] != null && studentData['activo'] == false) {
        return {
          'success': false,
          'error': 'El alumno está inactivo en el sistema',
        };
      }

      // Step 6: Validate no duplicate notification in short time window (prevent double scans)
      final recentNotification =
          await _checkRecentNotification(studentId, timestamp);
      if (recentNotification != null) {
        final minutes = recentNotification['minutes'] as int;
        final displayMinutes =
            minutes <= 0 ? 1 : minutes; // Show minimum 1 minute

        return {
          'success': false,
          'error':
              'Ya existe un registro reciente para este alumno (hace $displayMinutes minuto${displayMinutes == 1 ? '' : 's'})',
        };
      }

      final ScannerAccessType accessType = accessInfo['accessType'];
      final bool isLate = accessInfo['isLate'] ?? false;

      // Determine notification type
      NotificationType notificationType;
      if (accessType == ScannerAccessType.exit) {
        notificationType = NotificationType.salida;
      } else if (isLate) {
        notificationType = NotificationType.retraso;
      } else {
        notificationType = NotificationType.entrada;
      }

      // Generate title based on access type and timing
      String titulo;
      if (accessType == ScannerAccessType.exit) {
        titulo = '$studentName ha salido';
      } else if (isLate) {
        titulo = '$studentName llegó tarde';
      } else {
        titulo = '$studentName ha llegado';
      }

      // Generate message with exact timestamp
      String mensaje;
      final timeString = _formatTime(timestamp);
      if (accessType == ScannerAccessType.exit) {
        mensaje = '$studentName salió de la escuela a las $timeString';
      } else if (isLate) {
        mensaje = '$studentName llegó tarde a la escuela a las $timeString';
      } else {
        mensaje = '$studentName llegó a la escuela a las $timeString';
      }

      // Create notification in database
      final response = await _supabase
          .from('notificaciones')
          .insert({
            'id_alumno': studentId,
            'id_admin': adminId,
            'titulo': titulo,
            'mensaje': mensaje,
            'tipo_notificacion': notificationType.name,
            'estado': 'nueva',
            'fecha_registro':
                timestamp.toUtc().toIso8601String(), // Ensure UTC storage
          })
          .select()
          .single();

      // Send push notification to student's tutors
      final notificationId = response['id']?.toString() ?? '';
      try {
        await _fcmService.sendNotificationToStudentTutors(
          studentId: studentId,
          title: titulo,
          body: mensaje,
          notificationId: notificationId,
          additionalData: {
            'access_type': accessType.name,
            'is_late': isLate.toString(),
            'timestamp': timestamp.toIso8601String(),
          },
        );
        debugPrint('FCM: Push notification sent successfully for attendance');
      } catch (e) {
        debugPrint('FCM: Error sending push notification for attendance: $e');
        // Don't fail the whole process if push notification fails
      }

      return {
        'success': true,
        'notification': {
          'id': notificationId,
          'titulo': titulo,
          'mensaje': mensaje,
          'tipo': notificationType.name,
          'fecha': timestamp.toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return {
        'success': false,
        'error': 'Error al crear la notificación: $e',
      };
    }
  }

  /// Format time for display in messages
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Convert ScannerAccessType to string for display
  String getAccessTypeDisplayName(
    ScannerAccessType accessType,
    bool isDefaultEntryConfig,
  ) {
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

  /// Get appropriate color for access type
  Color getAccessTypeColor(
    ScannerAccessType accessType,
    bool isDefaultEntryConfig,
  ) {
    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntryConfig ? Colors.green : Colors.red;
      case ScannerAccessType.entry:
        return Colors.green;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  /// Get appropriate icon for access type
  IconData getAccessTypeIcon(
    ScannerAccessType accessType,
    bool isDefaultEntryConfig,
  ) {
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

  /// Get admin user information for validation
  Future<Map<String, dynamic>?> _getAdminUserInfo(String adminId) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select('id, id_escuela, tipo, tipo_administrador')
          .eq('id', adminId)
          .maybeSingle();

      if (response == null) {
        debugPrint('Admin user not found with ID: $adminId');
        return null;
      }

      return response;
    } catch (e) {
      debugPrint('Error getting admin user info: $e');
      return null;
    }
  }

  /// Validate if student has valid key registration
  Future<Map<String, dynamic>> _validateStudentKeyAndTutor(
      String studentId) async {
    try {
      debugPrint('Checking tutor registration for student ID: $studentId');

      // Check if student has any tutor registration
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id')
          .eq('id_alumno', studentId)
          .maybeSingle();

      debugPrint('Tutor registration query result: $tutorResponse');

      if (tutorResponse == null) {
        debugPrint('No tutor registration found for student ID: $studentId');
        return {
          'isValid': false,
          'error': 'El alumno aún no ha sido registrado por un familiar',
        };
      }

      debugPrint(
          'Tutor registration found, checking key validity for student ID: $studentId');

      // Check if student has a valid (not expired) key
      final currentDateTime = DateTime.now();
      final keyResponse = await _supabase
          .from('llaves')
          .select('id, fecha_registro, fecha_desactivacion, activo')
          .eq('id_alumno', studentId)
          .eq('activo', true)
          .maybeSingle();

      if (keyResponse == null) {
        return {
          'isValid': false,
          'error': 'El alumno no tiene una llave activa asignada',
        };
      }

      // Parse dates and validate key is not expired
      try {
        final fechaRegistro = DateTime.parse(keyResponse['fecha_registro']);
        final fechaDesactivacion =
            DateTime.parse(keyResponse['fecha_desactivacion']);

        if (currentDateTime.isBefore(fechaRegistro) ||
            currentDateTime.isAfter(fechaDesactivacion)) {
          return {
            'isValid': false,
            'error': 'La llave del alumno está vencida',
          };
        }
      } catch (e) {
        debugPrint('Error parsing key dates: $e');
        return {
          'isValid': false,
          'error': 'Error al validar fechas de la llave del alumno',
        };
      }

      return {
        'isValid': true,
      };
    } catch (e) {
      debugPrint('Error validating student key and tutor: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar registro del alumno: $e',
      };
    }
  }

  /// Check for recent notifications to prevent duplicate scans
  Future<Map<String, dynamic>?> _checkRecentNotification(
      String studentId, DateTime currentTime) async {
    try {
      // Check for notifications in the last 2 minutes to prevent duplicate scans
      final twoMinutesAgo = currentTime.subtract(const Duration(minutes: 2));

      final response = await _supabase
          .from('notificaciones')
          .select('id, fecha_registro')
          .eq('id_alumno', studentId)
          .gte('fecha_registro',
              twoMinutesAgo.toUtc().toIso8601String()) // Convert to UTC
          .order('fecha_registro', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        // Parse the timestamp and ensure it's in UTC, then convert to local
        final notificationTimeStr = response['fecha_registro'].toString();

        DateTime notificationTime;
        if (notificationTimeStr.endsWith('Z') ||
            notificationTimeStr.contains('+')) {
          // Already has timezone info
          notificationTime = DateTime.parse(notificationTimeStr).toLocal();
        } else {
          // Assume it's UTC and convert to local
          notificationTime =
              DateTime.parse('${notificationTimeStr}Z').toLocal();
        }

        // Calculate difference using local times
        final diffInMinutes =
            currentTime.difference(notificationTime).inMinutes;

        // Debug information
        debugPrint('Current time (local): ${currentTime.toIso8601String()}');
        debugPrint(
            'Notification time (parsed to local): ${notificationTime.toIso8601String()}');
        debugPrint('Difference in minutes: $diffInMinutes');

        return {
          'minutes': diffInMinutes,
          'notification_id': response['id'],
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error checking recent notifications: $e');
      return null; // Allow registration if we can't check (fail-open for better UX)
    }
  }

  /// Validate student group belongs to the same school
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
          'error': 'El grupo del estudiante no existe en el sistema',
        };
      }

      final String? groupSchoolId = response['id_escuela']?.toString();
      if (groupSchoolId != studentSchoolId) {
        return {
          'isValid': false,
          'error': 'El grupo del estudiante no pertenece a la escuela correcta',
        };
      }

      return {
        'isValid': true,
      };
    } catch (e) {
      debugPrint('Error validating student group consistency: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar grupo del estudiante: $e',
      };
    }
  }

  /// Validate turno belongs to the same school as student
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
          'error': 'El turno del estudiante no existe en el sistema',
        };
      }

      final String? turnoSchoolId = response['id_escuela']?.toString();
      if (turnoSchoolId != studentSchoolId) {
        return {
          'isValid': false,
          'error': 'El turno del estudiante no pertenece a la escuela correcta',
        };
      }

      return {
        'isValid': true,
      };
    } catch (e) {
      debugPrint('Error validating turno school consistency: $e');
      return {
        'isValid': false,
        'error': 'Error interno al validar turno del estudiante: $e',
      };
    }
  }
}
