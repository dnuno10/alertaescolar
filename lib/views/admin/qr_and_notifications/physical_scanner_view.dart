import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import 'processing_view.dart';

/// Physical Scanner View para lectores de QR conectados
///
/// Esta vista está diseñada para funcionar con un lector de QR físico conectado
/// al dispositivo. No muestra cámara y está preparado para recibir datos reales
/// del ScannerService.
///
/// Para integrar con un lector físico:
/// 1. Configurar el listener del dispositivo físico
/// 2. Llamar al método onPhysicalScanReceived(String code) cuando se detecte un código
/// 3. El resto del procesamiento es automático usando datos reales de la base de datos
class PhysicalScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final ScannerAccessType? accessType;
  final bool? isDefaultEntryConfig;

  const PhysicalScannerView({
    super.key,
    required this.onCodeScanned,
    this.accessType,
    this.isDefaultEntryConfig,
  });

  @override
  State<PhysicalScannerView> createState() => _PhysicalScannerViewState();
}

class _PhysicalScannerViewState extends State<PhysicalScannerView> {
  bool _isListening = true;
  bool _hasScanned = false;

  // Focus node and keyboard input handling for physical scanner
  final FocusNode _focusNode = FocusNode();
  String _currentInput = '';
  DateTime? _lastInputTime;

  @override
  void initState() {
    super.initState();
    // Request focus for keyboard input with delay to ensure widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  String _getAccessTypeText() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? 'Entrada Automática' : 'Salida Automática';
      case ScannerAccessType.entry:
        return 'Entrada';
      case ScannerAccessType.exit:
        return 'Salida';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Colors.green : Colors.orange;
      case ScannerAccessType.entry:
        return Colors.blue;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (!mounted || !_isListening) return;

    try {
      if (event is KeyDownEvent) {
        final character = event.character;
        final now = DateTime.now();

        // Reset input if too much time has passed (new scan)
        if (_lastInputTime != null &&
            now.difference(_lastInputTime!).inMilliseconds > 100) {
          _currentInput = '';
        }
        _lastInputTime = now;

        if (character != null) {
          if (character == '\n' || character == '\r') {
            // Enter pressed - complete scan
            if (_currentInput.isNotEmpty && _currentInput.length >= 3) {
              _processScannedCode(_currentInput.trim());
            }
            _currentInput = '';
          } else if (character.codeUnitAt(0) >= 32) {
            // Printable character
            if (mounted) {
              setState(() {
                _currentInput += character;
              });
              debugPrint('Building input: $_currentInput');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Key event error: $e');
      // Reset input on error
      if (mounted) {
        setState(() {
          _currentInput = '';
        });
      }
    }
  }

  /// Navigate to ProcessingView when QR code is detected
  Future<void> _processScannedCode(String code) async {
    if (_hasScanned) return;

    setState(() {
      _hasScanned = true;
      _isListening = false;
    });

    // Get current user (admin) ID
    final userProvider = context.read<UserProvider>();
    final adminId = userProvider.currentUser?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      _resetForNextScan();
      return;
    }

    // Navigate to ProcessingView
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProcessingView(
          scannedCode: code,
          adminId: adminId,
          accessType: widget.accessType ?? ScannerAccessType.automatic,
          isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
        ),
      ),
    );

    // Reset scanner for next scan when returning
    _resetForNextScan();

    // Call the callback if processing was successful
    if (result == true) {
      widget.onCodeScanned(code);
    }
  }

  void _resetForNextScan() {
    if (!mounted) return;

    try {
      setState(() {
        _hasScanned = false;
        _isListening = true;
      });
      _currentInput = '';

      // Refocus for next scan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    } catch (e) {
      debugPrint('Reset for next scan error: $e');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: CustomScrollView(
          slivers: [
            // Header
            NavHeader(
              title: 'Escáner Físico',
            ),

            // Main content
            SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                child: Column(
                  children: [
                    // Access type indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: _getAccessTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getAccessTypeColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getAccessTypeColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            _getAccessTypeText(),
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: _getAccessTypeColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),

                    // Scanner visualization
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Scanner icon (static - no animation)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentOrange.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner,
                                size: 60,
                                color: AppTheme.accentOrange,
                              ),
                            ),

                            SizedBox(
                                height: AppTheme.getLargePadding(screenSize)),

                            // Status text
                            Text(
                              _isListening
                                  ? 'Listo para escanear'
                                  : 'Procesando...',
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Instruction text
                            Text(
                              _isListening
                                  ? 'Escanea un código QR con tu lector físico'
                                  : 'Espera un momento...',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            if (_isListening) ...[
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),

                              // Static scanning line indicator
                              Container(
                                width: 200,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: AppTheme.accentOrange.withOpacity(0.5),
                                ),
                              ),
                            ],

                            if (_currentInput.isNotEmpty) ...[
                              SizedBox(
                                  height: AppTheme.getLargePadding(screenSize)),

                              // Show current input being built
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppTheme.getMediumPadding(screenSize),
                                  vertical:
                                      AppTheme.getSmallPadding(screenSize),
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        AppTheme.accentOrange.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _currentInput,
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color: AppTheme.accentOrange,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Help text
                    Container(
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.getTextSecondaryColor(context)
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.getTextSecondaryColor(context)
                              .withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: AppTheme.getTextSecondaryColor(context),
                            size: 24,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            'Conecta tu lector de códigos QR USB o Bluetooth y escanea directamente. Los códigos aparecerán automáticamente.',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
