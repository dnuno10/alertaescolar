import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notificacion.dart'; // <- usamos tu modelo de notificación
import '../models/grupo.dart';
import '../models/turno.dart';
import 'fcm_service.dart';

class NotificationSendService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FCMService _fcmService = FCMService();

  /// Envía notificaciones según el tipo de destinatario
  ///
  /// [messageType] debe mapearse a `TipoNotificacion`:
  ///   'entrada' | 'salida' | 'retraso' | 'ausencia' | 'permisoEspecial' | 'comunicado'
  ///
  /// Si [messageType] == 'comunicado' puedes pasar [communicationType] y [priority].
  Future<Map<String, dynamic>> sendNotification({
    required String adminId,
    required String schoolId,
    required String messageType,
    required String recipientType, // 'individual' | 'grupo' | 'turno' | 'todos'
    required String title,
    required String message,
    TipoComunicacion? communicationType, // <- reemplaza a TipoComunicado
    PrioridadComunicado? priority,
    Map<String, dynamic>? selectedStudent, // { id: ..., name: ... }
    List<Grupo>? selectedGroups,
    Turno? selectedShift,
  }) async {
    try {
      debugPrint('Sending notification: $messageType to $recipientType');

      // 1) Resolver destinatarios (ids de alumnos)
      List<String> targetStudentIds = [];
      String destinatarios = '';

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

      // 2) Preparar batch de inserción en 'notificaciones'
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final List<Map<String, dynamic>> notifications = [];
      final List<String> notificationIds = [];

      // Normaliza messageType a enum.name válido
      final tipoString = _coerceTipoName(messageType);
      for (final studentId in targetStudentIds) {
        final notificationData = <String, dynamic>{
          'id_alumno': studentId,
          'id_admin': adminId,
          'titulo': title,
          'mensaje': message,
          // Campo correcto según tu modelo/tabla:
          'tipo': tipoString,
          'estado': EstadoNotificacion.nueva.name,
          // Fecha correcta según tu modelo:
          'fecha_hora': nowIso,
          // Extras para tipo "comunicado" dentro de NOTIFICACIONES (si aplica)
          if (tipoString == TipoNotificacion.comunicado.name)
            'tipo_comunicacion': communicationType?.name ?? '',
          if (tipoString == TipoNotificacion.comunicado.name)
            'prioridad_comunicado': priority?.name ?? '',
          if (tipoString == TipoNotificacion.comunicado.name)
            'destinatarios_comunicado': destinatarios,
          // Puedes incluir id_escuela si tu tabla lo guarda en notificaciones:
          // 'id_escuela': schoolId,
        };

        notifications.add(notificationData);
      }

      // 3) Insert batch
      final response = await _supabase
          .from('notificaciones')
          .insert(notifications)
          .select('id');

      notificationIds.addAll(
        response.map<String>((r) => r['id']?.toString() ?? ''),
      );
      debugPrint('Created ${notificationIds.length} notifications');

      // 4) Push por FCM (no romper la firma existente)
      try {
        List<String>? groupIds;
        if (selectedGroups != null && selectedGroups.isNotEmpty) {
          groupIds = selectedGroups.map((g) => g.id).toList();
        }
        String? schoolIdForFCM = recipientType == 'todos' ? schoolId : null;

        await _fcmService.sendNotificationsByRecipientType(
          recipientType: recipientType,
          title: title,
          body: message,
          messageType: tipoString, // pasamos el enum.name final
          // mantenemos el nombre del parámetro para no romper FCMService
          comunicadoType: communicationType?.name,
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
        // No romper el flujo si FCM falla
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

  // ---------- Helpers de obtención de alumnos ----------
  Future<List<String>> _getStudentIdsFromGroups(List<String> groupIds) async {
    try {
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .inFilter('id_grupo', groupIds);

      return response.map<String>((r) => r['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from groups: $e');
      return [];
    }
  }

  Future<List<String>> _getStudentIdsFromShift(String shiftId) async {
    try {
      final response =
          await _supabase.from('alumnos').select('id').eq('id_turno', shiftId);

      return response.map<String>((r) => r['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from shift: $e');
      return [];
    }
  }

  Future<List<String>> _getStudentIdsFromSchool(String schoolId) async {
    try {
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', schoolId);

      return response.map<String>((r) => r['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting students from school: $e');
      return [];
    }
  }

  /// Estadísticas de notificaciones enviadas por un admin
  Future<Map<String, dynamic>> getNotificationStats({
    required String adminId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final query = _supabase
          .from('notificaciones')
          // columnas correctas según tu modelo/tabla
          .select('tipo, estado, fecha_hora')
          .eq('id_admin', adminId);

      if (startDate != null) {
        query.gte('fecha_hora', startDate); // <- antes era fecha_registro
      }
      if (endDate != null) {
        query.lte('fecha_hora', endDate);
      }

      final response = await query;

      final totalSent = response.length;
      final permisosEspeciales =
          response.where((n) => n['tipo'] == 'permisoEspecial').length;
      final comunicados =
          response.where((n) => n['tipo'] == 'comunicado').length;
      final leidas = response.where((n) => n['estado'] == 'leida').length;

      final readRate = totalSent > 0 ? ((leidas / totalSent) * 100).round() : 0;

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

  // ---------- Normalización del tipo ----------
  /// Acepta valores de UI como 'permiso', 'permisoEspecial', 'comunicado', etc.
  /// y devuelve exactamente el `.name` de `TipoNotificacion`.
  String _coerceTipoName(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'permiso' || s == 'permisoespecial') {
      return TipoNotificacion.permisoEspecial.name;
    }
    if (s == 'entrada') return TipoNotificacion.entrada.name;
    if (s == 'salida') return TipoNotificacion.salida.name;
    if (s == 'retraso') return TipoNotificacion.retraso.name;
    if (s == 'ausencia') return TipoNotificacion.ausencia.name;
    if (s == 'comunicado') return TipoNotificacion.comunicado.name;
    // fallback seguro
    return TipoNotificacion.entrada.name;
  }
}
