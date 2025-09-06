// lib/services/notification_send_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart'; // Enums: TipoComunicacion, PrioridadComunicado, etc.
import '../models/notification_draft.dart';
import 'fcm_service.dart';

class NotificationSendService {
  NotificationSendService();

  static const int _kFcmBatchSize = 400;

  final SupabaseClient _sb = Supabase.instance.client;
  final FCMService _fcm = FCMService();

  /// Envío principal basado en Draft:
  /// - Resuelve destinatarios
  /// - Filtra alumnos activos (con tutor registrado)
  /// - Inserta en `notificaciones` (1 fila por alumno)
  /// - Fanout a tutores -> tokens -> FCM (por lotes)
  Future<Map<String, dynamic>> sendDraft({
    required NotificationDraft draft,
    required String adminId,
    required String escuelaId,
  }) async {
    try {
      // 1) Resolver alumnos destino
      final rawStudentIds = await _resolveTargetStudents(
        draft: draft,
        escuelaId: escuelaId,
      );

      // 2) Filtrar alumnos activos (con tutor registrado)
      final targetStudentIds = await _filterActiveStudents(rawStudentIds);

      if (targetStudentIds.isEmpty) {
        return {
          'success': false,
          'error':
              'No se encontraron alumnos activos (con tutor registrado) para el alcance seleccionado (${draft.tipoDestinatario}).',
        };
      }

      // 3) Preparar inserciones a `notificaciones`
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final tipoDb = _coerceTipoFromDraft(draft.tipoMensaje);

      final List<Map<String, dynamic>> rows = targetStudentIds.map((alId) {
        return {
          'id_alumno': alId,
          'id_admin': adminId,
          'id_escuela': escuelaId,
          'titulo': draft.titulo,
          'mensaje': draft.mensaje,
          'tipo':
              tipoDb, // entrada|salida|retraso|ausencia|permisoEspecial|comunicado
          'estado': 'nueva',
          'fecha_hora': nowIso,
          'datos_adicionales': {
            if (draft.tipoComunicado != null)
              'tipo_comunicacion': draft.tipoComunicado, // 'emergencia', etc.
            if (draft.prioridad != null)
              'prioridad': draft.prioridad, // 'baja'|'media'|'alta'|'critica'
            'destinatario': {
              'tipo': draft
                  .tipoDestinatario, // 'individual'|'grupo'|'turno'|'todos'
              'alumno_id': draft.alumnoId,
              'grupo_ids': draft.grupoIds,
              'turno_id': draft.turnoId,
            },
            'enviar_push': true,
          },
        };
      }).toList();

      // 4) Inserción batch
      final inserted =
          await _sb.from('notificaciones').insert(rows).select('id');
      final notificationIds = inserted
          .map<String>((r) => (r['id'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();

      // 5) Fanout a tutores -> tokens -> FCM
      final tutorIds = await _getTutorIdsFromStudents(targetStudentIds);
      final tokens = await _getTokensFromUserIds(tutorIds);

      int pushes = 0;
      if (tokens.isNotEmpty) {
        final data = {
          'tipo': tipoDb,
          'titulo': draft.titulo,
          'mensaje': draft.mensaje,
          'id_escuela': escuelaId,
          if (draft.tipoComunicado != null)
            'tipo_comunicacion': draft.tipoComunicado,
          if (draft.prioridad != null) 'prioridad': draft.prioridad,
        };

        pushes = await _pushInBatches(
          tokens: tokens,
          title: draft.titulo,
          body: draft.mensaje,
          data: data,
          batchSize: _kFcmBatchSize,
        );
      }

      return {
        'success': true,
        'data': {
          'notifications_created': notificationIds.length,
          'notification_ids': notificationIds,
          'target_students': targetStudentIds.length,
          'target_tutors': tutorIds.length,
          'device_tokens': tokens.length,
          'pushes_sent': pushes,
        },
      };
    } catch (e) {
      debugPrint('sendDraft error: $e');
      return {
        'success': false,
        'error': 'Error interno al enviar: $e',
      };
    }
  }

  /// Compatibilidad con firmas antiguas. Construye un Draft y delega a sendDraft.
  @deprecated
  Future<Map<String, dynamic>> sendNotification({
    required String adminId,
    required String schoolId,
    required String messageType, // 'permiso' | 'comunicado' | 'entrada' | ...
    required String recipientType, // 'individual' | 'grupo' | 'turno' | 'todos'
    required String title,
    required String message,
    TipoComunicacion? communicationType,
    PrioridadComunicado? priority,
    Map<String, dynamic>? selectedStudent, // { 'id': ... }
    List<Grupo>? selectedGroups,
    Turno? selectedShift,
  }) async {
    final draft = NotificationDraft(
      tipoMensaje: messageType,
      tipoDestinatario: recipientType,
      titulo: title,
      mensaje: message,
      tipoComunicado: communicationType == null
          ? null
          : _tipoComunicacionDb(communicationType),
      prioridad: priority == null ? null : _prioridadDb(priority),
      alumnoId: recipientType == 'individual'
          ? (selectedStudent?['id']?.toString())
          : null,
      grupoIds: recipientType == 'grupo'
          ? (selectedGroups ?? []).map((g) => g.id).toList()
          : null,
      turnoId: recipientType == 'turno' ? selectedShift?.id : null,
    );

    return sendDraft(draft: draft, adminId: adminId, escuelaId: schoolId);
  }

  // =========================================================
  //                 Lectura / Borrado (esquema actual)
  // =========================================================

  /// Lee notificaciones con el esquema actual (tipo / fecha_hora / datos_adicionales).
  /// Puedes filtrar por escuela o por alumno si lo necesitas.
  Future<List<Notificacion>> getNotifications({
    String? escuelaId,
    String? alumnoId,
    int limit = 200,
  }) async {
    try {
      var query = _sb.from('notificaciones').select("""
  id,
  id_alumno,
  id_admin,
  id_escuela,
  titulo,
  mensaje,
  tipo,
  estado,
  fecha_hora,
  datos_adicionales
""");

// 1) Aplica filtros ANTES de order/limit
      if (escuelaId != null && escuelaId.isNotEmpty) {
        query = query.eq('id_escuela', escuelaId);
      }
      if (alumnoId != null && alumnoId.isNotEmpty) {
        query = query.eq('id_alumno', alumnoId);
      }

// 2) Ahora sí, ordena y limita
      final rows =
          await query.order('fecha_hora', ascending: false).limit(limit);

      return (rows as List).map((r) {
        return Notificacion(
          id: (r['id'] ?? '').toString(),
          alumnoId: (r['id_alumno'] ?? '').toString(),
          adminId: (r['id_admin'] ?? '').toString(),
          titulo: (r['titulo'] ?? '') as String,
          mensaje: (r['mensaje'] ?? '') as String,
          tipo: _mapTipoNotificacionDb((r['tipo'] ?? '').toString()),
          estado: ((r['estado'] ?? '').toString().toLowerCase() ==
                  EstadoNotificacion.leida.name)
              ? EstadoNotificacion.leida
              : EstadoNotificacion.nueva,
          fechaHora: DateTime.tryParse((r['fecha_hora'] ?? '').toString()) ??
              DateTime.now(),
          datosAdicionales: (r['datos_adicionales'] is Map
              ? Map<String, dynamic>.from(r['datos_adicionales'])
              : null),
          // Si tu modelo Notificacion tiene escuelaId, puedes añadirlo también:
          // escuelaId: (r['id_escuela'] ?? '').toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('getNotifications error: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final res =
          await _sb.from('notificaciones').delete().eq('id', notificationId);
      // Supabase retorna lista de filas afectadas o vacío según config
      if (res == null) {
        throw Exception('Respuesta nula al eliminar.');
      }
    } catch (e) {
      debugPrint('deleteNotification error: $e');
      rethrow;
    }
  }

  // =========================================================
  //                RESOLUCIÓN DE DESTINATARIOS
  // =========================================================

  Future<List<String>> _resolveTargetStudents({
    required NotificationDraft draft,
    required String escuelaId,
  }) async {
    switch (draft.tipoDestinatario) {
      case 'individual':
        if ((draft.alumnoId ?? '').isEmpty) return [];
        // Verificamos que pertenezca a la escuela (seguridad extra)
        final ok = await _belongToSchool(draft.alumnoId!, escuelaId);
        return ok ? [draft.alumnoId!] : [];

      case 'grupo':
        final groupIds =
            (draft.grupoIds ?? []).where((e) => e.isNotEmpty).toList();
        if (groupIds.isEmpty) return [];
        return _getStudentIdsFromGroups(groupIds, escuelaId);

      case 'turno':
        if ((draft.turnoId ?? '').isEmpty) return [];
        return _getStudentIdsFromShift(draft.turnoId!, escuelaId);

      case 'todos':
        return _getStudentIdsFromSchool(escuelaId);

      default:
        return [];
    }
  }

  Future<bool> _belongToSchool(String alumnoId, String escuelaId) async {
    try {
      final row = await _sb
          .from('alumnos')
          .select('id')
          .eq('id', alumnoId)
          .eq('id_escuela', escuelaId)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> _getStudentIdsFromGroups(
      List<String> groupIds, String escuelaId) async {
    try {
      final rows = await _sb
          .from('alumnos')
          .select('id')
          .eq('id_escuela', escuelaId)
          .inFilter('id_grupo', groupIds);

      return rows.map<String>((r) => (r['id'] ?? '').toString()).toList();
    } catch (e) {
      debugPrint('_getStudentIdsFromGroups error: $e');
      return [];
    }
  }

  Future<List<String>> _getStudentIdsFromShift(
      String shiftId, String escuelaId) async {
    try {
      final rows = await _sb
          .from('alumnos')
          .select('id')
          .eq('id_escuela', escuelaId)
          .eq('id_turno', shiftId);

      return rows.map<String>((r) => (r['id'] ?? '').toString()).toList();
    } catch (e) {
      debugPrint('_getStudentIdsFromShift error: $e');
      return [];
    }
  }

  Future<List<String>> _getStudentIdsFromSchool(String escuelaId) async {
    try {
      final rows =
          await _sb.from('alumnos').select('id').eq('id_escuela', escuelaId);
      return rows.map<String>((r) => (r['id'] ?? '').toString()).toList();
    } catch (e) {
      debugPrint('_getStudentIdsFromSchool error: $e');
      return [];
    }
  }

  /// Filtra estudiantes que están registrados por tutores (activos en el sistema)
  Future<List<String>> _filterActiveStudents(List<String> studentIds) async {
    try {
      if (studentIds.isEmpty) return [];

      final rows = await _sb
          .from('alumno_tutores')
          .select('id_alumno')
          .inFilter('id_alumno', studentIds);

      final active = <String>{};
      for (final r in rows) {
        final v = (r['id_alumno'] ?? '').toString();
        if (v.isNotEmpty) active.add(v);
      }
      return active.toList();
    } catch (e) {
      debugPrint('_filterActiveStudents error: $e');
      return [];
    }
  }

  /// alumno_tutores: id_alumno -> id_tutor (puede haber múltiples)
  Future<List<String>> _getTutorIdsFromStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    try {
      final rows = await _sb
          .from('alumno_tutores')
          .select('id_tutor')
          .inFilter('id_alumno', studentIds);

      final ids = <String>{};
      for (final r in rows) {
        final v = (r['id_tutor'] ?? '').toString();
        if (v.isNotEmpty) ids.add(v);
      }
      return ids.toList();
    } catch (e) {
      debugPrint('_getTutorIdsFromStudents error: $e');
      return [];
    }
  }

  /// mobile_tokens: id_usuario -> token (1..n por usuario)
  Future<List<String>> _getTokensFromUserIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    try {
      final rows = await _sb
          .from('mobile_tokens')
          .select('token, id_usuario')
          .inFilter('id_usuario', userIds);

      final tokens = <String>{};
      for (final r in rows) {
        final t = (r['token'] ?? '').toString().trim();
        if (t.isNotEmpty) tokens.add(t);
      }
      return tokens.toList();
    } catch (e) {
      debugPrint('_getTokensFromUserIds error: $e');
      return [];
    }
  }

  // =========================================================
  //                        PUSH
  // =========================================================

  /// Envía en lotes (para evitar límites); retorna el total de tokens notificados.
  Future<int> _pushInBatches({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int batchSize = _kFcmBatchSize,
  }) async {
    if (tokens.isEmpty) return 0;

    int sent = 0;
    final total = tokens.length;

    for (int i = 0; i < total; i += batchSize) {
      final end = min(i + batchSize, total);
      final slice = tokens.sublist(i, end);

      try {
        await _fcm.sendToTokens(
          tokens: slice,
          title: title,
          body: body,
          data: data ?? const {},
        );
        sent += slice.length;
      } catch (e) {
        debugPrint('FCM batch error ($i..$end): $e');
        // Continuamos con el resto; no abortar todo el envío por un lote.
      }
    }
    return sent;
  }

  // =========================================================
  //            Helpers de normalización / mapeos
  // =========================================================

  String _coerceTipoFromDraft(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'permiso' || s == 'permiso_especial' || s == 'permisoespecial') {
      return 'permisoEspecial';
    }
    if (s == 'comunicado') return 'comunicado';
    if (s == 'entrada') return 'entrada';
    if (s == 'salida') return 'salida';
    if (s == 'retraso') return 'retraso';
    if (s == 'ausencia') return 'ausencia';
    // Fallback conservador
    return 'comunicado';
  }

  String _tipoComunicacionDb(TipoComunicacion v) {
    switch (v) {
      case TipoComunicacion.emergencia:
        return 'emergencia';
      case TipoComunicacion.paseo:
        return 'paseo';
      case TipoComunicacion.evento:
        return 'evento';
      case TipoComunicacion.recordatorioPago:
        return 'recordatorio_pago';
      case TipoComunicacion.citatorio:
        return 'citatorio';
      case TipoComunicacion.informativo:
        return 'informativo';
      case TipoComunicacion.celebracion:
        return 'celebracion';
      case TipoComunicacion.suspencionClases:
        return 'suspension_clases';
      case TipoComunicacion.cambioHorario:
        return 'cambio_horario';
    }
  }

  String _prioridadDb(PrioridadComunicado v) {
    switch (v) {
      case PrioridadComunicado.baja:
        return 'baja';
      case PrioridadComunicado.media:
        return 'media';
      case PrioridadComunicado.alta:
        return 'alta';
      case PrioridadComunicado.critica:
        return 'critica';
    }
  }

  TipoNotificacion _mapTipoNotificacionDb(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return TipoNotificacion.entrada;
      case 'salida':
        return TipoNotificacion.salida;
      case 'retraso':
        return TipoNotificacion.retraso;
      case 'ausencia':
        return TipoNotificacion.ausencia;
      case 'permisoespecial':
        return TipoNotificacion.permisoEspecial;
      case 'comunicado':
        return TipoNotificacion.comunicado;
      default:
        // Si aparece un valor inesperado en DB, cae a 'comunicado' por seguridad.
        return TipoNotificacion.comunicado;
    }
  }
}
