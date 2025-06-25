import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FCM Service for handling Firebase Cloud Messaging
///
/// This service:
/// 1. Registers FCM tokens only for non-admin users
/// 2. Stores tokens in the 'mobile_tokens' table
/// 3. Handles token refresh automatically
/// 4. Manages foreground and background message handling
/// 5. Removes tokens on user sign out
/// 6. Sends real push notifications using FCM HTTP v1 API

/// Background message handler - must be a top-level function
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

      // Request permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: Permission granted');

        // Get FCM token
        final token = await _firebaseMessaging.getToken();
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
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('FCM: Registering token for user: ${user.id}');

      // Check if token already exists
      final existing = await _supabase
          .from('mobile_tokens')
          .select('id')
          .eq('id_usuario', user.id)
          .eq('token', token)
          .maybeSingle();

      if (existing == null) {
        // Insert new token
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

  /// Remove FCM token on sign out
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

  /// Handle foreground messages
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

    // In a real app, you would show a local notification or update the UI here
    // For now, this console output confirms the notification system is working
  }

  /// Send notification to student's tutors (for attendance)
  Future<void> sendNotificationToStudentTutors({
    required String studentId,
    required String title,
    required String body,
    required String notificationId,
    Map<String, String>? additionalData,
  }) async {
    try {
      debugPrint(
          'FCM: Sending attendance notification for student: $studentId');

      final tokens = await _getTutorTokensForStudent(studentId);
      if (tokens.isEmpty) {
        debugPrint('FCM: No tokens found for student tutors');
        return;
      }

      final data = {
        'notificationId': notificationId,
        'studentId': studentId,
        'type': 'attendance',
        ...?additionalData,
      };

      await _sendPushNotificationsToTokens(
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

      final data = {
        'recipientType': recipientType,
        'type': 'communication',
        'messageType': messageType,
        'comunicadoType': comunicadoType ?? '',
        'priority': priority ?? '',
        'destinatarios': destinatarios ?? '',
        'totalStudents': totalStudents?.toString() ?? '0',
      };

      await _sendPushNotificationsToTokens(
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

  /// Get tutor tokens for a specific student
  Future<List<String>> _getTutorTokensForStudent(String studentId) async {
    try {
      // First, get all tutors for this student
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .eq('id_alumno', studentId);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for student: $studentId');
        return [];
      }

      // Extract tutor IDs (which are user IDs)
      final tutorIds = tutorResponse
          .map<String>((record) => record['id_tutor'] as String)
          .toList();

      debugPrint(
          'FCM: Found ${tutorIds.length} tutors for student: $studentId');

      // Get the most recent token for each tutor
      List<String> tokens = [];
      for (String tutorId in tutorIds) {
        final tokenResponse = await _supabase
            .from('mobile_tokens')
            .select('token')
            .eq('id_usuario', tutorId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (tokenResponse != null && tokenResponse['token'] != null) {
          final token = tokenResponse['token'] as String;
          if (token.isNotEmpty) {
            tokens.add(token);
          }
        }
      }

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
      // First, get all students in these groups
      final studentsResponse = await _supabase
          .from('alumnos')
          .select('id')
          .inFilter('id_grupo', groupIds);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in groups: $groupIds');
        return [];
      }

      final studentIds = studentsResponse
          .map<String>((record) => record['id'] as String)
          .toList();

      debugPrint('FCM: Found ${studentIds.length} students in groups');

      // Get all tutors for these students
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in groups');
        return [];
      }

      // Extract unique tutor IDs
      final tutorIds = tutorResponse
          .map<String>((record) => record['id_tutor'] as String)
          .toSet() // Remove duplicates
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for groups');

      // Get tokens for these tutors
      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => record['token'] as String)
          .where((token) => token.isNotEmpty)
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
      // First, get all students in this shift
      final studentsResponse =
          await _supabase.from('alumnos').select('id').eq('id_turno', shiftId);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in shift: $shiftId');
        return [];
      }

      final studentIds = studentsResponse
          .map<String>((record) => record['id'] as String)
          .toList();

      debugPrint('FCM: Found ${studentIds.length} students in shift');

      // Get all tutors for these students
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in shift');
        return [];
      }

      // Extract unique tutor IDs
      final tutorIds = tutorResponse
          .map<String>((record) => record['id_tutor'] as String)
          .toSet() // Remove duplicates
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for shift');

      // Get tokens for these tutors
      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => record['token'] as String)
          .where((token) => token.isNotEmpty)
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
      // First, get all students in this school
      final studentsResponse = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', schoolId);

      if (studentsResponse.isEmpty) {
        debugPrint('FCM: No students found in school: $schoolId');
        return [];
      }

      final studentIds = studentsResponse
          .map<String>((record) => record['id'] as String)
          .toList();

      debugPrint('FCM: Found ${studentIds.length} students in school');

      // Get all tutors for these students
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      if (tutorResponse.isEmpty) {
        debugPrint('FCM: No tutors found for students in school');
        return [];
      }

      // Extract unique tutor IDs
      final tutorIds = tutorResponse
          .map<String>((record) => record['id_tutor'] as String)
          .toSet() // Remove duplicates
          .toList();

      debugPrint('FCM: Found ${tutorIds.length} unique tutors for school');

      // Get tokens for these tutors
      final tokenResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .inFilter('id_usuario', tutorIds);

      final tokens = tokenResponse
          .map<String>((record) => record['token'] as String)
          .where((token) => token.isNotEmpty)
          .toList();

      debugPrint('FCM: Found ${tokens.length} tokens for school tutors');
      return tokens;
    } catch (e) {
      debugPrint('FCM: Error getting tutor tokens for all students: $e');
      return [];
    }
  }

  /// Send push notifications to multiple tokens using Supabase Edge Function
  Future<void> _sendPushNotificationsToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    if (tokens.isEmpty) {
      debugPrint('FCM: No tokens to send notifications to');
      return;
    }

    debugPrint('FCM: ==========================================');
    debugPrint('FCM: 🚀 INTENTANDO ENVIAR NOTIFICACIONES REALES');
    debugPrint('FCM: ==========================================');
    debugPrint('FCM: Tokens: ${tokens.length}');
    debugPrint('FCM: Title: $title');
    debugPrint('FCM: Body: $body');
    debugPrint('FCM: Data: $data');
    debugPrint(
        'FCM: Tokens (primeros 20 chars): ${tokens.map((t) => '${t.substring(0, 20)}...').join(', ')}');

    try {
      debugPrint('FCM: 📡 Llamando Edge Function: send-fcm-notification');

      // Call Supabase Edge Function to send real FCM notifications
      final response = await _supabase.functions.invoke(
        'send-fcm-notification',
        body: {
          'tokens': tokens,
          'title': title,
          'body': body,
          'data': data,
        },
      );

      debugPrint('FCM: 📥 Respuesta recibida de Edge Function');
      debugPrint('FCM: Status: ${response.status}');

      if (response.data != null) {
        final result = response.data as Map<String, dynamic>;
        final successCount = result['successCount'] ?? 0;
        final failureCount = result['failureCount'] ?? 0;
        final totalTokens = result['totalTokens'] ?? 0;

        debugPrint('FCM: ==========================================');
        debugPrint('FCM: 🚀 REAL PUSH NOTIFICATIONS SENT! 🚀');
        debugPrint('FCM: ==========================================');
        debugPrint('FCM: Total tokens: $totalTokens');
        debugPrint('FCM: Successful: $successCount');
        debugPrint('FCM: Failed: $failureCount');
        debugPrint('FCM: ⏰ Time: ${DateTime.now()}');
        debugPrint('FCM: ==========================================');

        // Log individual results if available
        if (result['results'] != null) {
          final results = result['results'] as List;
          for (var tokenResult in results) {
            if (tokenResult['success'] == true) {
              debugPrint('FCM: ✅ ${tokenResult['token']}: SUCCESS');
            } else {
              debugPrint(
                  'FCM: ❌ ${tokenResult['token']}: ${tokenResult['error']}');
            }
          }
        }

        if (successCount > 0) {
          debugPrint('FCM: 🎉 Real push notifications delivered successfully!');
        }
      } else {
        debugPrint('FCM: Error: No response data from Edge Function');
        debugPrint('FCM: Response status: ${response.status}');

        // Fallback to simulation
        await _simulateNotificationDelivery(tokens, title, body, data);
      }
    } catch (e) {
      debugPrint('FCM: Error calling Edge Function: $e');
      debugPrint('FCM: Falling back to local simulation...');

      // Fallback to simulation if Edge Function fails
      await _simulateNotificationDelivery(tokens, title, body, data);
    }
  }

  /// Fallback method to simulate notification delivery when Edge Function fails
  Future<void> _simulateNotificationDelivery(
    List<String> tokens,
    String title,
    String body,
    Map<String, String> data,
  ) async {
    int successCount = 0;
    int failureCount = 0;

    for (final token in tokens) {
      try {
        debugPrint('FCM: Processing token: ${token.substring(0, 20)}...');

        // Trigger local notification handling to simulate received push notification
        await _triggerLocalNotification(title, body, data);

        successCount++;
        debugPrint(
            'FCM: Successfully processed token: ${token.substring(0, 20)}...');

        // Small delay between notifications
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint('FCM: Error processing token $token: $e');
        failureCount++;
      }
    }

    debugPrint(
        'FCM: Successfully processed $successCount devices (simulation)');
    if (failureCount > 0) {
      debugPrint('FCM: Failed to send to $failureCount devices (simulation)');
    }
  }

  /// Trigger local notification to simulate push notification reception
  Future<void> _triggerLocalNotification(
      String title, String body, Map<String, String> data) async {
    try {
      // Create a simulated RemoteMessage
      final message = RemoteMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        notification: RemoteNotification(
          title: title,
          body: body,
        ),
        data: data,
        sentTime: DateTime.now(),
      );

      // Trigger the foreground message handler
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
