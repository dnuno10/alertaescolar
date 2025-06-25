import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
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

class _PhysicalScannerViewState extends State<PhysicalScannerView>
    with SingleTickerProviderStateMixin {
  bool _isListening = true;
  bool _hasScanned = false;

  // Focus node and keyboard input handling for physical scanner
  final FocusNode _focusNode = FocusNode();
  String _currentInput = '';
  DateTime? _lastInputTime;

  // Single animation controller for smooth listening effect
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize smooth animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Pulse animation for the icon (subtle)
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Scan line animation (smooth horizontal movement)
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation if listening
    if (_isListening) {
      _animationController.repeat(reverse: true);
    }

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
    final l10n = AppLocalizations.of(context);

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? l10n.automaticEntry : l10n.automaticExit;
      case ScannerAccessType.entry:
        return l10n.entry;
      case ScannerAccessType.exit:
        return l10n.exit;
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

    // Pause animation during processing
    _animationController.stop();

    // Get current user (admin) ID
    final userProvider = context.read<UserProvider>();
    final adminId = userProvider.currentUser?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).unauthenticatedUser),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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

      // Restart animation smoothly when ready to listen again
      if (_isListening) {
        _animationController.repeat(reverse: true);
      }

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
    _animationController.dispose();
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
          physics: const NeverScrollableScrollPhysics(),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (_isListening) ...[
                              // Enhanced animated scanning area with corrected opacity values
                              Container(
                                width: 280,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        AppTheme.accentOrange.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  color:
                                      AppTheme.accentOrange.withOpacity(0.03),
                                ),
                                child: Stack(
                                  children: [
                                    // Corner indicators with clamped opacity values
                                    ...List.generate(4, (index) {
                                      return AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) {
                                          final opacityValue = (0.3 +
                                                  (0.4 * _pulseAnimation.value))
                                              .clamp(0.0, 1.0);
                                          return Positioned(
                                            top: index < 2 ? 8 : null,
                                            bottom: index >= 2 ? 8 : null,
                                            left: index % 2 == 0 ? 8 : null,
                                            right: index % 2 == 1 ? 8 : null,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: index < 2
                                                      ? BorderSide(
                                                          color: AppTheme
                                                              .accentOrange
                                                              .withOpacity(
                                                                  opacityValue),
                                                          width: 3,
                                                        )
                                                      : BorderSide.none,
                                                  bottom: index >= 2
                                                      ? BorderSide(
                                                          color: AppTheme
                                                              .accentOrange
                                                              .withOpacity(
                                                                  opacityValue),
                                                          width: 3,
                                                        )
                                                      : BorderSide.none,
                                                  left: index % 2 == 0
                                                      ? BorderSide(
                                                          color: AppTheme
                                                              .accentOrange
                                                              .withOpacity(
                                                                  opacityValue),
                                                          width: 3,
                                                        )
                                                      : BorderSide.none,
                                                  right: index % 2 == 1
                                                      ? BorderSide(
                                                          color: AppTheme
                                                              .accentOrange
                                                              .withOpacity(
                                                                  opacityValue),
                                                          width: 3,
                                                        )
                                                      : BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }),

                                    // Main scanning line with enhanced effects
                                    Center(
                                      child: Container(
                                        width: 240,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: AppTheme.accentOrange
                                              .withOpacity(0.1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.accentOrange
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _scanAnimation,
                                          builder: (context, child) {
                                            return Stack(
                                              children: [
                                                // Main scanning beam
                                                Align(
                                                  alignment: Alignment(
                                                    -1 +
                                                        (2 *
                                                            _scanAnimation
                                                                .value),
                                                    0,
                                                  ),
                                                  child: Container(
                                                    width: 80,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.0),
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.3),
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.8),
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.8),
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.3),
                                                          AppTheme.accentOrange
                                                              .withOpacity(0.0),
                                                        ],
                                                        stops: const [
                                                          0.0,
                                                          0.2,
                                                          0.4,
                                                          0.6,
                                                          0.8,
                                                          1.0
                                                        ],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppTheme
                                                              .accentOrange
                                                              .withOpacity(0.4),
                                                          blurRadius: 12,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // Leading light effect
                                                Align(
                                                  alignment: Alignment(
                                                    -1 +
                                                        (2 *
                                                            _scanAnimation
                                                                .value),
                                                    0,
                                                  ),
                                                  child: Transform.translate(
                                                    offset: const Offset(40, 0),
                                                    child: Container(
                                                      width: 20,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        gradient:
                                                            RadialGradient(
                                                          colors: [
                                                            AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.8),
                                                            AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.3),
                                                            AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.0),
                                                          ],
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.5),
                                                            blurRadius: 15,
                                                            spreadRadius: 3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Trailing particles effect
                                                ...List.generate(3, (index) {
                                                  return Align(
                                                    alignment: Alignment(
                                                      -1 +
                                                          (2 *
                                                              _scanAnimation
                                                                  .value),
                                                      0,
                                                    ),
                                                    child: Transform.translate(
                                                      offset: Offset(
                                                          -20.0 - (index * 8),
                                                          0),
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            _pulseAnimation,
                                                        builder:
                                                            (context, child) {
                                                          final particleOpacity = ((0.6 -
                                                                      (index *
                                                                          0.15)) *
                                                                  _pulseAnimation
                                                                      .value)
                                                              .clamp(0.0, 1.0);
                                                          return Container(
                                                            width: 4 -
                                                                (index * 0.5),
                                                            height: 4 -
                                                                (index * 0.5),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: AppTheme
                                                                  .accentOrange
                                                                  .withOpacity(
                                                                      particleOpacity),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: AppTheme
                                                                      .accentOrange
                                                                      .withOpacity(
                                                                          particleOpacity *
                                                                              0.5),
                                                                  blurRadius: 6,
                                                                  spreadRadius:
                                                                      1,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // Data stream lines
                                    ...List.generate(2, (index) {
                                      return Positioned(
                                        top: 35 + (index * 45),
                                        left: 20,
                                        right: 20,
                                        child: AnimatedBuilder(
                                          animation: _scanAnimation,
                                          builder: (context, child) {
                                            final offset =
                                                (_scanAnimation.value +
                                                        (index * 0.3)) %
                                                    1.0;
                                            return Row(
                                              children:
                                                  List.generate(8, (dotIndex) {
                                                final dotOpacity = (offset >
                                                            (dotIndex / 8) &&
                                                        offset <
                                                            ((dotIndex + 2) /
                                                                8))
                                                    ? 0.6
                                                    : 0.1;
                                                return Expanded(
                                                  child: Center(
                                                    child: Container(
                                                      width: 3,
                                                      height: 3,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppTheme
                                                            .accentOrange
                                                            .withOpacity(
                                                                dotOpacity),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      );
                                    }),

                                    // Central focus indicator
                                    Center(
                                      child: AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) {
                                          final borderOpacity = (0.3 +
                                                  (0.4 * _pulseAnimation.value))
                                              .clamp(0.0, 1.0);
                                          final fillOpacity = (0.1 +
                                                  (0.2 * _pulseAnimation.value))
                                              .clamp(0.0, 1.0);
                                          final iconOpacity = (0.5 +
                                                  (0.3 * _pulseAnimation.value))
                                              .clamp(0.0, 1.0);

                                          return Container(
                                            width:
                                                100, // Increased from 40 to 60
                                            height:
                                                100, // Increased from 40 to 60
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppTheme.accentOrange
                                                    .withOpacity(borderOpacity),
                                                width:
                                                    3, // Increased border width from 2 to 3
                                              ),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(
                                                  10), // Increased margin from 8 to 10
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.accentOrange
                                                    .withOpacity(fillOpacity),
                                              ),
                                              child: Icon(
                                                Icons.qr_code_2,
                                                size:
                                                    49, // Increased icon size from 16 to 28
                                                color: AppTheme.accentOrange
                                                    .withOpacity(iconOpacity),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
