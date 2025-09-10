// lib/managers/notification_provider.dart
import 'dart:collection';
import 'package:alertaescolar/services/notification_send_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationSendService _sendService = NotificationSendService();

  List<Notificacion> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // --- Realtime ---
  final List<RealtimeChannel> _notiChannels = [];
  Set<String> _childrenIds = {};

  // Pequeño anti-duplicados (insert + update back-to-back)
  final Map<String, DateTime> _lastUpsertAt = HashMap();

  // Getters
  List<Notificacion> get notifications => List.unmodifiable(_notifications);
  List<Notificacion> get unreadNotifications => _notifications
      .where((n) => n.estado == EstadoNotificacion.nueva)
      .toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => unreadNotifications.length;
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Carga notificaciones para los hijos del usuario autenticado (tutor).
  Future<void> loadNotifications({int limit = 300}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Usuario no autenticado');

      // 1) Ids de alumnos vinculados a este tutor
      final childrenRows = await _supabase
          .from('alumno_tutores')
          .select('id_alumno')
          .eq('id_tutor', currentUser.id);

      _childrenIds = childrenRows
          .map<String>((r) => (r['id_alumno'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet();

      if (_childrenIds.isEmpty) {
        _notifications = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2) Notificaciones de esos alumnos (filtros ANTES de order/limit)
      var query = _supabase.from('notificaciones').select(r'''
  id,
  id_alumno,
  id_admin,
  titulo,
  mensaje,
  estado,
  fecha_registro,
  tipo_notificacion,
  tipo_comunicado,
  prioridad_comunicado,
  destinatarios_comunicado,
  alumnos:id_alumno (
    nombre,
    matricula,
    id_grupo,
    id_turno,
    grupos:id_grupo (
      grupo,
      nivel_educativo
    ),
    turnos:id_turno (
      turno
    )
  )
''');

      query = query.inFilter('id_alumno', _childrenIds.toList());

      List rows;
      try {
        rows =
            await query.order('fecha_registro', ascending: false).limit(limit);
      } catch (_) {
        rows = await query.limit(limit);
      }

      _notifications = _mapNotificationsFromDb(rows);
      _notifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ayudante para flujos donde cambian los hijos (vinculaciones).
  Future<void> reloadAndRefreshRealtime() async {
    await loadNotifications();
    await startRealtimeForCurrentUser();
  }

  /// Inicia suscripciones Realtime (por cada hijo, para filtrar en servidor).
  Future<void> startRealtimeForCurrentUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      // Asegura hijos cargados
      if (_childrenIds.isEmpty) {
        final rows = await _supabase
            .from('alumno_tutores')
            .select('id_alumno')
            .eq('id_tutor', currentUser.id);
        _childrenIds = rows
            .map<String>((r) => (r['id_alumno'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toSet();
      }

      // Limpia canales anteriores
      for (final ch in _notiChannels) {
        try {
          await _supabase.removeChannel(ch);
        } catch (_) {}
      }
      _notiChannels.clear();

      // Crea un canal por alumno para que el filtro ocurra en Postgres
      for (final childId in _childrenIds) {
        final ch = _supabase.channel('noti_alumno_$childId');

        ch.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notificaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_alumno',
            value: childId,
          ),
          callback: (payload) {
            final rec = payload.newRecord;
            _upsertFromRealtime(rec);
          },
        );

        ch.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notificaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_alumno',
            value: childId,
          ),
          callback: (payload) {
            final rec = payload.newRecord;
            _upsertFromRealtime(rec);
          },
        );

        ch.onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notificaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_alumno',
            value: childId,
          ),
          callback: (payload) {
            final oldRec = payload.oldRecord;
            final id = (oldRec['id'] ?? '').toString();
            if (id.isNotEmpty) {
              _notifications.removeWhere((n) => n.id == id);
              _notifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
              notifyListeners();
            }
          },
        );

        ch.subscribe();
        _notiChannels.add(ch);
      }
    } catch (e) {
      debugPrint('Error starting realtime notifications: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Inserta/actualiza un registro recibido por Realtime.
  Future<void> _upsertFromRealtime(Map<String, dynamic> rec) async {
    try {
      final id = (rec['id'] ?? '').toString();
      if (id.isEmpty) return;

      // Antiduplicado básico (250ms)
      final now = DateTime.now();
      final last = _lastUpsertAt[id];
      if (last != null && now.difference(last).inMilliseconds < 250) return;
      _lastUpsertAt[id] = now;

      final rows = await _supabase.from('notificaciones').select(r'''
  id,
  id_alumno,
  id_admin,
  titulo,
  mensaje,
  estado,
  fecha_registro,
  tipo_notificacion,
  tipo_comunicado,
  prioridad_comunicado,
  destinatarios_comunicado,
  alumnos:id_alumno (
    nombre,
    matricula,
    id_grupo,
    id_turno,
    grupos:id_grupo (
      grupo,
      nivel_educativo
    ),
    turnos:id_turno (
      turno
    )
  )
''').eq('id', id).limit(1);

      if (rows.isNotEmpty) {
        final mapped = _mapNotificationsFromDb(rows).first;
        final i = _notifications.indexWhere((n) => n.id == mapped.id);
        if (i == -1) {
          _notifications.insert(0, mapped);
        } else {
          _notifications[i] = mapped;
        }
        _notifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error upserting realtime notification: $e');
    }
  }

  /// Mapea filas de Supabase → modelo Notificacion (esquema actual).
  List<Notificacion> _mapNotificationsFromDb(List<dynamic> data) {
    return data.map<Notificacion>((record) {
      final fechaStr =
          (record['fecha_registro'] ?? record['created_at'] ?? '').toString();
      final fecha = DateTime.tryParse(fechaStr) ?? DateTime.now();

      final tipoDb = (record['tipo_notificacion'] ?? '').toString();
      final estadoDb = (record['estado'] ?? '').toString().toLowerCase();

      final alumnos = record['alumnos'] as Map<String, dynamic>?;
      final grupos = alumnos?['grupos'] as Map<String, dynamic>?;
      final turnos = alumnos?['turnos'] as Map<String, dynamic>?;

      final Map<String, dynamic> datosAd = <String, dynamic>{
        'alumno_nombre': alumnos?['nombre'] ?? '',
        'alumno_matricula': alumnos?['matricula'] ?? '',
        'alumno_grupo': grupos?['grupo'] ?? '',
        'alumno_nivel_educativo': grupos?['nivel_educativo'] ?? '',
        'alumno_turno': turnos?['turno'] ?? '',
        'tipo_comunicado': record['tipo_comunicado'],
        'prioridad_comunicado': record['prioridad_comunicado'],
        'destinatarios_comunicado': record['destinatarios_comunicado'],
      };

      return Notificacion(
        id: (record['id'] ?? '').toString(),
        alumnoId: (record['id_alumno'] ?? '').toString(),
        adminId: (record['id_admin'] ?? '').toString(),
        titulo: (record['titulo'] ?? '') as String,
        mensaje: (record['mensaje'] ?? '') as String,
        tipo: _mapTipoFromDb(tipoDb),
        estado: estadoDb == EstadoNotificacion.leida.name
            ? EstadoNotificacion.leida
            : EstadoNotificacion.nueva,
        fechaHora: fecha,
        datosAdicionales: datosAd,
      );
    }).toList();
  }

  TipoNotificacion _mapTipoFromDb(String rawTipo) {
    final tipo = rawTipo.trim().toLowerCase();
    switch (tipo) {
      case 'entrada':
        return TipoNotificacion.entrada;
      case 'salida':
        return TipoNotificacion.salida;
      case 'retraso':
        return TipoNotificacion.retraso;
      case 'ausencia':
        return TipoNotificacion.ausencia;
      case 'permisoespecial':
      case 'permiso_especial':
      case 'permiso-especial':
        return TipoNotificacion.permisoEspecial;
      case 'comunicado':
      default:
        return TipoNotificacion.comunicado;
    }
  }

  // ---------- Optimistic update instantáneo ----------
  void markLocalAsRead(String notificationId) {
    final i = _notifications.indexWhere((n) => n.id == notificationId);
    if (i == -1) return;
    if (_notifications[i].estado == EstadoNotificacion.leida) return;

    _notifications[i] =
        _notifications[i].copyWith(estado: EstadoNotificacion.leida);
    notifyListeners();
  }

  void markLocalAsUnread(String notificationId) {
    final i = _notifications.indexWhere((n) => n.id == notificationId);
    if (i == -1) return;
    if (_notifications[i].estado == EstadoNotificacion.nueva) return;

    _notifications[i] =
        _notifications[i].copyWith(estado: EstadoNotificacion.nueva);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notificaciones').update(
          {'estado': EstadoNotificacion.leida.name}).eq('id', notificationId);

      // Refuerza estado local
      markLocalAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _error = e.toString();
      // En errores, mantenemos la UI como leída para no "parpadear".
      // Si prefieres revertir, descomenta:
      // markLocalAsUnread(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Usuario no autenticado');

      final childrenRows = await _supabase
          .from('alumno_tutores')
          .select('id_alumno')
          .eq('id_tutor', currentUser.id);

      if (childrenRows.isNotEmpty) {
        final childrenIds = childrenRows
            .map<String>((r) => (r['id_alumno'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();

        await _supabase
            .from('notificaciones')
            .update({'estado': EstadoNotificacion.leida.name})
            .inFilter('id_alumno', childrenIds)
            .eq('estado', EstadoNotificacion.nueva.name);
      }

      _notifications = _notifications
          .map((n) => n.copyWith(estado: EstadoNotificacion.leida))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      _error = e.toString();
      _notifications = _notifications
          .map((n) => n.copyWith(estado: EstadoNotificacion.leida))
          .toList();
      notifyListeners();
    }
  }

  List<Notificacion> getNotificationsByStudent(String studentId) =>
      _notifications.where((n) => n.alumnoId == studentId).toList();

  List<Notificacion> getNotificationsByType(TipoNotificacion type) =>
      _notifications.where((n) => n.tipo == type).toList();

  List<Notificacion> getRecentNotifications({int limit = 5}) {
    final sorted = List<Notificacion>.from(_notifications)
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return sorted.take(limit).toList();
  }

  Notificacion? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _sendService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Map<String, int> getNotificationStatsByStudent(String studentId, int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final items = _notifications.where((n) {
      return n.alumnoId == studentId &&
          n.fechaHora.isAfter(startDate) &&
          n.fechaHora.isBefore(now);
    }).toList();

    int entries = 0, lateArrivals = 0, exits = 0;
    for (final n in items) {
      switch (n.tipo) {
        case TipoNotificacion.entrada:
          entries++;
          break;
        case TipoNotificacion.retraso:
          lateArrivals++;
          break;
        case TipoNotificacion.salida:
          exits++;
          break;
        default:
          break;
      }
    }

    final schoolDays = (days / 7 * 5).ceil();
    final attendanceCount = entries + lateArrivals;
    final attendanceRate = schoolDays > 0
        ? ((attendanceCount / schoolDays) * 100).clamp(0, 100).toInt()
        : 0;

    return {
      'entries': entries,
      'lateArrivals': lateArrivals,
      'exits': exits,
      'attendanceRate': attendanceRate,
      'schoolDays': schoolDays,
    };
  }

  double getAttendanceRateChange(String studentId, int days) {
    final now = DateTime.now();
    final currentStart = now.subtract(Duration(days: days));
    final previousStart = currentStart.subtract(Duration(days: days));

    final currentStats = getNotificationStatsByStudent(studentId, days);

    final prevItems = _notifications.where((n) {
      return n.alumnoId == studentId &&
          n.fechaHora.isAfter(previousStart) &&
          n.fechaHora.isBefore(currentStart);
    }).toList();

    int prevEntries = 0, prevLate = 0;
    for (final n in prevItems) {
      if (n.tipo == TipoNotificacion.entrada) prevEntries++;
      if (n.tipo == TipoNotificacion.retraso) prevLate++;
    }

    final schoolDays = (days / 7 * 5).ceil();
    final prevAttendanceCount = prevEntries + prevLate;
    final prevAttendanceRate = schoolDays > 0
        ? ((prevAttendanceCount / schoolDays) * 100).clamp(0, 100)
        : 0;

    return (currentStats['attendanceRate']! - prevAttendanceRate).toDouble();
  }

  void clearAllData() {
    _notifications.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final ch in _notiChannels) {
      try {
        _supabase.removeChannel(ch);
      } catch (_) {}
    }
    _notiChannels.clear();
    super.dispose();
  }
}
