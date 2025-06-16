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
