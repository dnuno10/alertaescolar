import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';

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
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseAnimationController;
  late AnimationController _scanLineAnimationController;
  late AnimationController _rotationAnimationController;
  late AnimationController _successAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _accessTypeAnimationController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardOpacityAnimation;

  bool _isListening = true;
  bool _hasScanned = false;
  bool _showStudentData = false;
  String? _scannedCode;
  String? _errorMessage;
  Map<String, dynamic>? _accessData; // Store access information

  // Scanner service
  final ScannerService _scannerService = ScannerService();

  // Student data from real scanning
  Map<String, dynamic>? _studentData;

  // Focus node and keyboard input handling for physical scanner
  final FocusNode _focusNode = FocusNode();
  String _currentInput = '';
  DateTime? _lastInputTime;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startListening();

    // Request focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _initAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanLineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _accessTypeAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineAnimationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationAnimationController,
      curve: Curves.linear,
    ));

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _cardOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));

    _pulseAnimationController.repeat(reverse: true);
    _scanLineAnimationController.repeat();
    _rotationAnimationController.repeat();
    _accessTypeAnimationController.repeat(reverse: true);
  }

  void _startListening() {
    // En un entorno real, aquí se configuraría el listener para el escáner físico
    // Por ahora, el método está preparado para recibir datos del escáner cuando esté conectado
    debugPrint('Physical scanner ready and listening for input...');
  }

  // Método público para ser llamado cuando el escáner físico detecte un código
  void onPhysicalScanReceived(String scannedCode) {
    if (_isListening && !_hasScanned && mounted) {
      _processScannedCode(scannedCode);
    }
  }

  /// Handle keyboard input from physical QR scanner
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      debugPrint('Key event received: ${event.logicalKey}');

      final currentTime = DateTime.now();

      // If too much time has passed since the last input, reset the current input
      if (_lastInputTime != null &&
          currentTime.difference(_lastInputTime!).inMilliseconds > 100) {
        debugPrint(
            'Resetting input due to timeout. Current input was: $_currentInput');
        setState(() {
          _currentInput = '';
        });
      }

      _lastInputTime = currentTime;

      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        // Enter key pressed - process the scanned code
        debugPrint('Enter key detected. Processing input: $_currentInput');
        if (_currentInput.isNotEmpty && _isListening && !_hasScanned) {
          debugPrint('Physical scanner input received: $_currentInput');
          _processScannedCode(_currentInput.trim());
        }
        setState(() {
          _currentInput = '';
        });
      } else if (event.character != null && event.character!.isNotEmpty) {
        // Regular character input
        setState(() {
          _currentInput += event.character!;
        });
        debugPrint('Building input: $_currentInput');
      }
    }
  }

  /// Process a scanned QR code using the scanner service
  Future<void> _processScannedCode(String code) async {
    if (_hasScanned) return;

    setState(() {
      _hasScanned = true;
      _isListening = false;
      _scannedCode = code;
    });

    try {
      // Get current user (admin) ID
      final userProvider = context.read<UserProvider>();
      final adminId = userProvider.currentUser?.id;

      if (adminId == null) {
        _showError('Error: Usuario no autenticado');
        return;
      }

      // Process the scanned code
      final result = await _scannerService.processScannedCode(
        scannedCode: code,
        adminId: adminId,
        accessType: widget.accessType ?? ScannerAccessType.automatic,
        isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
      );

      if (result['success']) {
        // Success - show student data and play animation
        setState(() {
          _studentData = result['student'];
          _accessData = result['access'];
        });

        HapticFeedback.lightImpact();
        _stopScanningAnimations();
        _successAnimationController.forward();
        widget.onCodeScanned(code);

        // Show slide animation and student data
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _slideAnimationController.forward();
            setState(() {
              _showStudentData = true;
            });
            _cardAnimationController.forward();
          }
        });

        // Hide student data after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _hideStudentData();
          }
        });
      } else {
        // Error - show error message
        _showError(result['error'] ?? 'Error desconocido');

        if (result['shouldTerminate'] == true) {
          // Critical error - return to previous screen
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          // Non-critical error - reset for next scan
          _resetForNextScan();
        }
      }
    } catch (e) {
      _showError('Error interno: $e');
      _resetForNextScan();
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetForNextScan() {
    _resetScanner();
  }

  /// Reset the scanner to listen for new codes
  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _isListening = true;
      _showStudentData = false;
      _scannedCode = null;
      _errorMessage = null;
      _studentData = null;
      _accessData = null;
      _currentInput = '';
      _lastInputTime = null;
    });

    // Reset animations
    _successAnimationController.reset();
    _slideAnimationController.reset();
    _cardAnimationController.reset();

    // Restart animations
    _startScanningAnimations();
    _startListening();

    // Request focus again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startScanningAnimations() {
    _pulseAnimationController.repeat(reverse: true);
    _scanLineAnimationController.repeat();
    _rotationAnimationController.repeat();
    _accessTypeAnimationController.repeat(reverse: true);
  }

  void _hideStudentData() {
    _cardAnimationController.reverse().then((_) {
      _slideAnimationController.reverse().then((_) {
        if (mounted) {
          _resetForNextScan();
        }
      });
    });
  }

  void _stopScanningAnimations() {
    _pulseAnimationController.stop();
    _scanLineAnimationController.stop();
    _rotationAnimationController.stop();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _scanLineAnimationController.dispose();
    _rotationAnimationController.dispose();
    _successAnimationController.dispose();
    _slideAnimationController.dispose();
    _cardAnimationController.dispose();
    _accessTypeAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getAccessTypeText() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry
            ? 'Modo Automático - Entrada'
            : 'Modo Automático - Salida';
      case ScannerAccessType.entry:
        return 'Entrada Fija';
      case ScannerAccessType.exit:
        return 'Salida Fija';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? AppTheme.successColor : AppTheme.errorColor;
      case ScannerAccessType.entry:
        return AppTheme.successColor;
      case ScannerAccessType.exit:
        return AppTheme.errorColor;
    }
  }

  IconData _getAccessTypeIcon() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Icons.login_rounded : Icons.logout_rounded;
      case ScannerAccessType.entry:
        return Icons.login_rounded;
      case ScannerAccessType.exit:
        return Icons.logout_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                NavHeader(title: "Escáner Físico"),

                // Clean Access Type Indicator
                SliverToBoxAdapter(
                  child: Container(
                    margin:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getAccessTypeColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Status indicator dot
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getAccessTypeColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getAccessTypeColor().withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppTheme.getMediumPadding(screenSize)),

                        // Access type info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Activo',
                                style: AppTheme.getCaptionSmall(screenSize)
                                    .copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                _getAccessTypeText(),
                                style:
                                    AppTheme.getBodyMedium(screenSize).copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Access type icon
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getAccessTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getAccessTypeIcon(),
                            color: _getAccessTypeColor(),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Status indicator with improved animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getLargePadding(screenSize),
                          vertical: AppTheme.getMediumPadding(screenSize),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _hasScanned
                                ? [
                                    Colors.green.withOpacity(0.15),
                                    Colors.green.withOpacity(0.08),
                                  ]
                                : [
                                    AppTheme.accentOrange.withOpacity(0.15),
                                    AppTheme.accentOrange.withOpacity(0.08),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _hasScanned
                                ? Colors.green.withOpacity(0.4)
                                : AppTheme.accentOrange.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_hasScanned)
                              AnimatedBuilder(
                                animation: _successScaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _successScaleAnimation.value,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 28,
                                    ),
                                  );
                                },
                              )
                            else
                              AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _rotationAnimation.value * 2 * 3.14159,
                                    child: Icon(
                                      Icons.bluetooth_searching_rounded,
                                      color: AppTheme.accentOrange,
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _hasScanned
                                    ? '¡Estudiante detectado!'
                                    : 'Esperando estudiante...',
                                key: ValueKey(_hasScanned),
                                style:
                                    AppTheme.getBodyLarge(screenSize).copyWith(
                                  color: _hasScanned
                                      ? Colors.green
                                      : AppTheme.accentOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: AppTheme.getLargePadding(screenSize) * 5),

                      // Enhanced scanner animation
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                              offset: Offset(0, _slideAnimation.value * -100),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _showStudentData ? 0.3 : 1.0,
                                child: Container(
                                  width: screenSize.width * 0.75,
                                  height: screenSize.width * 0.75,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Multiple pulse rings
                                      for (int i = 0; i < 3; i++)
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _pulseAnimation.value *
                                                  (1.0 - i * 0.15),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.accentOrange
                                                        .withOpacity(
                                                            0.2 + i * 0.1),
                                                    width: 2.0 + i,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                      // Inner scanner area with gradient
                                      Container(
                                        width: screenSize.width * 0.5,
                                        height: screenSize.width * 0.5,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: _hasScanned
                                                ? [
                                                    Colors.green
                                                        .withOpacity(0.2),
                                                    Colors.green
                                                        .withOpacity(0.1),
                                                    Colors.green
                                                        .withOpacity(0.05),
                                                    Colors.transparent,
                                                  ]
                                                : [
                                                    AppTheme.accentOrange
                                                        .withOpacity(0.2),
                                                    AppTheme.accentOrange
                                                        .withOpacity(0.1),
                                                    AppTheme.accentOrange
                                                        .withOpacity(0.05),
                                                    Colors.transparent,
                                                  ],
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _hasScanned
                                                ? Colors.green
                                                : AppTheme.accentOrange,
                                            width: 4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_hasScanned
                                                      ? Colors.green
                                                      : AppTheme.accentOrange)
                                                  .withOpacity(0.2),
                                              blurRadius: 20,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Main icon with animation
                                            Center(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                child: _hasScanned
                                                    ? AnimatedBuilder(
                                                        animation:
                                                            _successScaleAnimation,
                                                        builder:
                                                            (context, child) {
                                                          return Transform
                                                              .scale(
                                                            scale:
                                                                _successScaleAnimation
                                                                    .value,
                                                            child: Icon(
                                                              Icons
                                                                  .person_add_alt_1,
                                                              key: const ValueKey(
                                                                  'success'),
                                                              size: screenSize
                                                                      .width *
                                                                  0.18,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .qr_code_scanner_rounded,
                                                        key: const ValueKey(
                                                            'scanning'),
                                                        size: screenSize.width *
                                                            0.18,
                                                        color: AppTheme
                                                            .accentOrange,
                                                      ),
                                              ),
                                            ),

                                            if (!_hasScanned)
                                              AnimatedBuilder(
                                                animation: _scanLineAnimation,
                                                builder: (context, child) {
                                                  return Positioned(
                                                    top: (screenSize.width *
                                                                    0.55 -
                                                                60) *
                                                            _scanLineAnimation
                                                                .value +
                                                        30,
                                                    left: 40,
                                                    right: 40,
                                                    child: Container(
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.transparent,
                                                            AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.5),
                                                            AppTheme
                                                                .accentOrange,
                                                            AppTheme
                                                                .accentOrange,
                                                            AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.5),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .accentOrange
                                                                .withOpacity(
                                                                    0.8),
                                                            blurRadius: 15,
                                                            spreadRadius: 3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),

                      SizedBox(
                          height: AppTheme.getLargePadding(screenSize) * 2),

                      // Enhanced connection status
                      if (!_hasScanned)
                        Container(
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentOrange.withOpacity(0.1),
                                AppTheme.accentOrange.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize)),
                            border: Border.all(
                              color: AppTheme.accentOrange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.7 + (0.6 * _pulseAnimation.value),
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentOrange,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentOrange
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                  width: AppTheme.getMediumPadding(screenSize)),
                              Expanded(
                                child: Text(
                                  'Dispositivo listo • Escuchando escáner...',
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color: AppTheme.accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Student data overlay - Fixed positioning to prevent overflow

            if (_showStudentData && _studentData != null)
              AnimatedBuilder(
                animation: _cardSlideAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.3), // Semi-transparent backdrop
                      child: AnimatedBuilder(
                        animation: _cardOpacityAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _cardOpacityAnimation.value,
                            child: Column(
                              children: [
                                // Spacer to push content down
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _hideStudentData(), // Optional: tap to close
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // Student data card
                                Expanded(
                                  flex: 3,
                                  child: Transform.translate(
                                    offset: Offset(
                                        0, _cardSlideAnimation.value * 500),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          AppTheme.getLargePadding(screenSize)),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.green.withOpacity(0.95),
                                            Colors.green.shade600
                                                .withOpacity(0.95),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              AppTheme.getLargeRadius(
                                                      screenSize) *
                                                  1.5),
                                          topRight: Radius.circular(
                                              AppTheme.getLargeRadius(
                                                      screenSize) *
                                                  1.5),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Success animation icon
                                            AnimatedBuilder(
                                              animation: _successScaleAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _successScaleAnimation
                                                              .value *
                                                          0.8 +
                                                      0.2,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        AppTheme
                                                            .getMediumPadding(
                                                                screenSize)),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.qr_code_2_rounded,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Student info header
                                            Text(
                                              'ESCANEO EXITOSO',
                                              style: AppTheme.getBodyMedium(
                                                      screenSize)
                                                  .copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                        screenSize)),

                                            // Student name
                                            Text(
                                              _studentData!['name'],
                                              style: AppTheme.getH1(screenSize)
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    screenSize.height * 0.028,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Student details
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(
                                                  AppTheme.getMediumPadding(
                                                      screenSize)),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme
                                                            .getMediumRadius(
                                                                screenSize)),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildDataItem(
                                                          'Grado',
                                                          _studentData![
                                                              'grade'],
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Sección',
                                                          _studentData![
                                                              'section'],
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Estado',
                                                          _studentData![
                                                              'status'],
                                                          screenSize),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: AppTheme
                                                          .getMediumPadding(
                                                              screenSize)),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildDataItem(
                                                          'Código',
                                                          _studentData!['code'],
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Hora',
                                                          '${_studentData!['time'].hour}:${_studentData!['time'].minute.toString().padLeft(2, '0')}',
                                                          screenSize),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Continue scanning hint
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppTheme.getMediumPadding(
                                                        screenSize),
                                                vertical:
                                                    AppTheme.getSmallPadding(
                                                        screenSize),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Listo para el siguiente estudiante',
                                                style: AppTheme.getBodyMedium(
                                                        screenSize)
                                                    .copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

            // Student data overlay - Fixed positioning to prevent overflow
            if (_showStudentData && _studentData != null)
              AnimatedBuilder(
                animation: _cardSlideAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.3), // Semi-transparent backdrop
                      child: AnimatedBuilder(
                        animation: _cardOpacityAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _cardOpacityAnimation.value,
                            child: Column(
                              children: [
                                // Spacer to push content down
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _hideStudentData(), // Optional: tap to close
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // Student data card
                                Expanded(
                                  flex: 3,
                                  child: Transform.translate(
                                    offset: Offset(
                                        0, _cardSlideAnimation.value * 500),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          AppTheme.getLargePadding(screenSize)),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.green.withOpacity(0.95),
                                            Colors.green.shade600
                                                .withOpacity(0.95),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              AppTheme.getLargeRadius(
                                                      screenSize) *
                                                  1.5),
                                          topRight: Radius.circular(
                                              AppTheme.getLargeRadius(
                                                      screenSize) *
                                                  1.5),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Success animation icon
                                            AnimatedBuilder(
                                              animation: _successScaleAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _successScaleAnimation
                                                              .value *
                                                          0.8 +
                                                      0.2,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        AppTheme
                                                            .getMediumPadding(
                                                                screenSize)),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.qr_code_2_rounded,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Student info header
                                            Text(
                                              'ESCANEO EXITOSO',
                                              style: AppTheme.getBodyMedium(
                                                      screenSize)
                                                  .copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                        screenSize)),

                                            // Student name (REAL DATA)
                                            Text(
                                              _studentData!['name'] ??
                                                  'Sin nombre',
                                              style: AppTheme.getH1(screenSize)
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    screenSize.height * 0.028,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Student details (REAL DATA)
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(
                                                  AppTheme.getMediumPadding(
                                                      screenSize)),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme
                                                            .getMediumRadius(
                                                                screenSize)),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildDataItem(
                                                          'Grupo',
                                                          _studentData![
                                                                  'grupo'] ??
                                                              'N/A',
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Nivel',
                                                          _studentData![
                                                                  'nivel'] ??
                                                              'N/A',
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Turno',
                                                          _studentData![
                                                                  'turno'] ??
                                                              'N/A',
                                                          screenSize),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: AppTheme
                                                          .getMediumPadding(
                                                              screenSize)),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildDataItem(
                                                          'Matrícula',
                                                          _studentData![
                                                                  'matricula'] ??
                                                              'N/A',
                                                          screenSize),
                                                      _buildDataItem(
                                                          'Hora',
                                                          _accessData != null
                                                              ? DateTime.parse(
                                                                      _accessData![
                                                                          'time'])
                                                                  .toString()
                                                                  .substring(
                                                                      11, 16)
                                                              : 'N/A',
                                                          screenSize),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: AppTheme
                                                          .getMediumPadding(
                                                              screenSize)),
                                                  // Estado/tipo de acceso (REAL DATA)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: AppTheme
                                                          .getMediumPadding(
                                                              screenSize),
                                                      vertical: AppTheme
                                                          .getSmallPadding(
                                                              screenSize),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (_accessData !=
                                                                  null &&
                                                              _accessData![
                                                                      'isLate'] ==
                                                                  true)
                                                          ? Colors.orange
                                                              .withOpacity(0.2)
                                                          : Colors.green
                                                              .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          (_accessData !=
                                                                      null &&
                                                                  _accessData![
                                                                          'isLate'] ==
                                                                      true)
                                                              ? Icons.schedule
                                                              : Icons
                                                                  .check_circle,
                                                          color: (_accessData !=
                                                                      null &&
                                                                  _accessData![
                                                                          'isLate'] ==
                                                                      true)
                                                              ? Colors.orange
                                                              : Colors.green,
                                                          size: 16,
                                                        ),
                                                        SizedBox(
                                                            width: AppTheme
                                                                .getSmallPadding(
                                                                    screenSize)),
                                                        Text(
                                                          _accessData != null &&
                                                                  _accessData![
                                                                          'message'] !=
                                                                      null
                                                              ? _accessData![
                                                                  'message']
                                                              : 'Asistencia registrada',
                                                          style: AppTheme
                                                                  .getBodyMedium(
                                                                      screenSize)
                                                              .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(
                                                height:
                                                    AppTheme.getMediumPadding(
                                                        screenSize)),

                                            // Continue scanning hint
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppTheme.getMediumPadding(
                                                        screenSize),
                                                vertical:
                                                    AppTheme.getSmallPadding(
                                                        screenSize),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Listo para el siguiente estudiante',
                                                style: AppTheme.getBodyMedium(
                                                        screenSize)
                                                    .copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ), // Close Focus widget
    );
  }

  Widget _buildDataItem(String label, String value, Size screenSize) {
    return Flexible(
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenSize.height * 0.014,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
