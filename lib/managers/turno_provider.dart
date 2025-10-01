import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turno.dart' as turno_model;

/// Tipos de fase para el escáner (lo que la UI/servicio necesita resolver)

/// Resultado de resolución de fase de acceso en el instante `now`.
class AccessPhase {
  final ScannerAccessType type;
  final turno_model.Turno? turno; // Turno al que aplica la fase/validación
  final DateTime?
      windowStart; // Inicio de ventana considerada (para depurar/mostrar)
  final DateTime?
      windowEnd; // Fin de ventana considerada (para depurar/mostrar)
  final bool withinTolerance; // Solo relevante cuando type==entry
  final int
      minutesLate; // Minutos de retraso (>=0); 0 si en tiempo. Solo para entrada.
  final String?
      reason; // Texto breve de por qué se resolvió así (útil para logs)

  const AccessPhase({
    required this.type,
    required this.turno,
    required this.windowStart,
    required this.windowEnd,
    required this.withinTolerance,
    required this.minutesLate,
    required this.reason,
  });
}

/// Representa una ventana de turno aterrizada a DateTime reales (start/end)
class _ShiftWindow {
  final turno_model.Turno raw;
  final DateTime start;
  final DateTime end;

  _ShiftWindow({
    required this.raw,
    required this.start,
    required this.end,
  });

  bool contains(DateTime t) =>
      (t.isAtSameMomentAs(start) || t.isAfter(start)) && t.isBefore(end);
  bool isEndedBefore(DateTime t) => end.isBefore(t) || end.isAtSameMomentAs(t);
  bool startsAfter(DateTime t) => start.isAfter(t) || start.isAtSameMomentAs(t);
}

/// Proveedor para gestionar turnos (dinámico, N turnos) por escuela.
class TurnoProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado
  final List<turno_model.Turno> _turnos = [];
  bool _isLoading = false;
  String? _error;
  String? _currentEscuelaId;

  // Realtime
  RealtimeChannel? _chTurnos;

  // Getters
  List<turno_model.Turno> get turnos => List.unmodifiable(_turnos);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentEscuelaId => _currentEscuelaId;

  // ---------------- Helpers privados ----------------

  void _setLoading(bool v) {
    _isLoading = v;
    Future.microtask(notifyListeners);
  }

  void _setError(String? msg) {
    _error = msg;
    Future.microtask(notifyListeners);
  }

  void _disposeRealtime() {
    _chTurnos?.unsubscribe();
    _chTurnos = null;
  }

  void _startRealtimeForSchool(String escuelaId) {
    _disposeRealtime();
    _chTurnos = _supabase.channel('turnos_school_$escuelaId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'turnos',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id_escuela',
          value: escuelaId,
        ),
        callback: (payload) async {
          try {
            await loadTurnos(escuelaId: escuelaId);
          } catch (_) {}
        },
      )
      ..subscribe();
  }

  void _replaceOrAdd(turno_model.Turno t) {
    final idx = _turnos.indexWhere((x) => x.id == t.id);
    if (idx == -1) {
      _turnos.add(t);
    } else {
      _turnos[idx] = t;
    }
  }

  // ---------------- Utilidades de tiempo ----------------

  /// Parsea time dinámico a TimeOfDay. Acepta:
  /// - HH:mm
  /// - HH:mm:ss
  /// - HH:mm:ss+ZZ / HH:mm:ss.ffffff / HH:mm:ss.ffffff+ZZ
  /// - ISO con fecha (YYYY-MM-DDTHH:mm[:ss][.ffffffff][Z|+ZZ])
  TimeOfDay? parseTimeString(dynamic value) {
    if (value == null) return null;
    String s = value.toString().trim();
    if (s.isEmpty) return null;

    try {
      // Si viene ISO con fecha, quedarnos con la parte de la hora.
      if (s.contains('T')) {
        final timePart = s.split('T').last;
        s = timePart;
      }

      // Quitar zona horaria (+00, Z) y fracciones (.ffffff)
      if (s.contains('+')) s = s.split('+').first;
      if (s.endsWith('Z')) s = s.substring(0, s.length - 1);
      if (s.contains('.')) s = s.split('.').first;

      // Ahora s debería ser HH:mm o HH:mm:ss
      final parts = s.split(':');
      if (parts.length < 2) return null;

      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);

      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  /// Formatea TimeOfDay -> 'HH:mm'
  String formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Crea un DateTime "hoy" con la hora/minuto de un TimeOfDay.
  DateTime _buildToday(TimeOfDay tod, {DateTime? anchor}) {
    final base = anchor ?? DateTime.now();
    return DateTime(base.year, base.month, base.day, tod.hour, tod.minute);
    // Nota: usaremos la zona del dispositivo. Si requieres TZ de la escuela,
    // aquí podrías aplicar un offset/país según configuración de la escuela.
  }

  /// Construye ventanas de turno (start/end) para HOY.
  /// Maneja turnos que cruzan medianoche (end < start => end + 1 día).
  List<_ShiftWindow> _buildTodayWindows(List<turno_model.Turno> list,
      {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final windows = <_ShiftWindow>[];

    for (final t in list) {
      final startTod = parseTimeString(t.horaInicio);
      final endTod = parseTimeString(t.horaFin);
      if (startTod == null || endTod == null) continue;

      var start = _buildToday(startTod, anchor: anchor);
      var end = _buildToday(endTod, anchor: anchor);

      // Si el fin es "antes" que el inicio, asumimos turno nocturno que cruza medianoche.
      if (!end.isAfter(start)) {
        end = end.add(const Duration(days: 1));
      }

      windows.add(_ShiftWindow(raw: t, start: start, end: end));
    }

    windows.sort((a, b) => a.start.compareTo(b.start));
    return windows;
  }

  // ---------------- API pública ----------------

  void clearError() => _setError(null);

  /// Limpia todo y cierra realtime.
  void clearAllData() {
    _disposeRealtime();
    _turnos.clear();
    _isLoading = false;
    _error = null;
    _currentEscuelaId = null;
    Future.microtask(notifyListeners);
  }

  /// Carga todos los turnos de una escuela ordenados por hora de inicio.
  Future<void> loadTurnos({
    required String escuelaId,
    BuildContext? context,
  }) async {
    if (escuelaId.trim().isEmpty) {
      _setError('Escuela no válida');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final resp = await _supabase
          .from('turnos')
          .select(
              'id, turno, hora_inicio, hora_fin, tolerancia, id_escuela, fecha_registro, aplicar_tolerancia')
          .eq('id_escuela', escuelaId)
          .order('hora_inicio', ascending: true);

      _turnos
        ..clear()
        ..addAll((resp as List).map((e) => turno_model.Turno.fromJson(e)));

      _currentEscuelaId = escuelaId;

      // Inicia realtime
      _startRealtimeForSchool(escuelaId);
    } catch (e) {
      _setError('Error al cargar turnos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca turno por ID.
  turno_model.Turno? getTurnoById(String id) {
    try {
      return _turnos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Busca turno por nombre (case-insensitive).
  turno_model.Turno? getTurnoByName(String name) {
    final target = name.trim().toLowerCase();
    try {
      return _turnos.firstWhere(
        (t) => t.turno.trim().toLowerCase() == target,
      );
    } catch (_) {
      return null;
    }
  }

  /// Actualiza un turno por ID.
  Future<bool> updateTurno({
    required String turnoId,
    String? nombre,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    int? tolerancia,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['turno'] = nombre.trim();
      if (horaInicio != null) data['hora_inicio'] = formatTimeOfDay(horaInicio);
      if (horaFin != null) data['hora_fin'] = formatTimeOfDay(horaFin);
      if (tolerancia != null) data['tolerancia'] = tolerancia;

      if (data.isEmpty) return true;

      final updated = await _supabase
          .from('turnos')
          .update(data)
          .eq('id', turnoId)
          .select()
          .single();

      _replaceOrAdd(turno_model.Turno.fromJson(updated));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar turno: $e');
      return false;
    }
  }

  /// Elimina un turno.
  Future<bool> deleteTurno(String turnoId) async {
    try {
      await _supabase.from('turnos').delete().eq('id', turnoId);
      _turnos.removeWhere((t) => t.id == turnoId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar turno: $e');
      return false;
    }
  }

  /// Actualiza múltiples turnos (horas + tolerancia) en lote.
  Future<bool> updateTurnosBatch(List<TurnoPatch> patches) async {
    if (patches.isEmpty) return true;
    _setLoading(true);
    _setError(null);

    try {
      for (final p in patches) {
        final updated = await _supabase
            .from('turnos')
            .update({
              'hora_inicio': formatTimeOfDay(p.start),
              'hora_fin': formatTimeOfDay(p.end),
              'tolerancia': p.tolerancia,
              'aplicar_tolerancia': p.aplicarTolerancia,
            })
            .eq('id', p.id)
            .select()
            .single();
        _replaceOrAdd(turno_model.Turno.fromJson(updated));
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al guardar turnos: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ----------------- RESOLUCIÓN DE FASE (Entrada/Salida) -----------------

  /// Resuelve si el escáner debe tratarse como ENTRADA o SALIDA en el instante `now`.
  ///
  /// Reglas:
  ///  - **Entrada**: mientras `now` esté entre [start, end) del turno activo.
  ///    La **tolerancia** (minutos) SOLO aplica para calificar si el alumno va en tiempo
  ///    o en retraso (no cambia que la fase sea entrada).
  ///  - **Salida**: desde que `hora_fin` del turno activo llega/pasa y hasta que inicie
  ///    el siguiente turno. Cuando otra `hora_inicio` llega, volvemos a **Entrada** con
  ///    la tolerancia de ese nuevo turno.
  ///
  /// Si no hay turnos cargados, se devuelve `exit` sin turno (para bloquear).
  AccessPhase resolveAccessPhase({DateTime? now}) {
    final now0 = now ?? DateTime.now();

    if (_turnos.isEmpty) {
      return const AccessPhase(
        type: ScannerAccessType.exit,
        turno: null,
        windowStart: null,
        windowEnd: null,
        withinTolerance: false,
        minutesLate: 0,
        reason: 'No hay turnos configurados',
      );
    }

    final windows = _buildTodayWindows(_turnos, now: now0);

    for (final w in windows) {
      if (w.contains(now0)) {
        // ENTRADA
        final tol = (w.raw.tolerancia).toInt();
        final limitOnTime = w.start.add(Duration(minutes: tol.clamp(0, 480)));

        final withinTol = !now0.isAfter(limitOnTime);
        final lateMinutes =
            withinTol ? 0 : now0.difference(limitOnTime).inMinutes;

        return AccessPhase(
          type: ScannerAccessType.entry,
          turno: w.raw,
          windowStart: w.start,
          windowEnd: w.end,
          withinTolerance: withinTol,
          minutesLate: lateMinutes,
          reason: withinTol
              ? 'Dentro de turno (en tiempo/tolerancia)'
              : 'Dentro de turno (retraso ${lateMinutes}m > tolerancia ${tol}m)',
        );
      }
    }

    _ShiftWindow? lastEnded;
    _ShiftWindow? nextStarting;

    for (final w in windows) {
      if (w.isEndedBefore(now0)) {
        lastEnded = w;
      } else if (w.startsAfter(now0) && nextStarting == null) {
        nextStarting = w;
      }
    }

    if (lastEnded != null &&
        (nextStarting == null || nextStarting.start.isAfter(now0))) {
      return AccessPhase(
        type: ScannerAccessType.exit,
        turno: lastEnded.raw,
        windowStart: lastEnded.end,
        windowEnd: nextStarting?.start,
        withinTolerance: false,
        minutesLate: 0,
        reason:
            'Fuera de turno activo; aplica SALIDA del último turno que finalizó',
      );
    }

    if (lastEnded == null &&
        nextStarting != null &&
        now0.isBefore(nextStarting.start)) {
      return AccessPhase(
        type: ScannerAccessType.exit,
        turno: null,
        windowStart: null,
        windowEnd: nextStarting.start,
        withinTolerance: false,
        minutesLate: 0,
        reason: 'Antes del primer turno del día; aún no es ENTRADA',
      );
    }

    // 4) Caso borde: no hay siguiente turno (estamos después del último) → SALIDA genérica del último si existiera.
    if (lastEnded != null && nextStarting == null) {
      return AccessPhase(
        type: ScannerAccessType.exit,
        turno: lastEnded.raw,
        windowStart: lastEnded.end,
        windowEnd: null,
        withinTolerance: false,
        minutesLate: 0,
        reason: 'Después del último turno del día; SALIDA',
      );
    }

    // 5) Devolver salida por defecto (fallback seguro).
    return const AccessPhase(
      type: ScannerAccessType.exit,
      turno: null,
      windowStart: null,
      windowEnd: null,
      withinTolerance: false,
      minutesLate: 0,
      reason: 'No se pudo determinar fase; fallback SALIDA',
    );
  }

  @override
  void dispose() {
    _disposeRealtime();
    super.dispose();
  }
}

/// Patch por turno para guardado en lote (para la vista de escáner).
class TurnoPatch {
  final String id;
  final TimeOfDay start;
  final TimeOfDay end;
  final int tolerancia;
  final bool aplicarTolerancia;
  TurnoPatch({
    required this.id,
    required this.start,
    required this.end,
    required this.tolerancia,
    required this.aplicarTolerancia,
  });
}
