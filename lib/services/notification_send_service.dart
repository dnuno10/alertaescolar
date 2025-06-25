import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comunicado.dart';
import '../models/grupo.dart';
import '../models/turno.dart';
import 'fcm_service.dart';

class NotificationSendService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FCMService _fcmService = FCMService();

  /// Send notification based on recipient type and message details
  Future<Map<String, dynamic>> sendNotification({
    required String adminId,
    required String schoolId,
    required String messageType, // 'permiso' or 'comunicado'
    required String recipientType, // 'individual', 'grupo', 'turno', 'todos'
    required String title,
    required String message,
    TipoComunicado? comunicadoType,
    PrioridadComunicado? priority,
    Map<String, dynamic>? selectedStudent,
    List<Grupo>? selectedGroups,
    Turno? selectedShift,
  }) async {
    try {
      debugPrint('Sending notification: $messageType to $recipientType');

      List<String> targetStudentIds = [];
      String destinatarios = '';

      // Get target student IDs based on recipient type
      switch (recipientType) {
        case 'individual':
          if (selectedStudent != null) {
            targetStudentIds.add(selectedStudent['id']);
            destinatarios = 'Estudiante: ${selectedStudent['name']}';
          }
          break;

        case 'grupo':
          if (selectedGroups != null && selectedGroups.isNotEmpty) {
            final groupIds = selectedGroups.map((g) => g.id).toList();
            targetStudentIds = await _getStudentIdsFromGroups(groupIds);
            destinatarios =
                'Grupos: ${selectedGroups.map((g) => g.grupo).join(', ')}';
          }
          break;

        case 'turno':
          if (selectedShift != null) {
            targetStudentIds = await _getStudentIdsFromShift(selectedShift.id);
            destinatarios = 'Turno: ${selectedShift.turno}';
          }
          break;

        case 'todos':
          targetStudentIds = await _getStudentIdsFromSchool(schoolId);
          destinatarios = 'Todos los estudiantes';
          break;
      }

      if (targetStudentIds.isEmpty) {
        return {
          'success': false,
          'error': 'No se encontraron estudiantes para enviar la notificación',
        };
      }

      // Create notifications for each student
      final List<Map<String, dynamic>> notifications = [];
      final List<String> notificationIds = [];

      for (String studentId in targetStudentIds) {
        final notificationData = {
          'id_alumno': studentId,
          'id_admin': adminId,
          'titulo': title,
          'mensaje': message,
          'tipo_notificacion':
              messageType == 'permiso' ? 'permisoEspecial' : 'comunicado',
          'estado': 'nueva',
          'fecha_registro': DateTime.now().toUtc().toIso8601String(),
        };

        // Add comunicado-specific fields
        if (messageType == 'comunicado') {
          notificationData['tipo_comunicado'] = comunicadoType?.name ?? '';
          notificationData['prioridad_comunicado'] = priority?.name ?? '';
          notificationData['destinatarios_comunicado'] = destinatarios;
        }

        notifications.add(notificationData);
      }

      // Insert all notifications in batch
      final response = await _supabase
          .from('notificaciones')
          .insert(notifications)
          .select('id');

      // Get the created notification IDs
      notificationIds.addAll(
        response.map<String>((record) => record['id']?.toString() ?? ''),
      );

      debugPrint('Created ${notificationIds.length} notifications');

      // Send push notifications based on recipient type
      try {
        List<String>? groupIds;
        if (selectedGroups != null) {
          groupIds = selectedGroups.map((g) => g.id).toList();
        }

        String? schoolIdForFCM;
        if (recipientType == 'todos') {
          schoolIdForFCM = schoolId;
        }

        await _fcmService.sendNotificationsByRecipientType(
          recipientType: recipientType,
          title: title,
          body: message,
          messageType: messageType,
          comunicadoType: comunicadoType?.name,
          priority: priority?.name,
          destinatarios: destinatarios,
          selectedStudent: selectedStudent,
          selectedGroupIds: groupIds,
          selectedShiftId: selectedShift?.id,
          schoolId: schoolIdForFCM,
          totalStudents: targetStudentIds.length,
        );
        debugPrint('FCM: Push notifications sent successfully');
      } catch (e) {
        debugPrint('FCM: Error sending push notifications: $e');
        // Don't fail the whole process if push notification fails
      }

      return {
        'success': true,
        'data': {
          'notifications_created': notificationIds.length,
          'notification_ids': notificationIds,
          'target_students': targetStudentIds.length,
          'destinatarios': destinatarios,
        },
      };
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return {
        'success': false,
        'error': 'Error interno al enviar la notificación: $e',
      };
    }
  }

  /// Get student IDs from specific groups
  Future<List<String>> _getStudentIdsFromGroups(List<String> groupIds) async {
    try {
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .inFilter('id_grupo', groupIds);

      return response.map<String>((record) => record['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from groups: $e');
      return [];
    }
  }

  /// Get student IDs from specific shift
  Future<List<String>> _getStudentIdsFromShift(String shiftId) async {
    try {
      final response =
          await _supabase.from('alumnos').select('id').eq('id_turno', shiftId);

      return response.map<String>((record) => record['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from shift: $e');
      return [];
    }
  }

  /// Get all student IDs from school
  Future<List<String>> _getStudentIdsFromSchool(String schoolId) async {
    try {
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', schoolId);

      return response.map<String>((record) => record['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from school: $e');
      return [];
    }
  }

  /// Get notification statistics for sent notifications
  Future<Map<String, dynamic>> getNotificationStats({
    required String adminId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final query = _supabase
          .from('notificaciones')
          .select('tipo_notificacion, estado')
          .eq('id_admin', adminId);

      if (startDate != null) {
        query.gte('fecha_registro', startDate);
      }
      if (endDate != null) {
        query.lte('fecha_registro', endDate);
      }

      final response = await query;

      int totalSent = response.length;
      int permisosEspeciales = response
          .where((n) => n['tipo_notificacion'] == 'permisoEspecial')
          .length;
      int comunicados =
          response.where((n) => n['tipo_notificacion'] == 'comunicado').length;
      int leidas = response.where((n) => n['estado'] == 'leida').length;

      int readRate = 0;
      if (totalSent > 0) {
        readRate = ((leidas / totalSent) * 100).round();
      }

      return {
        'success': true,
        'stats': {
          'total_sent': totalSent,
          'special_permissions': permisosEspeciales,
          'communications': comunicados,
          'read_notifications': leidas,
          'read_rate': readRate,
        },
      };
    } catch (e) {
      debugPrint('Error getting notification stats: $e');
      return {
        'success': false,
        'error': 'Error al obtener estadísticas: $e',
      };
    }
  }
}
