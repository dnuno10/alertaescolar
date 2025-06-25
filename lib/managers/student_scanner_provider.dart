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

  /// Find student by matricula (QR code value)
  /// Returns the student with grupo information
  Future<Alumno?> findStudentByMatricula(String matricula) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Searching for student with matricula: $matricula');

      final response = await _supabase.from('alumnos').select('''
            id,
            nombre,
            id_grupo,
            id_escuela,
            id_llave,
            vinculado,
            matricula,
            fecha_registro,
            turno,
            grupos!inner(
              grupo
            )
          ''').eq('matricula', matricula).maybeSingle();

      if (response == null) {
        debugPrint('No student found with matricula: $matricula');
        return null;
      }

      // Parse turno enum
      TurnoEnum turnoEnum = TurnoEnum.matutino;
      if (response['turno'] != null) {
        try {
          turnoEnum = TurnoEnum.values.firstWhere(
            (e) =>
                e.name.toLowerCase() ==
                response['turno'].toString().toLowerCase(),
            orElse: () => TurnoEnum.matutino,
          );
        } catch (e) {
          debugPrint('Error parsing turno: $e, using default');
        }
      }

      // Get grupo name from the joined grupos table
      String grupoName = '';
      if (response['grupos'] != null && response['grupos'] is Map) {
        grupoName = response['grupos']['grupo']?.toString() ?? '';
      }

      // Parse fecha_registro safely
      DateTime fechaRegistro = DateTime.now();
      if (response['fecha_registro'] != null) {
        try {
          fechaRegistro = DateTime.parse(response['fecha_registro'].toString());
        } catch (e) {
          debugPrint('Error parsing fecha_registro: $e, using current date');
        }
      }

      // Map response to Alumno object using the correct structure
      final alumno = Alumno(
        id: response['id']?.toString() ?? '',
        nombre: response['nombre']?.toString() ?? '',
        id_grupo: response['id_grupo']?.toString() ?? '',
        grupo: grupoName,
        id_escuela: response['id_escuela']?.toString() ?? '',
        id_llave: response['id_llave']?.toString() ?? '',
        vinculado: response['vinculado'] == true,
        matricula: response['matricula']?.toString() ?? '',
        fecha_registro: fechaRegistro,
        turno: turnoEnum,
      );

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

  /// Get turno information for time validation based on turno enum and school
  Future<Map<String, dynamic>?> getTurnoInfo(
      TurnoEnum turnoEnum, String escuelaId) async {
    try {
      // Convert enum to string for database query
      String turnoString = turnoEnum.name; // 'matutino' or 'vespertino'

      final response = await _supabase
          .from('turnos')
          .select('*')
          .eq('turno', turnoString)
          .eq('id_escuela', escuelaId)
          .maybeSingle();

      if (response != null) {
        debugPrint(
            'Turno info found: ${response['turno']} - ${response['hora_inicio']} to ${response['hora_fin']}');
      }

      return response;
    } catch (e) {
      debugPrint('Error getting turno info: $e');
      return null;
    }
  }

  /// Get student's turno information for time validation (legacy method for compatibility)
  Future<Map<String, dynamic>?> getStudentTurno(int idTurno) async {
    try {
      final response = await _supabase
          .from('turnos')
          .select('*')
          .eq('id', idTurno)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error getting turno: $e');
      return null;
    }
  }
}
