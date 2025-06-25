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

  // Mock admin ID - in a real app, this would come from authentication
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

  // Camera Scanner Methods
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

  // Physical Scanner Methods
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

  // Process scan result and create notification
  Future<void> _processScanResult(String scannedCode) async {
    _setState(ScannerState.processing);
    _lastScannedCode = scannedCode;

    try {
      // Find student by matricula
      final student = await _findStudentByMatricula(scannedCode);

      if (student == null) {
        _setError('Estudiante no encontrado con matrícula: $scannedCode');
        return;
      }

      // Create attendance notification
      await _createAttendanceNotification(student);

      // Add to history
      _scannedHistory.insert(0, scannedCode);
      if (_scannedHistory.length > 50) {
        _scannedHistory = _scannedHistory.take(50).toList();
      }

      _setSuccess('Asistencia registrada para ${student.nombre}');
    } catch (e) {
      _setError('Error al procesar el escaneo: $e');
    }
  }

  // Mock method to find student by matricula
  Future<Alumno?> _findStudentByMatricula(String matricula) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - In real implementation, this would query the database
    final mockStudents = [
      Alumno(
        id: 'student-1-id',
        nombre: 'Juan Pérez',
        id_grupo: 'group-1-id',
        grupo: 'Grupo A',
        id_escuela: 'school-1-id',
        id_llave: 'key-1',
        matricula: '2024001',
        fecha_registro: DateTime.now(),
      ),
      Alumno(
        id: 'student-2-id',
        nombre: 'María García',
        id_grupo: 'group-1-id',
        grupo: 'Grupo A',
        id_escuela: 'school-1-id',
        id_llave: 'key-2',
        matricula: '2024002',
        fecha_registro: DateTime.now(),
      ),
      Alumno(
        id: 'student-3-id',
        nombre: 'Carlos López',
        id_grupo: 'group-2-id',
        grupo: 'Grupo B',
        id_escuela: 'school-1-id',
        id_llave: 'key-3',
        matricula: '2024003',
        fecha_registro: DateTime.now(),
      ),
    ];

    return mockStudents.firstWhere(
      (student) => student.matricula == matricula,
      orElse: () => throw Exception('Student not found'),
    );
  }

  // Create attendance notification in database
  Future<void> _createAttendanceNotification(Alumno student) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Determine notification type based on current time
    final now = DateTime.now();
    final currentHour = now.hour;

    TipoNotificacion tipoNotificacion;
    if (currentHour >= 7 && currentHour < 12) {
      tipoNotificacion = TipoNotificacion.entrada;
    } else if (currentHour >= 12 && currentHour < 18) {
      tipoNotificacion = TipoNotificacion.salida;
    } else {
      tipoNotificacion = TipoNotificacion.entrada; // Default
    }

    // Create notification object
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

    // Mock database insertion
    print('Creating attendance notification: ${notification.toJson()}');

    // In a real implementation, you would call your API here:
    // await NotificationService.createNotification(notification);
  }

  // Utility method to reset scanner
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
