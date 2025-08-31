import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../models/alumno.dart';
import '../models/notificacion.dart';

enum ScannerType {
  camera,
  physical,
}

enum ScannerState {
  idle,
  scanning,
  processing,
  success,
  error,
}

class AttendanceScannerProvider with ChangeNotifier {
  ScannerState _state = ScannerState.idle;
  ScannerType? _selectedScannerType;
  String? _lastScannedCode;
  String? _errorMessage;
  String? _successMessage;
  bool _isListeningToPhysicalScanner = false;
  QRViewController? _cameraController;
  List<String> _scannedHistory = [];

  // Mock admin ID - en una app real, vendría del sistema de auth
  final String _currentAdminId = 'current-admin-id';

  // Getters
  ScannerState get state => _state;
  ScannerType? get selectedScannerType => _selectedScannerType;
  String? get lastScannedCode => _lastScannedCode;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isListeningToPhysicalScanner => _isListeningToPhysicalScanner;
  bool get isScanning => _state == ScannerState.scanning;
  List<String> get scannedHistory => List.unmodifiable(_scannedHistory);

  void _setState(ScannerState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(ScannerState.error);
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _setState(ScannerState.success);
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    if (_state == ScannerState.error || _state == ScannerState.success) {
      _setState(ScannerState.idle);
    }
  }

  void selectScannerType(ScannerType type) {
    _selectedScannerType = type;
    notifyListeners();
  }

  // ===== Cámara =====
  void setCameraController(QRViewController controller) {
    _cameraController = controller;
  }

  void startCameraScanning() {
    if (_cameraController != null) {
      _setState(ScannerState.scanning);
      _cameraController!.resumeCamera();
    }
  }

  void stopCameraScanning() {
    if (_cameraController != null) {
      _cameraController!.pauseCamera();
    }
    _setState(ScannerState.idle);
  }

  void onCameraQRViewCreated(QRViewController controller) {
    setCameraController(controller);
    controller.scannedDataStream.listen((scanData) {
      if (_state == ScannerState.scanning && scanData.code != null) {
        _processScanResult(scanData.code!);
      }
    });
  }

  // ===== Lector físico =====
  void startPhysicalScannerListening() {
    _isListeningToPhysicalScanner = true;
    _setState(ScannerState.scanning);
    notifyListeners();
  }

  void stopPhysicalScannerListening() {
    _isListeningToPhysicalScanner = false;
    _setState(ScannerState.idle);
    notifyListeners();
  }

  void handlePhysicalScannerInput(String input) {
    if (_isListeningToPhysicalScanner && input.isNotEmpty) {
      _processScanResult(input.trim());
    }
  }

  // ===== Procesamiento =====
  Future<void> _processScanResult(String scannedCode) async {
    _setState(ScannerState.processing);
    _lastScannedCode = scannedCode;

    try {
      final student = await _findStudentByMatricula(scannedCode);

      if (student == null) {
        _setError('Estudiante no encontrado con matrícula: $scannedCode');
        return;
      }

      await _createAttendanceNotification(student);

      // Historial
      _scannedHistory.insert(0, scannedCode);
      if (_scannedHistory.length > 50) {
        _scannedHistory = _scannedHistory.take(50).toList();
      }

      _setSuccess('Asistencia registrada para ${student.nombre}');
    } catch (e) {
      _setError('Error al procesar el escaneo: $e');
    }
  }

  // Mock: buscar alumno por matrícula (usa tu modelo Alumno correcto)
  Future<Alumno?> _findStudentByMatricula(String matricula) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final mockStudents = <Alumno>[
      Alumno(
        id: 'student-1-id',
        nombre: 'Juan Pérez',
        idGrupo: 'group-1-id',
        grupo: 'Grupo A',
        idEscuela: 'school-1-id',
        idLlave: 'key-1',
        matricula: '2024001',
        fechaRegistro: now,
        idTurno: '', // si no aplica en mock
      ),
      Alumno(
        id: 'student-2-id',
        nombre: 'María García',
        idGrupo: 'group-1-id',
        grupo: 'Grupo A',
        idEscuela: 'school-1-id',
        idLlave: 'key-2',
        matricula: '2024002',
        fechaRegistro: now,
        idTurno: '',
      ),
      Alumno(
        id: 'student-3-id',
        nombre: 'Carlos López',
        idGrupo: 'group-2-id',
        grupo: 'Grupo B',
        idEscuela: 'school-1-id',
        idLlave: 'key-3',
        matricula: '2024003',
        fechaRegistro: now,
        idTurno: '',
      ),
    ];

    for (final s in mockStudents) {
      if (s.matricula == matricula) return s;
    }
    return null;
  }

  // Crear notificación de asistencia (mock)
  Future<void> _createAttendanceNotification(Alumno student) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final hour = now.hour;

    TipoNotificacion tipoNotificacion;
    if (hour >= 7 && hour < 12) {
      tipoNotificacion = TipoNotificacion.entrada;
    } else if (hour >= 12 && hour < 18) {
      tipoNotificacion = TipoNotificacion.salida;
    } else {
      tipoNotificacion = TipoNotificacion.entrada;
    }

    final notification = Notificacion(
      id: 'notification-${DateTime.now().millisecondsSinceEpoch}',
      alumnoId: student.id,
      adminId: _currentAdminId,
      titulo: 'Notificación',
      mensaje: 'Notificación',
      tipo: tipoNotificacion,
      estado: EstadoNotificacion.nueva,
      fechaHora: now,
    );

    // Evitar print en producción
    debugPrint('Creating attendance notification: ${notification.toJson()}');

    // Aquí iría tu inserción real a BD / API.
  }

  // ===== Utilidades =====
  void resetScanner() {
    stopCameraScanning();
    stopPhysicalScannerListening();
    _selectedScannerType = null;
    clearMessages();
    _lastScannedCode = null;
  }

  void clearAllData() {
    _state = ScannerState.idle;
    _selectedScannerType = null;
    _lastScannedCode = null;
    _errorMessage = null;
    _successMessage = null;
    _isListeningToPhysicalScanner = false;
    _cameraController = null;
    _scannedHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
