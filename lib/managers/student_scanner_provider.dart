import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class StudentScannerProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAllData() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Obtiene información del turno (por enum + escuela) -> Turno del modelo.
  Future<Turno?> getTurnoInfo(TurnoEnum turnoEnum, String escuelaId) async {
    try {
      final turnoString =
          turnoEnum.name; // 'matutino' | 'vespertino' | 'desconocido'

      final resp = await _supabase
          .from('turnos')
          .select('*')
          .eq('turno', turnoString)
          .eq('id_escuela', escuelaId)
          .maybeSingle();

      if (resp == null) return null;

      final t = Turno.fromJson(Map<String, dynamic>.from(resp));
      debugPrint(
          'Turno info: ${t.turno} - ${t.horaInicio} to ${t.horaFin} (tol: ${t.tolerancia}m)');
      return t;
    } catch (e) {
      debugPrint('Error getting turno info: $e');
      return null;
    }
  }

  /// Obtiene un turno por su ID (UUID en tu modelo) -> Turno del modelo.
  Future<Turno?> getStudentTurno(String idTurno) async {
    try {
      final resp = await _supabase
          .from('turnos')
          .select('*')
          .eq('id', idTurno)
          .maybeSingle();

      if (resp == null) return null;

      return Turno.fromJson(Map<String, dynamic>.from(resp));
    } catch (e) {
      debugPrint('Error getting turno by id: $e');
      return null;
    }
  }
}
