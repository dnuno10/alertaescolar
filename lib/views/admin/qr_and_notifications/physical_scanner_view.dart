import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class PhysicalScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;

  const PhysicalScannerView({
    super.key,
    required this.onCodeScanned,
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

  // Mock student data
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startListening();
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
  }

  void _startListening() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_isListening && mounted) {
        _simulateScan("EST${DateTime.now().millisecond}");
      }
    });
  }

  void _simulateScan(String code) {
    if (!_hasScanned) {
      HapticFeedback.lightImpact();

      setState(() {
        _hasScanned = true;
        _isListening = false;
        _scannedCode = code;
        _studentData = _generateMockStudentData(code);
      });

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
    }
  }

  Map<String, dynamic> _generateMockStudentData(String code) {
    final names = [
      'Ana García',
      'Carlos López',
      'María Rodríguez',
      'José Martín',
      'Sofía Hernández'
    ];
    final grades = ['5to Grado', '6to Grado', '4to Grado', '3er Grado'];
    final sections = ['A', 'B', 'C'];

    return {
      'name': names[DateTime.now().millisecond % names.length],
      'code': code,
      'grade': grades[DateTime.now().millisecond % grades.length],
      'section': sections[DateTime.now().millisecond % sections.length],
      'time': DateTime.now(),
      'status': 'Presente',
    };
  }

  void _hideStudentData() {
    _cardAnimationController.reverse().then((_) {
      _slideAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showStudentData = false;
            _hasScanned = false;
            _isListening = true;
            _scannedCode = null;
            _studentData = null;
          });
          _resetAnimations();
        }
      });
    });
  }

  void _resetAnimations() {
    _successAnimationController.reset();
    _pulseAnimationController.repeat(reverse: true);
    _scanLineAnimationController.repeat();
    _rotationAnimationController.repeat();
    _startListening();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: "Escáner Físico"),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
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
                                                      AppTheme.getMediumPadding(
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
                                              height: AppTheme.getMediumPadding(
                                                  screenSize)),

                                          // Student info header
                                          Text(
                                            'ESCANEO EXITOSO',
                                            style: AppTheme.getBodyMedium(
                                                    screenSize)
                                                .copyWith(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(
                                              height: AppTheme.getSmallPadding(
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
                                              height: AppTheme.getMediumPadding(
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
                                                      AppTheme.getMediumRadius(
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
                                                        _studentData!['grade'],
                                                        screenSize),
                                                    _buildDataItem(
                                                        'Sección',
                                                        _studentData![
                                                            'section'],
                                                        screenSize),
                                                    _buildDataItem(
                                                        'Estado',
                                                        _studentData!['status'],
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
                                              height: AppTheme.getMediumPadding(
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
                                              color:
                                                  Colors.white.withOpacity(0.1),
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

// ...existing code...
        ],
      ),
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
