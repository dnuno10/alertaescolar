import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

enum ScannerType { camera, physical }

enum ScannerState { idle, scanning, processing, success, error }

class AttendanceScannerProvider with ChangeNotifier {
  ScannerState _state = ScannerState.idle;
  ScannerType? _selectedScannerType;
  String? _lastScannedCode;
  String? _errorMessage;
  String? _successMessage;

  bool _isListeningToPhysicalScanner = false;
  QRViewController? _cameraController;

  // Historial de códigos leídos (solo para UI)
  List<String> _scannedHistory = [];

  // Callback que el View inyecta para procesar el QR real (ScannerService vive en el View)
  Future<void> Function(String code)? _onScanCallback;

  // Getters
  ScannerState get state => _state;
  ScannerType? get selectedScannerType => _selectedScannerType;
  String? get lastScannedCode => _lastScannedCode;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isListeningToPhysicalScanner => _isListeningToPhysicalScanner;
  bool get isScanning => _state == ScannerState.scanning;
  List<String> get scannedHistory => List.unmodifiable(_scannedHistory);

  // Inyección del callback desde el View
  void setOnScanCallback(Future<void> Function(String code) callback) {
    _onScanCallback = callback;
  }

  // Estado base
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
    _cameraController?.pauseCamera();
    _setState(ScannerState.idle);
  }

  /// Importante: el View debe haber llamado antes a `setOnScanCallback(...)`
  /// para que el procesamiento real (sin mocks) ocurra fuera del provider.
  void onCameraQRViewCreated(QRViewController controller) {
    setCameraController(controller);
    controller.scannedDataStream.listen((scanData) async {
      if (_state == ScannerState.scanning && (scanData.code ?? '').isNotEmpty) {
        await _forwardScan(scanData.code!.trim());
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

  /// Recibe el texto de un lector físico (teclado/USB/Bluetooth) y lo reenvía.
  Future<void> handlePhysicalScannerInput(String input) async {
    final code = input.trim();
    if (code.isEmpty) return;

    // Solo condicionamos por estado para evitar ruido cuando no está activo
    if (!_isListeningToPhysicalScanner &&
        _selectedScannerType == ScannerType.physical) {
      // Si explícitamente estamos en físico pero no escuchando, ignoramos
      return;
    }
    await _forwardScan(code);
  }

  // ===== Reenvío del QR al callback real (View/Service) =====
  bool _isForwarding = false;

  Future<void> _forwardScan(String code) async {
    if (_isForwarding) return; // anti doble-disparo por stream
    _isForwarding = true;
    _lastScannedCode = code;
    _setState(ScannerState.processing);

    try {
      if (_onScanCallback == null) {
        _setError('No hay handler de escaneo configurado');
        return;
      }
      await _onScanCallback!(code);
      _setSuccess('Escaneo procesado');
    } catch (e) {
      _setError('Error al reenviar el escaneo: $e');
    } finally {
      _isForwarding = false;
    }
  }

  // ===== Historial (solo UI) =====
  void addToHistory(String code) {
    _scannedHistory.insert(0, code);
    if (_scannedHistory.length > 50) {
      _scannedHistory = _scannedHistory.take(50).toList();
    }
    notifyListeners();
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
