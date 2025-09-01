import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turno.dart' as turno_model;

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

  /// Parsea 'HH:mm' / 'HH:mm:ss' / ISO -> TimeOfDay.
  TimeOfDay? parseTimeString(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    try {
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) {
        final parts = s.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(s)) {
        final parts = s.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final dt = DateTime.parse(s);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
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

  /// Carga todos los turnos de una escuela.
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
          .select('id, turno, hora_inicio, hora_fin, tolerancia, id_escuela')
          .eq('id_escuela', escuelaId)
          .order('turno');

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

  /// Crea turno.
  Future<turno_model.Turno?> createTurno({
    required String escuelaId,
    required String nombre,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
    required int tolerancia,
  }) async {
    try {
      final inserted = await _supabase
          .from('turnos')
          .insert({
            'id_escuela': escuelaId,
            'turno': nombre.trim(),
            'hora_inicio': formatTimeOfDay(horaInicio),
            'hora_fin': formatTimeOfDay(horaFin),
            'tolerancia': tolerancia,
          })
          .select()
          .single();

      final t = turno_model.Turno.fromJson(inserted);
      _replaceOrAdd(t);
      notifyListeners();
      return t;
    } catch (e) {
      _setError('Error al crear turno: $e');
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
  TurnoPatch({
    required this.id,
    required this.start,
    required this.end,
    required this.tolerancia,
  });
}
