import '../models/models.dart';

class MockNotificationService {
  // Simular delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Lista de notificaciones mock
  static final List<Notificacion> _notifications = [
    Notificacion(
      id: 'notif_001',
      alumnoId: 'alumno_001',
      titulo: 'Entrada registrada',
      mensaje: 'Carlos Alberto ha llegado a la escuela a las 7:45 AM',
      tipo: TipoNotificacion.entrada,
      estado: EstadoNotificacion.nueva,
      fechaHora: DateTime.now().subtract(const Duration(minutes: 30)),
      datosAdicionales: {
        'hora': '07:45',
        'puerta': 'Principal',
      },
    ),
    Notificacion(
      id: 'notif_002',
      alumnoId: 'alumno_002',
      titulo: 'Llegada tardía',
      mensaje:
          'Ana Sofía llegó tarde a las 8:15 AM. Se ha notificado al maestro.',
      tipo: TipoNotificacion.retraso,
      estado: EstadoNotificacion.nueva,
      fechaHora: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      datosAdicionales: {
        'hora': '08:15',
        'retraso_minutos': 15,
      },
    ),
    Notificacion(
      id: 'notif_003',
      alumnoId: 'alumno_001',
      titulo: 'Salida registrada',
      mensaje: 'Carlos Alberto ha salido de la escuela a las 2:30 PM',
      tipo: TipoNotificacion.salida,
      estado: EstadoNotificacion.leida,
      fechaHora: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      datosAdicionales: {
        'hora': '14:30',
        'puerta': 'Principal',
      },
    ),
    Notificacion(
      id: 'notif_004',
      alumnoId: 'alumno_002',
      titulo: 'Permiso especial autorizado',
      mensaje:
          'Se ha autorizado la salida temprana de Ana Sofía a las 11:20 AM para cita médica.',
      tipo: TipoNotificacion.permisoEspecial,
      estado: EstadoNotificacion.leida,
      fechaHora: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      datosAdicionales: {
        'motivo': 'Cita médica',
        'autorizado_por': 'Directora María López',
        'hora_salida': '11:20',
      },
    ),
    Notificacion(
      id: 'notif_005',
      alumnoId: 'alumno_001',
      titulo: 'Comunicado importante',
      mensaje:
          'Reunión de padres de familia el viernes 15 de junio a las 6:00 PM en el aula magna.',
      tipo: TipoNotificacion.comunicado,
      estado: EstadoNotificacion.nueva,
      fechaHora: DateTime.now().subtract(const Duration(days: 1)),
      datosAdicionales: {
        'evento': 'Reunión de padres',
        'fecha': '2025-06-15',
        'hora': '18:00',
        'lugar': 'Aula magna',
      },
    ),
    Notificacion(
      id: 'notif_006',
      alumnoId: 'alumno_002',
      titulo: 'Ausencia registrada',
      mensaje:
          'Ana Sofía no asistió a clases hoy. Si fue planificado, favor de justificar.',
      tipo: TipoNotificacion.ausencia,
      estado: EstadoNotificacion.nueva,
      fechaHora: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      datosAdicionales: {
        'requiere_justificacion': true,
        'fecha_limite_justificacion':
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      },
    ),
  ];

  Future<List<Notificacion>> getNotifications() async {
    await _simulateNetworkDelay();
    return List.from(_notifications);
  }

  Future<List<Notificacion>> getNotificationsByStudent(String studentId) async {
    await _simulateNetworkDelay();
    return _notifications.where((n) => n.alumnoId == studentId).toList();
  }

  Future<List<Notificacion>> getUnreadNotifications() async {
    await _simulateNetworkDelay();
    return _notifications
        .where((n) => n.estado == EstadoNotificacion.nueva)
        .toList();
  }

  Future<Notificacion> markAsRead(String notificationId) async {
    await _simulateNetworkDelay();

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      throw Exception('Notificación no encontrada');
    }

    _notifications[index] = _notifications[index].copyWith(
      estado: EstadoNotificacion.leida,
    );

    return _notifications[index];
  }

  Future<void> markAllAsRead() async {
    await _simulateNetworkDelay();

    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].estado == EstadoNotificacion.nueva) {
        _notifications[i] = _notifications[i].copyWith(
          estado: EstadoNotificacion.leida,
        );
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _simulateNetworkDelay();

    _notifications.removeWhere((n) => n.id == notificationId);
  }

  Future<List<Notificacion>> getNotificationsByType(
      TipoNotificacion type) async {
    await _simulateNetworkDelay();
    return _notifications.where((n) => n.tipo == type).toList();
  }

  Future<List<Notificacion>> getNotificationsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    await _simulateNetworkDelay();

    return _notifications.where((n) {
      return n.fechaHora.isAfter(fromDate) && n.fechaHora.isBefore(toDate);
    }).toList();
  }

  // Simular la creación de una nueva notificación (para testing)
  Future<Notificacion> createNotification({
    required String alumnoId,
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    await _simulateNetworkDelay();

    final notification = Notificacion(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      alumnoId: alumnoId,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      estado: EstadoNotificacion.nueva,
      fechaHora: DateTime.now(),
      datosAdicionales: datosAdicionales,
    );

    _notifications.insert(0, notification); // Agregar al inicio
    return notification;
  }
}
