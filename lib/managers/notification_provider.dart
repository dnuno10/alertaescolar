import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/mock_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<Notificacion> _notifications = [];
  bool _isLoading = false;
  String? _error;
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Notificacion> get notifications => List.unmodifiable(_notifications);
  List<Notificacion> get unreadNotifications => _notifications
      .where((n) => n.estado == EstadoNotificacion.nueva)
      .toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => unreadNotifications.length;
  bool get hasNotifications => _notifications.isNotEmpty;

  // Keep mock service for backward compatibility
  final MockNotificationService _notificationService =
      MockNotificationService();

  // Load real notifications for current user's children
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current authenticated user
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // First, get the children IDs for this user
      final childrenResponse = await _supabase
          .from('alumno_tutores')
          .select('id_alumno')
          .eq('id_tutor', currentUser.id);

      if (childrenResponse.isEmpty) {
        _notifications = [];
        return;
      }

      final childrenIds = childrenResponse
          .map<String>((record) => record['id_alumno'] as String)
          .toList();

      // Then, fetch notifications for these children
      final response = await _supabase
          .from('notificaciones')
          .select('''
            *,
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
          ''')
          .inFilter('id_alumno', childrenIds)
          .order('fecha_registro', ascending: false);

      // Convert to our Notificacion model
      _notifications = _mapNotificationsFromDb(response);

      debugPrint('Loaded ${_notifications.length} notifications for user');
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _error = e.toString();

      // Fallback to mock data if error
      try {
        _notifications = await _notificationService.getNotifications();
      } catch (_) {
        // If even mock fails, keep empty list
        _notifications = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Map database response to Notificacion model
  List<Notificacion> _mapNotificationsFromDb(List<dynamic> data) {
    return data.map((record) {
      final fechaRegistro = DateTime.parse(record['fecha_registro']);
      final tipoNotificacion = record['tipo_notificacion'] ?? '';
      final estado = record['estado'] == 'leida'
          ? EstadoNotificacion.leida
          : EstadoNotificacion.nueva;

      // Additional data to include in datosAdicionales
      final Map<String, dynamic> additionalData = {
        'tipo_notificacion': tipoNotificacion,
        'id_alumno': record['id_alumno'],
        'id_admin': record['id_admin'],
        'tipo_comunicado': record['tipo_comunicado'],
        'prioridad_comunicado': record['prioridad_comunicado'],
        'destinatarios_comunicado': record['destinatarios_comunicado'],
        'alumno_nombre': record['alumnos']?['nombre'] ?? 'Estudiante',
        'alumno_grupo': record['alumnos']?['grupos']?['grupo'] ?? '',
        'alumno_nivel_educativo':
            record['alumnos']?['grupos']?['nivel_educativo'] ?? '',
      };

      return Notificacion(
        id: record['id'],
        alumnoId: record['id_alumno'],
        adminId: record['id_admin'],
        titulo: record['titulo'] ?? '',
        mensaje: record['mensaje'] ?? '',
        tipo: _mapTipoNotificacion(tipoNotificacion),
        estado: estado,
        fechaHora: fechaRegistro,
        datosAdicionales: additionalData,
      );
    }).toList();
  }

  // Map string tipo_notificacion to TipoNotificacion enum
  TipoNotificacion _mapTipoNotificacion(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return TipoNotificacion.entrada;
      case 'salida':
        return TipoNotificacion.salida;
      case 'retraso':
        return TipoNotificacion.retraso;
      case 'permisoespecial':
        return TipoNotificacion.permisoEspecial;
      case 'comunicado':
        return TipoNotificacion.comunicado;
      default:
        return TipoNotificacion
            .entrada; // Defaulting to entrada instead of otro
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Update the notification state in the database
      await _supabase
          .from('notificaciones')
          .update({'estado': 'leida'}).eq('id', notificationId);

      // Also update in the local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          estado: EstadoNotificacion.leida,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _error = e.toString();

      // Still update local state if database update fails
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          estado: EstadoNotificacion.leida,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Get current authenticated user
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // First, get the children IDs for this user
      final childrenResponse = await _supabase
          .from('alumno_tutores')
          .select('id_alumno')
          .eq('id_tutor', currentUser.id);

      if (childrenResponse.isNotEmpty) {
        final childrenIds = childrenResponse
            .map<String>((record) => record['id_alumno'] as String)
            .toList();

        // Update all unread notifications for these children
        await _supabase
            .from('notificaciones')
            .update({'estado': 'leida'})
            .inFilter('id_alumno', childrenIds)
            .eq('estado', 'nueva');
      }

      // Update local state
      _notifications = _notifications
          .map((n) => n.copyWith(estado: EstadoNotificacion.leida))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      _error = e.toString();

      // Still update local state if database update fails
      _notifications = _notifications
          .map((n) => n.copyWith(estado: EstadoNotificacion.leida))
          .toList();
      notifyListeners();
    }
  }

  List<Notificacion> getNotificationsByStudent(String studentId) {
    return _notifications.where((n) => n.alumnoId == studentId).toList();
  }

  List<Notificacion> getNotificationsByType(TipoNotificacion type) {
    return _notifications.where((n) => n.tipo == type).toList();
  }

  List<Notificacion> getRecentNotifications({int limit = 5}) {
    final sorted = List<Notificacion>.from(_notifications);
    sorted.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return sorted.take(limit).toList();
  }

  Notificacion? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByType(String type) {
    // En una aplicación real, esto podría filtrar desde el servicio
    // Por ahora, mantenemos la lista completa y filtramos en la UI
    notifyListeners();
  }

  void clearFilter() {
    // Recargar todas las notificaciones
    loadNotifications();
  }

  // Get notification statistics for a student within a period
  Map<String, int> getNotificationStatsByStudent(String studentId, int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final notifications = _notifications
        .where((n) =>
            n.alumnoId == studentId &&
            n.fechaHora.isAfter(startDate) &&
            n.fechaHora.isBefore(now))
        .toList();

    int entries = 0;
    int lateArrivals = 0;
    int exits = 0;

    for (var notification in notifications) {
      switch (notification.tipo) {
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
          // Skip other notification types
          break;
      }
    }

    // Calculate attendance rate based on school days
    // Assuming 5 school days per week
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

  // Get period comparison for attendance rate change
  double getAttendanceRateChange(String studentId, int days) {
    final now = DateTime.now();
    final currentPeriodStart = now.subtract(Duration(days: days));
    final previousPeriodStart =
        currentPeriodStart.subtract(Duration(days: days));

    // Current period stats
    final currentStats = getNotificationStatsByStudent(studentId, days);

    // Calculate previous period stats manually
    final previousPeriodNotifications = _notifications
        .where((n) =>
            n.alumnoId == studentId &&
            n.fechaHora.isAfter(previousPeriodStart) &&
            n.fechaHora.isBefore(currentPeriodStart))
        .toList();

    int previousEntries = 0;
    int previousLateArrivals = 0;

    for (var notification in previousPeriodNotifications) {
      if (notification.tipo == TipoNotificacion.entrada) {
        previousEntries++;
      } else if (notification.tipo == TipoNotificacion.retraso) {
        previousLateArrivals++;
      }
    }

    // Calculate previous attendance rate
    final schoolDays = (days / 7 * 5).ceil();
    final previousAttendanceCount = previousEntries + previousLateArrivals;
    final previousAttendanceRate = schoolDays > 0
        ? ((previousAttendanceCount / schoolDays) * 100).clamp(0, 100)
        : 0;

    // Calculate change
    return (currentStats['attendanceRate']! - previousAttendanceRate)
        .toDouble();
  }

  void clearAllData() {
    _notifications.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
