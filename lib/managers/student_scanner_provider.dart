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

  /// Busca alumno por matrícula (valor del QR).
  /// Regresa el Alumno con el nombre del grupo ya mapeado.
  Future<Alumno?> findStudentByMatricula(String matricula) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Searching for student with matricula: $matricula');

      final resp = await _supabase.from('alumnos').select('''
            id,
            nombre,
            id_grupo,
            id_escuela,
            id_llave,
            vinculado,
            matricula,
            fecha_registro,
            id_turno,
            turno,
            grupos!inner(grupo)
          ''').eq('matricula', matricula).maybeSingle();

      if (resp == null) {
        debugPrint('No student found with matricula: $matricula');
        return null;
      }

      // Extrae el nombre del grupo del join y lo deja como campo plano "grupo"
      final Map<String, dynamic> row = Map<String, dynamic>.from(resp);
      if (row['grupos'] is Map) {
        final g = row['grupos'] as Map;
        row['grupo'] = g['grupo']?.toString() ?? '';
      } else {
        row['grupo'] = row['grupo'] ?? '';
      }

      // Parseo robusto de fecha si hiciera falta (Alumno.fromJson ya maneja DateTime.parse).
      // Solo aseguramos que fecha_registro sea String.
      if (row['fecha_registro'] != null && row['fecha_registro'] is! String) {
        row['fecha_registro'] = row['fecha_registro'].toString();
      }

      final alumno = Alumno.fromJson(row);

      debugPrint(
          'Student found: ${alumno.nombre}, grupo: ${alumno.grupo}, turno: ${alumno.turno}');
      return alumno;
    } catch (e) {
      debugPrint('Error finding student: $e');
      _error = 'Error al buscar el estudiante: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
