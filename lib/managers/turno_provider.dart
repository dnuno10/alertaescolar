import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turno.dart';
import '../components/loading_dialog.dart';

class TurnoProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Turno> _turnos = [];
  Turno? _selectedTurno;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Turno> get turnos => _turnos;
  Turno? get selectedTurno => _selectedTurno;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load all turnos for a school
  Future<void> loadTurnos({
    required String escuelaId,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Cargando turnos...');
      }
      notifyListeners();

      final response = await _supabase
          .from('turnos')
          .select()
          .eq('id_escuela', escuelaId)
          .order('turno');

      _turnos = (response as List).map((item) => Turno.fromJson(item)).toList();

      _error = null;
      debugPrint('Loaded ${_turnos.length} turnos from database');
    } catch (e) {
      _error = 'Error al cargar turnos: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Get turno by type (e.g., "Matutino", "Vespertino")
  Turno? getTurnoByType(String turnoType) {
    return _turnos
        .where((turno) => turno.turno.toLowerCase() == turnoType.toLowerCase())
        .firstOrNull;
  }

  // Get morning shift (assuming it's named "Matutino")
  Turno? getMorningShift() {
    return getTurnoByType('Matutino');
  }

  // Get afternoon shift (assuming it's named "Vespertino")
  Turno? getAfternoonShift() {
    return getTurnoByType('Vespertino');
  }

  // Update turno configuration
  Future<bool> updateTurnoConfig({
    required String turnoId,
    required String horaInicio,
    required String horaFin,
    required int tolerancia,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context, message: 'Actualizando configuración...');
      }
      notifyListeners();

      // Format time for PostgreSQL time with timezone
      // PostgreSQL expects: "HH:MM:SS+00"
      final formattedHoraInicio = "${horaInicio}:00+00";
      final formattedHoraFin = "${horaFin}:00+00";

      await _supabase.from('turnos').update({
        'hora_inicio': formattedHoraInicio,
        'hora_fin': formattedHoraFin,
        'tolerancia': tolerancia,
      }).eq('id', turnoId);

      // Update the local copy as well
      final index = _turnos.indexWhere((turno) => turno.id == turnoId);
      if (index != -1) {
        _turnos[index] = _turnos[index].copyWith(
          horaInicio: horaInicio,
          horaFin: horaFin,
          tolerancia: tolerancia,
        );
      }

      _error = null;
      debugPrint('Updated turno configuration for id: $turnoId');
      return true;
    } catch (e) {
      _error = 'Error al actualizar configuración: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Update multiple turnos at once (for scanner configuration)
  Future<bool> updateScannerConfiguration({
    required String escuelaId,
    required String morningTurnoId,
    required TimeOfDay morningStartTime,
    required TimeOfDay morningEndTime,
    required String afternoonTurnoId,
    required TimeOfDay afternoonStartTime,
    required TimeOfDay afternoonEndTime,
    required int tolerance,
    BuildContext? context,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      if (context != null && context.mounted) {
        LoadingDialog.show(context,
            message: 'Actualizando configuración del escáner...');
      }
      notifyListeners();

      // Format morning time values
      final morningStartFormatted = _formatTimeOfDay(morningStartTime);
      final morningEndFormatted = _formatTimeOfDay(morningEndTime);

      // Format afternoon time values
      final afternoonStartFormatted = _formatTimeOfDay(afternoonStartTime);
      final afternoonEndFormatted = _formatTimeOfDay(afternoonEndTime);

      // Update morning shift
      await _supabase.from('turnos').update({
        'hora_inicio': "${morningStartFormatted}:00+00",
        'hora_fin': "${morningEndFormatted}:00+00",
        'tolerancia': tolerance,
      }).eq('id', morningTurnoId);

      // Update afternoon shift
      await _supabase.from('turnos').update({
        'hora_inicio': "${afternoonStartFormatted}:00+00",
        'hora_fin': "${afternoonEndFormatted}:00+00",
        'tolerancia': tolerance,
      }).eq('id', afternoonTurnoId);

      // Update local copies
      await loadTurnos(escuelaId: escuelaId); // Reload turnos to get fresh data

      _error = null;
      debugPrint('Updated scanner configuration for school: $escuelaId');
      return true;
    } catch (e) {
      _error = 'Error al actualizar configuración del escáner: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      if (context != null && context.mounted) {
        LoadingDialog.hide(context);
      }
      notifyListeners();
    }
  }

  // Helper to format TimeOfDay to "HH:MM" string
  String _formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Helper to convert "HH:MM" string to TimeOfDay
  TimeOfDay? parseTimeString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    final parts = timeString.split(':');
    if (parts.length < 2) return null;

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint('Error parsing time string: $e');
      return null;
    }
  }

  // Get turno names
  List<String> getTurnoNames() {
    return _turnos.map((turno) => turno.turno).toList();
  }

  // Get turno by name
  Turno? getTurnoByName(String name) {
    return _turnos.where((turno) => turno.turno == name).firstOrNull;
  }

  // Get turno by ID
  Turno? getTurnoById(String id) {
    return _turnos.where((turno) => turno.id == id).firstOrNull;
  }

  // Set selected turno
  void setSelectedTurno(Turno? turno) {
    _selectedTurno = turno;
    notifyListeners();
  }

  // Clear turnos list
  void clearTurnos() {
    _turnos.clear();
    _selectedTurno = null;
    notifyListeners();
  }
}
