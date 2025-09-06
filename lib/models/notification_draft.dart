// lib/models/notification_draft.dart
import 'package:alertaescolar/models/models.dart';

/// Contrato único entre SendView, ReviewView y el Service.
/// 100% serializable y alineado a columnas SQL.
class NotificationDraft {
  /// 'permiso' | 'comunicado' (snake_case según tu .dbValue)
  final String tipoMensaje;

  /// 'individual' | 'grupo' | 'turno' | 'todos'
  final String tipoDestinatario;

  final String titulo;
  final String mensaje;

  /// Solo si tipoMensaje == 'comunicado'
  /// Usa snake_case: 'emergencia', 'paseo', 'evento', ...
  final String? tipoComunicado;

  /// 'baja' | 'media' | 'alta' | 'critica'
  final String? prioridad;

  /// Recipients normalizados a ids
  final String? alumnoId;
  final List<String>? grupoIds;
  final String? turnoId;

  NotificationDraft({
    required this.tipoMensaje,
    required this.tipoDestinatario,
    required this.titulo,
    required this.mensaje,
    this.tipoComunicado,
    this.prioridad,
    this.alumnoId,
    this.grupoIds,
    this.turnoId,
  });

  /// Payload listo para INSERT + jsonb(datos_adicionales)
  Map<String, dynamic> toPersistenceMap({
    required String adminId,
    required String escuelaId,
  }) {
    return {
      // columnas directas
      'id_admin': adminId,
      'id_escuela': escuelaId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipoMensaje, // 'permiso' | 'comunicado'
      'estado': 'nueva', // default en UI (o en DB)
      'fecha_hora': DateTime.now().toIso8601String(),

      // meta que NO rompe el esquema base
      'datos_adicionales': {
        'tipo_comunicacion': tipoComunicado, // null si permiso
        'prioridad': prioridad, // null si permiso
        'destinatario': {
          'tipo': tipoDestinatario, // 'individual'|'grupo'|'turno'|'todos'
          'alumno_id': alumnoId,
          'grupo_ids': grupoIds,
          'turno_id': turnoId,
        },
        'enviar_push': true, // mantén la UX de push inmediato
      },
    };
  }
}
