import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool _hasBeenConnected = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  bool get isConnected => _isConnected;
  bool get hasBeenConnected => _hasBeenConnected;

  ConnectivityProvider() {
    _initConnectivity();
    _startListening();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _isConnected = false;
    }
  }

  void _startListening() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (_isConnected) {
      _hasBeenConnected = true;
    }

    // Solo notificar si el estado cambió
    if (wasConnected != _isConnected) {
      debugPrint(
          'Connectivity changed: Connected=$_isConnected, HasBeenConnected=$_hasBeenConnected');
      if (!_isConnected) {
        debugPrint('📵 Internet connection lost');
      } else {
        debugPrint('📶 Internet connection restored');
      }
      notifyListeners();
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        if (isConnected) {
          _hasBeenConnected = true;
        }
        notifyListeners();
      }

      return isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
