import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScannerType { camera, physical }

enum ScannerState { idle, scanning, processing, success, error }

class AttendanceScannerProvider with ChangeNotifier {
  ScannerState _state = ScannerState.idle;
  ScannerType? _selectedScannerType;
  String? _lastScannedCode;
  String? _errorMessage;
  String? _successMessage;

  bool _isListeningToPhysicalScanner = false;
  MobileScannerController? _cameraController;

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

  // ===== Cámara (mobile_scanner) =====
  void setCameraController(MobileScannerController controller) {
    _cameraController = controller;
  }

  Future<void> startCameraScanning() async {
    if (_cameraController != null) {
      _setState(ScannerState.scanning);
      try {
        await _cameraController!.start();
      } catch (e) {
        _setError('No se pudo iniciar la cámara: $e');
      }
    }
  }

  Future<void> stopCameraScanning() async {
    try {
      await _cameraController?.stop();
    } catch (_) {}
    _setState(ScannerState.idle);
  }

  /// Con mobile_scanner usamos `onDetect` desde la vista y lo encaminamos aquí si quieres centralizar la lógica.
  Future<void> handleMobileDetection(BarcodeCapture capture) async {
    if (_state != ScannerState.scanning) return;

    // Tomamos el primer barcode con valor válido
    final code = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');

    if (code.isEmpty) return;
    await _forwardScan(code);
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

    if (!_isListeningToPhysicalScanner &&
        _selectedScannerType == ScannerType.physical) {
      return;
    }
    await _forwardScan(code);
  }

  // ===== Reenvío del QR al callback real (View/Service) =====
  bool _isForwarding = false;

  Future<void> _forwardScan(String code) async {
    if (_isForwarding) return; // anti doble-disparo
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
  Future<void> resetScanner() async {
    await stopCameraScanning();
    stopPhysicalScannerListening();
    _selectedScannerType = null;
    clearMessages();
    _lastScannedCode = null;
  }

  Future<void> clearAllData() async {
    try {
      await _cameraController?.dispose();
    } catch (_) {}
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
    try {
      _cameraController?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
