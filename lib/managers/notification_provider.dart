import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<Notificacion> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notificacion> get notifications => List.unmodifiable(_notifications);
  List<Notificacion> get unreadNotifications => _notifications
      .where((n) => n.estado == EstadoNotificacion.nueva)
      .toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => unreadNotifications.length;
  bool get hasNotifications => _notifications.isNotEmpty;

  final MockNotificationService _notificationService =
      MockNotificationService();

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      // Ordenar por fecha más reciente primero
      _notifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          estado: EstadoNotificacion.leida,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(estado: EstadoNotificacion.leida))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
}
