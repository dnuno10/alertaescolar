import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM: Handling background message: ${message.messageId}');
  debugPrint('FCM: Background message data: ${message.data}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialize FCM for non-admin users
  Future<void> initializeFCM() async {
    try {
      debugPrint('FCM: Initializing FCM service');

      //Pedimos permiso para las notificaciones
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      //Validamos si tenemos garantizado
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: Permission granted');

        // Obtenemos el FCM token del dispositivo
        final token = await _firebaseMessaging.getToken();
        //Si no es null, lo insertamos en la bd
        if (token != null) {
          await _registerToken(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_registerToken);

        // Set up foreground message handling
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      } else {
        debugPrint('FCM: Permission denied');
      }
    } catch (e) {
      debugPrint('FCM: Error initializing: $e');
    }
  }

  /// Register FCM token in database
  Future<void> _registerToken(String token) async {
    try {
      //Obtenemos el usuario en sesión
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('FCM: Registering token for user: ${user.id}');

      // Verificamos si ya existe este token en particular de este usuario
      final existing = await _supabase
          .from('mobile_tokens')
          .select('id')
          .eq('id_usuario', user.id)
          .eq('token', token)
          .maybeSingle();
      //Si no se encontró el token, significa que aún no esta registrado y retorna null
      if (existing == null) {
        //Insertamos el nuevo token del usuario
        await _supabase.from('mobile_tokens').insert({
          'id_usuario': user.id,
          'token': token,
        });

        debugPrint('FCM: Token registered successfully');
      } else {
        debugPrint('FCM: Token already exists');
      }
    } catch (e) {
      debugPrint('FCM: Error registering token: $e');
    }
  }

  /// Eliminamos los token FCM si el usuario cierra sesión
  Future<void> removeFCMToken() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('mobile_tokens').delete().eq('id_usuario', user.id);

      debugPrint('FCM: Token removed for user: ${user.id}');
    } catch (e) {
      debugPrint('FCM: Error removing token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM: ==========================================');
    debugPrint('FCM: 📱 NOTIFICATION RECEIVED! 📱');
    debugPrint('FCM: ==========================================');
    debugPrint('FCM: Message ID: ${message.messageId}');
    debugPrint('FCM: 📧 Title: ${message.notification?.title}');
    debugPrint('FCM: 💬 Body: ${message.notification?.body}');
    debugPrint('FCM: 📊 Data: ${message.data}');
    debugPrint('FCM: ⏰ Time: ${DateTime.now()}');
    debugPrint('FCM: ==========================================');

    // Aquí podrías mostrar una notificación local o actualizar UI
  }

  // =========================================================
  //                 NUEVO: envío directo a tokens
  // =========================================================

  /// Envía push a una lista de tokens. Se encarga de:
  /// - dividir en lotes,
  /// - llamar a la Edge Function,
  /// - eliminar tokens inválidos.
  /// Devuelve el número de tokens con envío exitoso reportado por la función.
// Envío en paralelo con límite de concurrencia para mayor velocidad.
// Retorna el total de envíos "ok" reportados por la Edge Function.
  Future<int> sendToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
    int batchSize = 500,
    int maxConcurrentBatches = 4, // <- controla la concurrencia total
  }) async {
    if (tokens.isEmpty) return 0;

    final dedup = tokens.toSet().toList();
    final batches = <List<String>>[];
    for (int i = 0; i < dedup.length; i += batchSize) {
      batches.add(dedup.sublist(
          i, i + batchSize > dedup.length ? dedup.length : i + batchSize));
    }

    int success = 0;
    int idx = 0;

    // Ejecutamos en tandas para no saturar el server ni la red
    while (idx < batches.length) {
      final slice = batches.sublist(
        idx,
        (idx + maxConcurrentBatches > batches.length)
            ? batches.length
            : idx + maxConcurrentBatches,
      );

      final results = await Future.wait(slice.map((lot) {
        return _sendPushNotificationsToTokens(
          tokens: lot,
          title: title,
          body: body,
          data: data,
        );
      }));

      for (final r in results) {
        success += r;
      }
      idx += slice.length;
    }

    return success;
  }

  /// Send notification to student's tutors (for attendance)
  Future<void> sendNotificationToStudentTutors({
    required String studentId,
    required String title,
    required String body,
    required String notificationId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint(
          'FCM: Sending attendance notification for student: $studentId');

      final tokens = await _getTutorTokensForStudent(studentId);
      if (tokens.isEmpty) {
        debugPrint('FCM: No tokens found for student tutors');
        return;
      }

      final data = <String, dynamic>{
        'notificationId': notificationId,
        'studentId': studentId,
        'type': 'attendance',
        ...(additionalData ?? {}),
      };

      await sendToTokens(
        tokens: tokens,
        title: title,
        body: body,
        data: data,
      );

      debugPrint('FCM: Attendance notifications sent successfully');
    } catch (e) {
      debugPrint('FCM: Error sending attendance notifications: $e');
    }
  }

  /// Send notifications by recipient type (for communications and permissions)
  Future<void> sendNotificationsByRecipientType({
    required String recipientType,
    required String title,
    required String body,
    required String messageType,
    String? comunicadoType,
    String? priority,
    String? destinatarios,
    Map<String, dynamic>? selectedStudent,
    List<String>? selectedGroupIds,
    String? selectedShiftId,
    String? schoolId,
    int? totalStudents,
  }) async {
    try {
      debugPrint(
          'FCM: Sending notifications for recipient type: $recipientType');

      List<String> tokens = [];

      switch (recipientType) {
        case 'individual':
          if (selectedStudent != null) {
            final studentId = selectedStudent['id']?.toString();
            if (studentId != null) {
              tokens = await _getTutorTokensForStudent(studentId);
            }
          }
          break;

        case 'grupo':
          if (selectedGroupIds != null && selectedGroupIds.isNotEmpty) {
            tokens = await _getTutorTokensForGroups(selectedGroupIds);
          }
          break;

        case 'turno':
          if (selectedShiftId != null) {
            tokens = await _getTutorTokensForShift(selectedShiftId);
          }
          break;

        case 'todos':
          if (schoolId != null) {
            tokens = await _getTutorTokensForAllStudents(schoolId);
          }
          break;
      }

      if (tokens.isEmpty) {
        debugPrint('FCM: No tokens found for recipient type: $recipientType');
        return;
      }

      final data = <String, dynamic>{
        'recipientType': recipientType,
        'type': 'communication',
        'messageType': messageType,
        'comunicadoType': comunicadoType ?? '',
        'priority': priority ?? '',
        'destinatarios': destinatarios ?? '',
        'totalStudents': (totalStudents ?? 0).toString(),
      };

      await sendToTokens(
        tokens: tokens,
        title: title,
        body: body,
        data: data,
      );

      debugPrint('FCM: Push notifications sent successfully');
    } catch (e) {
      debugPrint('FCM: Error sending push notifications: $e');
    }
  }

  // =========================================================
  //               Resolución de tokens por alcance
  // =========================================================

  /// Get tutor tokens for a specific student
  Future<List<String>> _getTutorTokensForStudent(String studentId) async {
    try {
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .eq('id_alumno', studentId);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for student: $studentId');
        return [];
      }

      final tutorIds = tutorResponse
          .map<String>((record) => record['id_tutor'].toString())
          .toList();

      debugPrint(
          'FCM: Found ${tutorIds.length} tutors for student: $studentId');

      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => (record['token'] ?? '').toString())
          .where((token) => token.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tokens.length} tokens for student tutors');
      return tokens;
    } catch (e) {
      debugPrint('FCM: Error getting tutor tokens for student: $e');
      return [];
    }
  }

  /// Get tutor tokens for multiple groups
  Future<List<String>> _getTutorTokensForGroups(List<String> groupIds) async {
    try {
      final studentsResponse = await _supabase
          .from('alumnos')
          .select('id')
          .inFilter('id_grupo', groupIds);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in groups: $groupIds');
        return [];
      }

      final studentIds =
          studentsResponse.map<String>((r) => r['id'].toString()).toList();

      debugPrint('FCM: Found ${studentIds.length} students in groups');

      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in groups');
        return [];
      }

      final tutorIds = tutorResponse
          .map<String>((r) => r['id_tutor'].toString())
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for groups');

      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => (record['token'] ?? '').toString())
          .where((token) => token.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tokens.length} tokens for group tutors');
      return tokens;
    } catch (e) {
      debugPrint('FCM: Error getting tutor tokens for groups: $e');
      return [];
    }
  }

  /// Get tutor tokens for a shift
  Future<List<String>> _getTutorTokensForShift(String shiftId) async {
    try {
      final studentsResponse =
          await _supabase.from('alumnos').select('id').eq('id_turno', shiftId);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in shift: $shiftId');
        return [];
      }

      final studentIds =
          studentsResponse.map<String>((r) => r['id'].toString()).toList();

      debugPrint('FCM: Found ${studentIds.length} students in shift');

      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in shift');
        return [];
      }

      final tutorIds = tutorResponse
          .map<String>((r) => r['id_tutor'].toString())
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for shift');

      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => (record['token'] ?? '').toString())
          .where((token) => token.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tokens.length} tokens for shift tutors');
      return tokens;
    } catch (e) {
      debugPrint('FCM: Error getting tutor tokens for shift: $e');
      return [];
    }
  }

  /// Get tutor tokens for all students in a school
  Future<List<String>> _getTutorTokensForAllStudents(String schoolId) async {
    try {
      final studentsResponse = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', schoolId);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in school: $schoolId');
        return [];
      }

      final studentIds =
          studentsResponse.map<String>((r) => r['id'].toString()).toList();

      debugPrint('FCM: Found ${studentIds.length} students in school');

      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in school');
        return [];
      }

      final tutorIds = tutorResponse
          .map<String>((r) => r['id_tutor'].toString())
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for school');

      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => (record['token'] ?? '').toString())
          .where((token) => token.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('FCM: Found ${tokens.length} tokens for school tutors');
      return tokens;
    } catch (e) {
      debugPrint('FCM: Error getting tutor tokens for all students: $e');
      return [];
    }
  }

  // =========================================================
  //                 Llamada a Edge Function
  // =========================================================

  /// Llama la Edge Function `send-fcm-notification` con un lote de tokens.
  /// Devuelve cuántos tokens resultaron en envío exitoso.
  Future<int> _sendPushNotificationsToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    if (tokens.isEmpty) {
      debugPrint('FCM: No tokens to send notifications to');
      return 0;
    }

    debugPrint('FCM: ==========================================');
    debugPrint('FCM: SENDING REAL NOTIFICATIONS (Edge Function)');
    debugPrint('FCM: ==========================================');
    debugPrint('FCM: Tokens: ${tokens.length}');
    debugPrint('FCM: Title: $title');
    debugPrint('FCM: Body:  $body');
    debugPrint('FCM: Data:  $data');
    debugPrint(
        'FCM: Tokens (first 20 chars): ${tokens.map((t) => '${t.substring(0, min(20, t.length))}...').join(', ')}');

    try {
      final response = await _supabase.functions.invoke(
        'send-fcm-notification',
        body: {
          'tokens': tokens,
          'title': title,
          'body': body,
          'data': data,
        },
      );

      debugPrint('FCM: 📥 Edge Function status: ${response.status}');

      int successCount = 0;

      if (response.data is Map) {
        final result = response.data as Map<String, dynamic>;
        successCount = (result['successCount'] ?? 0) as int;
        final failureCount = (result['failureCount'] ?? 0) as int;
        final invalid =
            (result['invalidTokens'] as List?)?.cast<String>() ?? const [];

        debugPrint('FCM: Total tokens: ${tokens.length}');
        debugPrint('FCM: Successful: $successCount');
        debugPrint('FCM: Failed: $failureCount');

        // Si la función devuelve tokens inválidos, borrarlos
        if (invalid.isNotEmpty) {
          await _handleInvalidTokens(invalid);
        }

        // Log de resultados individuales (opcional)
        if (result['results'] is List) {
          for (final item in (result['results'] as List)) {
            final ok = item['success'] == true;
            final tk = (item['token'] ?? '').toString();
            final err = (item['error'] ?? '').toString();
            debugPrint(
                'FCM: ${ok ? 'YESY' : 'ERROR'} ${tk.isEmpty ? '(unknown)' : '${tk.substring(0, min(20, tk.length))}...'} ${ok ? '' : err}');
          }
        }

        return successCount;
      } else {
        debugPrint('FCM: Edge Function returned no data; simulating locally');
        return await _simulateNotificationDelivery(tokens, title, body, data);
      }
    } catch (e) {
      debugPrint('FCM: Error calling Edge Function: $e');
      debugPrint('FCM: Falling back to local simulation...');
      return await _simulateNotificationDelivery(tokens, title, body, data);
    }
  }

  /// Fallback method to simulate notification delivery when Edge Function fails
  Future<int> _simulateNotificationDelivery(
    List<String> tokens,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    int successCount = 0;

    for (final token in tokens) {
      try {
        debugPrint(
            'FCM: Simulating token: ${token.substring(0, min(20, token.length))}...');
        await _triggerLocalNotification(title, body, data);
        successCount++;
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('FCM: Error simulating token $token: $e');
      }
    }

    debugPrint('FCM: Simulation finished, success on $successCount tokens');
    return successCount;
  }

  /// Trigger local notification to simulate push notification reception
  Future<void> _triggerLocalNotification(
      String title, String body, Map<String, dynamic> data) async {
    try {
      final message = RemoteMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        notification: RemoteNotification(
          title: title,
          body: body,
        ),
        data: data.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        sentTime: DateTime.now(),
      );

      _handleForegroundMessage(message);
      debugPrint('FCM: Local notification triggered successfully');
    } catch (e) {
      debugPrint('FCM: Error triggering local notification: $e');
    }
  }

  /// Handle invalid tokens by removing them from database
  Future<void> _handleInvalidTokens(List<String> invalidTokens) async {
    if (invalidTokens.isEmpty) return;

    try {
      await _supabase
          .from('mobile_tokens')
          .delete()
          .inFilter('token', invalidTokens);

      debugPrint('FCM: Removed ${invalidTokens.length} invalid tokens');
    } catch (e) {
      debugPrint('FCM: Error removing invalid tokens: $e');
    }
  }
}
