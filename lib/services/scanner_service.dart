import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ScannerAccessType { entry, exit, automatic }

enum NotificationType { entrada, salida, retraso }

class ScannerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Process a scanned QR code with complete validation and notification creation
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

      // Fix validation - check the actual fields that exist
      if (response['id'] == null ||
          response['nombre'] == null ||
          response['matricula'] == null ||
          response['id_escuela'] == null ||
          response['id_turno'] == null) {
        // This field exists in the response
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
        message = 'Llegada tardía (tolerancia: ${tolerancia} min)';
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

  /// Create notification with proper type and content
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

      if (studentId == null || studentId.isEmpty) {
        return {
          'success': false,
          'error': 'ID del estudiante no válido',
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
            'fecha_registro': timestamp.toIso8601String(),
          })
          .select()
          .single();

      return {
        'success': true,
        'notification': {
          'id': response['id']?.toString() ?? '',
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
}
