import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../services/scanner_service.dart';
import '../../../l10n/app_localizations.dart';

class ProcessingView extends StatefulWidget {
  final String scannedCode;
  final String adminId;
  final ScannerAccessType accessType;
  final bool isDefaultEntryConfig;

  const ProcessingView({
    super.key,
    required this.scannedCode,
    required this.adminId,
    required this.accessType,
    required this.isDefaultEntryConfig,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView>
    with TickerProviderStateMixin {
  final ScannerService _scannerService = ScannerService();

  bool _isProcessing = true;
  bool _showResult = false;
  bool _isSuccess = false;
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _accessData;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _processingAnimationController;
  late AnimationController _resultAnimationController;
  late AnimationController _slideInAnimationController;

  // Processing animations
  late Animation<double> _processingFadeAnimation;
  late Animation<double> _processingRotationAnimation;

  // Result animations
  late Animation<double> _resultScaleAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _overlayOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startProcessing();
  }

  void _initAnimations() {
    _processingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideInAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Processing animations
    _processingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingAnimationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    _processingRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _processingAnimationController,
      curve: Curves.linear,
    ));

    // Result animations
    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutBack,
    ));

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _overlayOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideInAnimationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _startProcessing() async {
    final l10n = AppLocalizations.of(context);
    // Start processing animation
    _processingAnimationController.repeat();

    try {
      // Process the scanned code
      final result = await _scannerService.processScannedCode(
        scannedCode: widget.scannedCode,
        adminId: widget.adminId,
        accessType: widget.accessType,
        isDefaultEntryConfig: widget.isDefaultEntryConfig,
      );

      // Stop processing animation
      _processingAnimationController.stop();

      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = result['success'];

        if (_isSuccess) {
          _studentData = result['student'];
          _accessData = result['access'];
          HapticFeedback.mediumImpact();
        } else {
          _errorMessage = result['error'] ?? l10n.unknownError;
          HapticFeedback.heavyImpact();
        }
      });

      // Start result animations
      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      // Auto-return after showing result
      Future.delayed(Duration(seconds: _isSuccess ? 2 : 3), () {
        if (mounted) {
          _returnToScanner();
        }
      });
    } catch (e) {
      // Stop processing animation on error
      _processingAnimationController.stop();

      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = false;
        _errorMessage = l10n.internalError(e.toString());
      });

      HapticFeedback.heavyImpact();

      // Start error result animations
      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      // Auto-return after showing error
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _returnToScanner();
        }
      });
    }
  }

  void _returnToScanner() {
    Navigator.of(context).pop(_isSuccess);
  }

  @override
  void dispose() {
    _processingAnimationController.dispose();
    _resultAnimationController.dispose();
    _slideInAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Processing View
          if (_isProcessing) _buildProcessingView(screenSize),

          // Result View (Success or Error)
          if (_showResult) _buildResultView(screenSize),
        ],
      ),
    );
  }

  Widget _buildProcessingView(Size screenSize) {
    return AnimatedBuilder(
      animation: _processingFadeAnimation,
      builder: (context, child) {
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean animated loading circle
                Container(
                  width: 80,
                  height: 80,
                  child: AnimatedBuilder(
                    animation: _processingRotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _processingRotationAnimation.value * 2 * math.pi,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentOrange,
                              width: 3,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ArcPainter(
                              color: AppTheme.accentOrange,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),

                // Simple title
                Text(
                  'Procesando',
                  style: AppTheme.getH1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Scanned code in minimal design
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getLargePadding(screenSize),
                    vertical: AppTheme.getMediumPadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentOrange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Código Escaneado",
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.accentOrange.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        widget.scannedCode,
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultView(Size screenSize) {
    if (_isSuccess && _studentData != null) {
      return _buildSuccessView(screenSize);
    } else {
      return _buildErrorView(screenSize);
    }
  }

  Widget _buildSuccessView(Size screenSize) {
    return AnimatedBuilder(
      animation: _overlayOpacityAnimation,
      builder: (context, child) {
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.withOpacity(_overlayOpacityAnimation.value),
                Colors.green.shade700
                    .withOpacity(_overlayOpacityAnimation.value),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getLargePadding(screenSize),
                vertical: AppTheme.getMediumPadding(screenSize),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon with enhanced animation
                  SlideTransition(
                    position: _slideInAnimation,
                    child: AnimatedBuilder(
                      animation: _resultScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _resultScaleAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Success message
                  SlideTransition(
                    position: _slideInAnimation,
                    child: Text(
                      'Escaneo Exitoso',
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.0,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Student name with enhanced styling
                  SlideTransition(
                    position: _slideInAnimation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getLargePadding(screenSize),
                        vertical: AppTheme.getMediumPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Estudiante',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            _studentData!['name'] ?? 'N/A',
                            style: AppTheme.getH1(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  SlideTransition(
                    position: _slideInAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header with Matrícula destacada
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'MATRÍCULA',
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize) /
                                            2),
                                Text(
                                  _studentData!['matricula'] ?? 'N/A',
                                  style: AppTheme.getH1(screenSize).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    letterSpacing: 2.0,
                                    fontFamily: 'monospace',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Grid de información académica
                          Padding(
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            child: Column(
                              children: [
                                // Primera fila: Grado y Nivel
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildModernInfoCard(
                                        'Grado',
                                        _studentData!['grupo'] ?? 'N/A',
                                        Icons.school_outlined,
                                        screenSize,
                                      ),
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                            screenSize)),
                                    Expanded(
                                      child: _buildModernInfoCard(
                                        'Nivel',
                                        _studentData!['nivel'] ?? 'N/A',
                                        Icons.stairs_outlined,
                                        screenSize,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize)),

                                // Segunda fila: Turno
                                _buildModernInfoCard(
                                  'Turno',
                                  _studentData!['turno'] ?? 'N/A',
                                  Icons.schedule_outlined,
                                  screenSize,
                                  isFullWidth: true,
                                ),

                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize)),

                                // Tercera fila: Hora de registro
                                _buildModernInfoCard(
                                  'Hora de Registro',
                                  _accessData != null
                                      ? DateTime.parse(_accessData!['time'])
                                          .toLocal()
                                          .toString()
                                          .substring(11, 16)
                                      : 'N/A',
                                  Icons.access_time_filled,
                                  screenSize,
                                  isFullWidth: true,
                                  isHighlighted: true,
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
          ),
        );
      },
    );
  }

  Widget _buildErrorView(Size screenSize) {
    return AnimatedBuilder(
      animation: _overlayOpacityAnimation,
      builder: (context, child) {
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.withOpacity(_overlayOpacityAnimation.value),
                Colors.red.shade700.withOpacity(_overlayOpacityAnimation.value),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getLargePadding(screenSize),
                vertical: AppTheme.getMediumPadding(screenSize),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error icon with enhanced animation
                  SlideTransition(
                    position: _slideInAnimation,
                    child: AnimatedBuilder(
                      animation: _resultScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _resultScaleAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Error message
                  SlideTransition(
                    position: _slideInAnimation,
                    child: Text(
                      'Error de Escaneo',
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.0,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Error details with enhanced styling
                  SlideTransition(
                    position: _slideInAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getLargePadding(screenSize),
                        vertical: AppTheme.getMediumPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 24,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            _errorMessage ?? 'Error desconocido',
                            style: AppTheme.getH2(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.getLargePadding(screenSize)),

                  // Scanned code display
                  SlideTransition(
                    position: _slideInAnimation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Código Escaneado',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize) / 2),
                          Text(
                            widget.scannedCode,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernInfoCard(
    String label,
    String value,
    IconData icon,
    Size screenSize, {
    bool isFullWidth = false,
    bool isHighlighted = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(screenSize),
        vertical: AppTheme.getSmallPadding(screenSize) * 1.2,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono y label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) / 2),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) / 2),

          // Valor
          Text(
            value,
            style: AppTheme.getH2(screenSize).copyWith(
              color: Colors.white,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              fontSize: isHighlighted ? 18 : 16,
              letterSpacing: isHighlighted ? 1.0 : 0.3,
              fontFamily: isHighlighted ? 'monospace' : null,
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

// Custom painter for arc progress
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Draw arc (3/4 circle for modern look)
    canvas.drawArc(
      rect,
      -1.57, // Start from top (-90 degrees in radians)
      4.71, // Draw 3/4 circle (270 degrees in radians)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
