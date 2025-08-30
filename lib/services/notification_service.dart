import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notificacion.dart';
import '../models/comunicado.dart' as comunicado_model;

class NotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Envía notificaciones basadas en el tipo de destinatario seleccionado
  static Future<Map<String, dynamic>> sendNotifications({
    required String adminId,
    required String escuelaId,
    required String titulo,
    required String mensaje,
    required String tipoMensaje, // 'permiso' o 'comunicado'
    required String tipoDestinatario, // 'individual', 'grupo', 'turno', 'todos'

    // Para destinatario individual
    String? studentId,

    // Para destinatarios múltiples (grupos)
    List<String>? groupIds,

    // Para destinatario por turno
    String? turnoId,

    // Para comunicados
    comunicado_model.TipoComunicado? tipoComunicado,
    comunicado_model.PrioridadComunicado? prioridadComunicado,
  }) async {
    try {
      debugPrint('Starting notification sending process...');
      debugPrint('Tipo: $tipoMensaje, Destinatario: $tipoDestinatario');

      // Determinar el tipo de notificación
      TipoNotificacion tipoNotificacion;
      if (tipoMensaje == 'permiso') {
        tipoNotificacion = TipoNotificacion.permisoEspecial;
      } else if (tipoMensaje == 'comunicado') {
        tipoNotificacion = TipoNotificacion.comunicado;
      } else {
        throw Exception('Tipo de mensaje no válido: $tipoMensaje');
      }

      // Obtener la lista de estudiantes destinatarios
      List<String> studentIds = [];

      switch (tipoDestinatario) {
        case 'individual':
          if (studentId == null) {
            throw Exception(
                'Se requiere ID de estudiante para destinatario individual');
          }
          // Validar que el estudiante individual esté activo (registrado por tutor)
          final activeStudentIds = await _filterActiveStudents([studentId]);
          if (activeStudentIds.isEmpty) {
            throw Exception(
                'El estudiante seleccionado no ha sido registrado por un familiar');
          }
          studentIds = activeStudentIds;
          break;

        case 'grupo':
          if (groupIds == null || groupIds.isEmpty) {
            throw Exception(
                'Se requieren IDs de grupos para destinatario por grupo');
          }
          studentIds = await _getStudentsByGroups(groupIds, escuelaId);
          break;

        case 'turno':
          if (turnoId == null) {
            throw Exception(
                'Se requiere ID de turno para destinatario por turno');
          }
          studentIds = await _getStudentsByTurno(turnoId, escuelaId);
          break;

        case 'todos':
          studentIds = await _getAllStudents(escuelaId);
          break;

        default:
          throw Exception('Tipo de destinatario no válido: $tipoDestinatario');
      }

      if (studentIds.isEmpty) {
        String message;
        switch (tipoDestinatario) {
          case 'individual':
            message =
                'El estudiante seleccionado no ha sido registrado por un familiar';
            break;
          case 'grupo':
            message =
                'No se encontraron estudiantes activos en los grupos seleccionados. Los estudiantes deben ser registrados por un familiar para recibir notificaciones.';
            break;
          case 'turno':
            message =
                'No se encontraron estudiantes activos en el turno seleccionado. Los estudiantes deben ser registrados por un familiar para recibir notificaciones.';
            break;
          case 'todos':
            message =
                'No se encontraron estudiantes activos en la escuela. Los estudiantes deben ser registrados por un familiar para recibir notificaciones.';
            break;
          default:
            message =
                'No se encontraron estudiantes activos para enviar la notificación';
        }

        return {
          'success': false,
          'message': message,
          'notificationsSent': 0,
        };
      }

      debugPrint('Enviando notificaciones a ${studentIds.length} estudiantes');

      // Crear notificaciones para cada estudiante
      int notificationsSent = 0;
      List<String> errors = [];

      for (String alumnoId in studentIds) {
        try {
          await _createNotification(
            alumnoId: alumnoId,
            adminId: adminId,
            titulo: titulo,
            mensaje: mensaje,
            tipo: tipoNotificacion,
            tipoComunicacion: _convertTipoComunicado(tipoComunicado),
            prioridadComunicado:
                _convertPrioridadComunicado(prioridadComunicado),
          );
          notificationsSent++;
        } catch (e) {
          errors.add('Error enviando a alumno $alumnoId: $e');
          debugPrint('Error enviando notificación a alumno $alumnoId: $e');
        }
      }

      if (errors.isNotEmpty && notificationsSent == 0) {
        return {
          'success': false,
          'message': 'No se pudo enviar ninguna notificación',
          'errors': errors,
          'notificationsSent': 0,
        };
      }

      String tipoMensajeText =
          tipoMensaje == 'permiso' ? 'Permiso especial' : 'Comunicado';
      String destinatarioText =
          _getDestinatarioText(tipoDestinatario, studentIds.length);

      String message =
          '$tipoMensajeText enviado exitosamente a $destinatarioText ($notificationsSent ${notificationsSent == 1 ? 'estudiante' : 'estudiantes'})';

      if (errors.isNotEmpty) {
        message +=
            ' • ${errors.length} ${errors.length == 1 ? 'error' : 'errores'}';
      }

      return {
        'success': true,
        'message': message,
        'notificationsSent': notificationsSent,
        'errors': errors,
        'tipoMensaje': tipoMensajeText,
        'destinatarioText': destinatarioText,
      };
    } catch (e) {
      debugPrint('Error en sendNotifications: $e');
      return {
        'success': false,
        'message': 'Error al enviar notificaciones: $e',
        'notificationsSent': 0,
      };
    }
  }

  Future<List<Notificacion>> getNotifications() async {
    try {
      // Obtener las notificaciones desde la base de datos
      final response = await _supabase
          .from('notificaciones')
          .select('*')
          .order('fecha_registro', ascending: false);

      // Mapear los datos obtenidos a la lista de objetos Notificacion
      return (response as List).map((record) {
        return Notificacion(
          id: record['id'],
          alumnoId: record['id_alumno'],
          adminId: record['id_admin'],
          titulo: record['titulo'] ?? '',
          mensaje: record['mensaje'] ?? '',
          tipo: _mapTipoNotificacion(record['tipo_notificacion']),
          estado: record['estado'] == EstadoNotificacion.leida.name
              ? EstadoNotificacion.leida
              : EstadoNotificacion.nueva,
          fechaHora: DateTime.parse(record['fecha_registro']),
          datosAdicionales: record['datos_adicionales'] ?? {},
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener notificaciones: $e');
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // Eliminar la notificación de la base de datos
      final response = await _supabase
          .from('notificaciones')
          .delete()
          .eq('id', notificationId);

      if (response == null || response.isEmpty) {
        throw Exception(
            'No se encontró la notificación con el ID proporcionado.');
      }

      debugPrint('Notificación con ID $notificationId eliminada exitosamente.');
    } catch (e) {
      debugPrint(
          'Error al eliminar la notificación con ID $notificationId: $e');
      throw Exception('Error al eliminar la notificación: $e');
    }
  }

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
        throw Exception('Tipo de notificación desconocido: $tipo');
    }
  }

  /// Obtiene los IDs de estudiantes por grupos
  static Future<List<String>> _getStudentsByGroups(
      List<String> groupIds, String escuelaId) async {
    try {
      // Obtener estudiantes que pertenecen a los grupos seleccionados
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', escuelaId)
          .inFilter('id_grupo', groupIds);

      final studentIds =
          (response as List).map((item) => item['id'] as String).toList();

      // Filtrar solo estudiantes que están registrados por tutores (activos)
      final activeStudentIds = await _filterActiveStudents(studentIds);

      debugPrint('Estudiantes encontrados en grupos: ${studentIds.length}');
      debugPrint('Estudiantes activos (con tutor): ${activeStudentIds.length}');

      return activeStudentIds;
    } catch (e) {
      debugPrint('Error obteniendo estudiantes por grupos: $e');
      throw Exception('Error al obtener estudiantes por grupos: $e');
    }
  }

  /// Obtiene los IDs de estudiantes por turno
  static Future<List<String>> _getStudentsByTurno(
      String turnoId, String escuelaId) async {
    try {
      // Obtener estudiantes que pertenecen al turno seleccionado
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', escuelaId)
          .eq('id_turno', turnoId);

      final studentIds =
          (response as List).map((item) => item['id'] as String).toList();

      // Filtrar solo estudiantes que están registrados por tutores (activos)
      final activeStudentIds = await _filterActiveStudents(studentIds);

      debugPrint('Estudiantes encontrados en turno: ${studentIds.length}');
      debugPrint('Estudiantes activos (con tutor): ${activeStudentIds.length}');

      return activeStudentIds;
    } catch (e) {
      debugPrint('Error obteniendo estudiantes por turno: $e');
      throw Exception('Error al obtener estudiantes por turno: $e');
    }
  }

  /// Obtiene todos los estudiantes de una escuela
  static Future<List<String>> _getAllStudents(String escuelaId) async {
    try {
      // Obtener todos los estudiantes de la escuela
      final response = await _supabase
          .from('alumnos')
          .select('id')
          .eq('id_escuela', escuelaId);

      final studentIds =
          (response as List).map((item) => item['id'] as String).toList();

      // Filtrar solo estudiantes que están registrados por tutores (activos)
      final activeStudentIds = await _filterActiveStudents(studentIds);

      debugPrint('Estudiantes encontrados en escuela: ${studentIds.length}');
      debugPrint('Estudiantes activos (con tutor): ${activeStudentIds.length}');

      return activeStudentIds;
    } catch (e) {
      debugPrint('Error obteniendo todos los estudiantes: $e');
      throw Exception('Error al obtener todos los estudiantes: $e');
    }
  }

  /// Crea una notificación individual en la base de datos
  static Future<void> _createNotification({
    required String alumnoId,
    required String adminId,
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    TipoComunicacion? tipoComunicacion,
    PrioridadComunicado? prioridadComunicado,
  }) async {
    try {
      final notificationData = {
        'id_alumno': alumnoId,
        'id_admin': adminId,
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo_notificacion': tipo.name,
        'estado': EstadoNotificacion.nueva.name,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      // Agregar campos específicos para comunicados
      if (tipo == TipoNotificacion.comunicado) {
        if (tipoComunicacion != null) {
          notificationData['tipo_comunicado'] = tipoComunicacion.name;
        }
        if (prioridadComunicado != null) {
          notificationData['prioridad_comunicado'] = prioridadComunicado.name;
        }
      }

      await _supabase.from('notificaciones').insert(notificationData);

      debugPrint('Notificación creada para alumno: $alumnoId');
    } catch (e) {
      debugPrint('Error creando notificación para alumno $alumnoId: $e');
      throw Exception('Error al crear notificación: $e');
    }
  }

  /// Convierte TipoComunicado enum a TipoComunicacion enum
  static TipoComunicacion? _convertTipoComunicado(
      comunicado_model.TipoComunicado? tipoComunicado) {
    if (tipoComunicado == null) return null;

    switch (tipoComunicado) {
      case comunicado_model.TipoComunicado.emergencia:
        return TipoComunicacion.emergencia;
      case comunicado_model.TipoComunicado.paseo:
        return TipoComunicacion.paseo;
      case comunicado_model.TipoComunicado.evento:
        return TipoComunicacion.evento;
      case comunicado_model.TipoComunicado.recordatorioPago:
        return TipoComunicacion.recordatorioPago;
      case comunicado_model.TipoComunicado.citatorio:
        return TipoComunicacion.citatorio;
      case comunicado_model.TipoComunicado.informativo:
        return TipoComunicacion.informativo;
      case comunicado_model.TipoComunicado.celebracion:
        return TipoComunicacion.celebracion;
      case comunicado_model.TipoComunicado.suspencionClases:
        return TipoComunicacion.suspencionClases;
      case comunicado_model.TipoComunicado.cambioHorario:
        return TipoComunicacion.cambioHorario;
    }
  }

  /// Convierte PrioridadComunicado enum del modelo comunicado al modelo notificación
  static PrioridadComunicado? _convertPrioridadComunicado(
      comunicado_model.PrioridadComunicado? prioridad) {
    if (prioridad == null) return null;

    switch (prioridad) {
      case comunicado_model.PrioridadComunicado.baja:
        return PrioridadComunicado.baja;
      case comunicado_model.PrioridadComunicado.media:
        return PrioridadComunicado.media;
      case comunicado_model.PrioridadComunicado.alta:
        return PrioridadComunicado.alta;
      case comunicado_model.PrioridadComunicado.critica:
        return PrioridadComunicado.critica;
    }
  }

  /// Genera texto descriptivo del destinatario basado en el tipo
  static String _getDestinatarioText(
      String tipoDestinatario, int cantidadEstudiantes) {
    switch (tipoDestinatario) {
      case 'individual':
        return 'estudiante seleccionado';
      case 'grupo':
        return cantidadEstudiantes == 1
            ? '1 grupo seleccionado'
            : 'grupos seleccionados';
      case 'turno':
        return 'turno seleccionado';
      case 'todos':
        return 'todos los estudiantes';
      default:
        return 'destinatarios seleccionados';
    }
  }

  /// Filtra estudiantes que están registrados por tutores (activos en el sistema)
  static Future<List<String>> _filterActiveStudents(
      List<String> studentIds) async {
    try {
      if (studentIds.isEmpty) {
        return [];
      }

      debugPrint(
          'Filtrando ${studentIds.length} estudiantes para verificar registro por tutores...');

      // Obtener estudiantes que tienen registro en alumno_tutores
      final response = await _supabase
          .from('alumno_tutores')
          .select('id_alumno')
          .inFilter('id_alumno', studentIds);

      final activeStudentIds = (response as List)
          .map((item) => item['id_alumno'] as String)
          .toList();

      debugPrint('Estudiantes activos encontrados: ${activeStudentIds.length}');

      if (activeStudentIds.length < studentIds.length) {
        final inactiveCount = studentIds.length - activeStudentIds.length;
        debugPrint(
            'Se excluyeron $inactiveCount estudiantes que no han sido registrados por tutores');
      }

      return activeStudentIds;
    } catch (e) {
      debugPrint('Error filtrando estudiantes activos: $e');
      throw Exception('Error al verificar estudiantes activos: $e');
    }
  }
}
