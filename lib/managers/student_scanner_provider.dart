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
  @override
  Future<Alumno?> findStudentByMatricula(String matricula) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final m = (matricula).trim();
      if (m.isEmpty) return null;

      debugPrint('Searching for student with matricula: $m');

      // Esquema alineado a la BD actual:
      final resp = await _supabase.from('alumnos').select('''
      id,
      nombre,
      id_grupo,
      id_escuela,
      matricula,
      fecha_registro,
      id_turno,
      grupos!inner(grupo),
      turnos(turno),
      llaves(
        id,
        activo,
        fecha_registro,
        fecha_desactivacion
      ),
      alumno_tutores(id_tutor)
    ''').eq('matricula', m).maybeSingle();

      if (resp == null) {
        debugPrint('No student found with matricula: $m');
        return null;
      }

      final Map<String, dynamic> row = Map<String, dynamic>.from(resp);

      // 1) Normalizar "grupo" como string plano
      if (row['grupos'] is Map) {
        row['grupo'] = (row['grupos']['grupo'] ?? '').toString();
      } else {
        row['grupo'] = row['grupo'] ?? '';
      }

      // 2) "turno" como string (el modelo Alumno suele mapear a enum internamente)
      final turnoStr = (row['turnos'] is Map)
          ? (row['turnos']['turno']?.toString() ?? 'desconocido')
          : 'desconocido';
      row['turno'] = turnoStr;

      // 3) Resolver llave activa vigente
      Map<String, dynamic>? activeKey;
      final List llaves = (row['llaves'] as List?) ?? const [];
      final now = DateTime.now();
      for (final l in llaves) {
        if (l is Map && (l['activo'] == true)) {
          try {
            final fReg = DateTime.tryParse('${l['fecha_registro']}');
            final fDes = DateTime.tryParse('${l['fecha_desactivacion']}');
            final inWindow = (fReg == null || !now.isBefore(fReg)) &&
                (fDes == null || !now.isAfter(fDes));
            if (inWindow) {
              activeKey = Map<String, dynamic>.from(l);
              break;
            }
          } catch (_) {
            // Si hay error de parseo, considera la llave activa por el flag
            activeKey = Map<String, dynamic>.from(l);
            break;
          }
        }
      }

      // 4) "vinculado" = hay tutor + llave activa
      final hasTutor = ((row['alumno_tutores'] as List?)?.isNotEmpty ?? false)
          ? true
          : false;
      row['vinculado'] = (hasTutor && activeKey != null);

      // 5) id_llave (si hay activa)
      row['id_llave'] = activeKey?['id']?.toString() ?? '';

      // 6) fecha_registro como String (por si viene como timestamp)
      if (row['fecha_registro'] != null && row['fecha_registro'] is! String) {
        row['fecha_registro'] = row['fecha_registro'].toString();
      }

      // 7) Quitar estructuras anidadas que el modelo no usa directamente
      row.remove('grupos');
      row.remove('turnos');
      row.remove('llaves');
      row.remove('alumno_tutores');

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
