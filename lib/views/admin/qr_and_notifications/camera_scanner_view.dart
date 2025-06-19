import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class CameraScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;

  const CameraScannerView({
    super.key,
    required this.onCodeScanned,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with TickerProviderStateMixin {
  QRViewController? _controller;
  bool _flashOn = false;
  bool _hasScanned = false;
  bool _showStudentData = false;
  String? _scannedCode;
  Map<String, dynamic>? _studentData;

  // Animation controllers
  late AnimationController _successAnimationController;
  late AnimationController _slideInAnimationController;

  late Animation<double> _successScaleAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _overlayOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _simulateDelayedScan();
  }

  void _initAnimations() {
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideInAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _overlayOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _slideInAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _simulateDelayedScan() {
    // Simulate scanning after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasScanned && mounted) {
        _simulateScan("EST${DateTime.now().millisecond}");
      }
    });
  }

  void _simulateScan(String code) {
    if (!_hasScanned) {
      HapticFeedback.mediumImpact();

      setState(() {
        _hasScanned = true;
        _scannedCode = code;
        _studentData = _generateMockStudentData(code);
      });

      _successAnimationController.forward();
      widget.onCodeScanned(code);

      // Show student data overlay from the side
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showStudentData = true;
          });
          _slideInAnimationController.forward();
        }
      });

      // Hide after 3 seconds and reset for next scan (don't close)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _slideInAnimationController.reverse().then((_) {
            _resetForNextScan();
          });
        }
      });
    }
  }

  void _resetForNextScan() {
    setState(() {
      _hasScanned = false;
      _showStudentData = false;
      _scannedCode = null;
      _studentData = null;
    });

    _successAnimationController.reset();
    _slideInAnimationController.reset();

    // Start next scan simulation
    _simulateDelayedScan();
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

  @override
  void dispose() {
    _controller?.dispose();
    _successAnimationController.dispose();
    _slideInAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Clean QR Camera View - No overlays
          QRView(
            key: GlobalKey(debugLabel: 'QR'),
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: _hasScanned ? Colors.green : AppTheme.accentBlue,
              borderRadius: 24,
              borderLength: 80,
              borderWidth: 4,
              cutOutSize: screenSize.width * 0.7,
            ),
          ),

          // Minimal top controls - positioned to not interfere with camera
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  _buildControlButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.close_rounded,
                    backgroundColor: Colors.black.withOpacity(0.7),
                  ),

                  // Status indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize),
                    ),
                    decoration: BoxDecoration(
                      color: _hasScanned
                          ? Colors.green.withOpacity(0.9)
                          : AppTheme.accentBlue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
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
                                  color: Colors.white,
                                  size: 16,
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Text(
                          _hasScanned ? 'Detectado' : 'Escaneando',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flash toggle
                  _buildControlButton(
                    onPressed: _toggleFlash,
                    icon: _flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    backgroundColor: _flashOn
                        ? AppTheme.accentOrange.withOpacity(0.9)
                        : Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instructions - Clean and minimal
          if (!_hasScanned)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: AppTheme.accentBlue,
                        size: 32,
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      Text(
                        'Escanear código QR',
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        'Posiciona el código QR del estudiante\ndentro del marco',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Student data overlay - Slides in from the right with fixed overflow
          if (_showStudentData && _studentData != null)
            AnimatedBuilder(
              animation: _overlayOpacityAnimation,
              builder: (context, child) {
                return Container(
                  color:
                      Colors.black.withOpacity(_overlayOpacityAnimation.value),
                  child: SlideTransition(
                    position: _slideInAnimation,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: screenSize.width * 0.9,
                        height: screenSize.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green,
                              Colors.green.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(
                                AppTheme.getLargePadding(screenSize)),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: screenSize.height -
                                    MediaQuery.of(context).padding.top -
                                    MediaQuery.of(context).padding.bottom,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Success icon
                                  AnimatedBuilder(
                                    animation: _successScaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale:
                                            _successScaleAnimation.value * 0.8 +
                                                0.2,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
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
                                          AppTheme.getLargePadding(screenSize)),

                                  // Header
                                  Text(
                                    'ESCANEO EXITOSO',
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(
                                      height:
                                          AppTheme.getSmallPadding(screenSize)),

                                  // Student name
                                  Text(
                                    _studentData!['name'],
                                    style: AppTheme.getH1(screenSize).copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenSize.height * 0.028,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(
                                      height:
                                          AppTheme.getLargePadding(screenSize)),

                                  // Student details in a clean grid
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
                                        AppTheme.getMediumPadding(screenSize)),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildDetailRow(
                                          'Grado',
                                          _studentData!['grade'],
                                          'Sección',
                                          _studentData!['section'],
                                          screenSize,
                                        ),
                                        SizedBox(
                                            height: AppTheme.getMediumPadding(
                                                screenSize)),
                                        _buildDetailRow(
                                          'Estado',
                                          _studentData!['status'],
                                          'Código',
                                          _studentData!['code'],
                                          screenSize,
                                        ),
                                        SizedBox(
                                            height: AppTheme.getMediumPadding(
                                                screenSize)),
                                        _buildSingleDetail(
                                          'Hora de escaneo',
                                          '${_studentData!['time'].hour.toString().padLeft(2, '0')}:${_studentData!['time'].minute.toString().padLeft(2, '0')}',
                                          screenSize,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                      height:
                                          AppTheme.getLargePadding(screenSize)),

                                  // Success message
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppTheme.getMediumPadding(screenSize),
                                      vertical:
                                          AppTheme.getSmallPadding(screenSize),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(
                                            width: AppTheme.getSmallPadding(
                                                screenSize)),
                                        Flexible(
                                          child: Text(
                                            'Asistencia registrada',
                                            style: AppTheme.getBodyMedium(
                                                    screenSize)
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                                          AppTheme.getMediumPadding(screenSize),
                                      vertical:
                                          AppTheme.getSmallPadding(screenSize),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Listo para escanear el siguiente estudiante',
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: Colors.white.withOpacity(0.8),
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
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label1, String value1, String label2,
      String value2, Size screenSize) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleDetail(label1, value1, screenSize),
        ),
        SizedBox(width: AppTheme.getMediumPadding(screenSize)),
        Expanded(
          child: _buildSingleDetail(label2, value2, screenSize),
        ),
      ],
    );
  }

  Widget _buildSingleDetail(String label, String value, Size screenSize) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) / 2),
        Text(
          value,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenSize.height * 0.016,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_hasScanned && scanData.code != null && scanData.code!.isNotEmpty) {
        _simulateScan(scanData.code!);
      }
    });
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    }
  }
}
