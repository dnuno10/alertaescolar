import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../services/scanner_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/turno_provider.dart';

enum ProcessingDisplayMode { full, headless }

class ProcessingOutcome {
  final bool success;
  final String? message;
  final Map<String, dynamic>? student;
  final Map<String, dynamic>? access;

  const ProcessingOutcome({
    required this.success,
    this.message,
    this.student,
    this.access,
  });
}

class ProcessingView extends StatefulWidget {
  final String scannedCode;
  final String adminId;
  final String escuelaId;
  final ScannerAccessType accessType;
  final bool isDefaultEntryConfig;
  final bool isExtracurricular; // Nuevo parámetro

  /// Nuevo: modo de visualización. En headless no se muestran pantallas de resultado.
  final ProcessingDisplayMode displayMode;

  /// Nuevo: si true, hace Navigator.pop con ProcessingOutcome (detallado); si false, pop(bool).
  final bool returnDetailedResult;

  const ProcessingView({
    super.key,
    required this.scannedCode,
    required this.adminId,
    required this.escuelaId,
    required this.accessType,
    required this.isDefaultEntryConfig,
    this.isExtracurricular = false, // Por defecto falso
    this.displayMode = ProcessingDisplayMode.full,
    this.returnDetailedResult = false,
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

  bool _processingStarted = false;

  // Anti double-pop & timers cancelables
  bool _hasPopped = false;
  bool _disposed = false; // ⚡ OPTIMIZACIÓN: Prevenir múltiples dispose
  Timer? _autoPopTimer;

  void _startProcessingOnce() {
    if (_processingStarted) return;
    _processingStarted = true;
    _startProcessing();
  }

  // Animations
  late AnimationController _processingAnimationController;
  late AnimationController _resultAnimationController;
  late AnimationController _slideInAnimationController;
  late Animation<double> _processingFadeAnimation;
  late Animation<double> _processingRotationAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _overlayOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    Future.microtask(_startProcessingOnce);
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

    _processingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _processingAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _processingRotationAnimation =
        Tween<double>(begin: 0.0, end: 2.0).animate(CurvedAnimation(
      parent: _processingAnimationController,
      curve: Curves.linear,
    ));

    _resultScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutBack,
    ));

    _slideInAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _slideInAnimationController, curve: Curves.easeOutQuart),
    );

    _overlayOpacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _slideInAnimationController,
      curve: Curves.easeOut,
    ));

    _processingAnimationController.repeat();
  }

  /// Busca recursivamente un mensaje de error en cualquier estructura (Map/List/String)
  String? _digForError(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final s = data.trim();
      if (s.isNotEmpty) return s;
      return null;
    }
    if (data is Map) {
      const candidates = [
        'error',
        'message',
        'mensaje',
        'detail',
        'descripcion',
        'razon',
        'reason'
      ];
      for (final key in candidates) {
        if (data.containsKey(key)) {
          final val = _digForError(data[key]);
          if (val != null && val.isNotEmpty) return val;
        }
      }
      for (final v in data.values) {
        final val = _digForError(v);
        if (val != null && val.isNotEmpty) return val;
      }
      return null;
    }
    if (data is List) {
      for (final v in data) {
        final val = _digForError(v);
        if (val != null && val.isNotEmpty) return val;
      }
    }
    return null;
  }

  Future<void> _startProcessing() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      if (turnoProvider.currentEscuelaId != widget.escuelaId) {
        await turnoProvider.loadTurnos(escuelaId: widget.escuelaId);
      }

      final result = await _scannerService.processScannedCode(
        scannedCode: widget.scannedCode,
        adminId: widget.adminId,
        escuelaIdFromContext: widget.escuelaId,
        accessType: widget.accessType,
        isDefaultEntryConfig: widget.isDefaultEntryConfig,
        isExtracurricular: widget.isExtracurricular, // Nuevo parámetro
        turnoProvider: turnoProvider,
      );

      if (!mounted) return;
      _processingAnimationController.stop();

      // Construimos outcome detallado desde el resultado
      bool success = result['success'] == true;
      String? message;

      if (success) {
        _studentData = result['student'] as Map<String, dynamic>?;
        _accessData = result['access'] as Map<String, dynamic>?;
        message = result['access']?['message']?.toString();
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      } else {
        String? specificError = _digForError(result);
        if ((result['noop'] == true || result['success'] == true) &&
            result['reason'] != null) {
          switch (result['reason']) {
            case 'recentDuplicate':
              specificError ??=
                  'Este alumno ya fue escaneado hace menos de 1 minuto. Espera antes de volver a escanearlo.';
              break;
            case 'hardwareRebound':
              specificError ??=
                  'Se detectó un rebote del lector. Intenta nuevamente.';
              break;
          }
        }
        if (specificError == null || specificError.isEmpty) {
          final err = (result['error']?.toString() ?? '').trim();
          if (err.isNotEmpty) specificError = err;
        }
        message = (specificError != null && specificError.isNotEmpty)
            ? specificError
            : 'No fue posible determinar la causa. Revisa el log para más detalles.';
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
      }

      final outcome = ProcessingOutcome(
        success: success,
        message: message,
        student: _studentData,
        access: _accessData,
      );

      if (widget.displayMode == ProcessingDisplayMode.headless) {
        // HEADLESS: no UI de resultado; regresar inmediato.
        _return(outcome);
        return;
      }

      // FULL UI:
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = success;
        if (!success) _errorMessage = message;
      });

      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      // ⚡ OPTIMIZACIÓN: Auto-pop más rápido para mejorar la experiencia
      _autoPopTimer?.cancel();
      _autoPopTimer = Timer(Duration(milliseconds: success ? 800 : 1200), () {
        if (mounted) _return(outcome);
      });
    } catch (e) {
      if (!mounted) return;

      _processingAnimationController.stop();

      final errorString = e.toString();
      String? clean = _digForError(errorString);

      if (clean == null || clean.isEmpty) {
        if (errorString.contains('scanner_service') ||
            errorString.contains('ScannerService')) {
          clean =
              'Error en el servicio de escáner: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\s*'), '')}';
        } else if (errorString.contains('supabase') ||
            errorString.contains('database') ||
            errorString.contains('PostgrestException')) {
          clean =
              'Error de conexión con la base de datos: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\s*'), '')}';
        } else if (errorString.contains('network') ||
            errorString.contains('connection') ||
            errorString.contains('timeout')) {
          clean =
              'Error de conexión de red: ${errorString.replaceAll(RegExp(r'^(Exception:|Error:)\s*'), '')}';
        } else {
          clean = errorString
              .replaceAll(
                  RegExp(
                      r'^(Exception:|Error:|FormatException:|StateError:)\s*'),
                  '')
              .trim();
        }
      }

      final outcome = ProcessingOutcome(
        success: false,
        message: clean ?? AppLocalizations.of(context).errorProcessingCode,
      );

      if (widget.displayMode == ProcessingDisplayMode.headless) {
        _return(outcome);
        return;
      }

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _showResult = true;
        _isSuccess = false;
        _errorMessage = outcome.message;
      });

      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      _resultAnimationController.forward();
      _slideInAnimationController.forward();

      _autoPopTimer?.cancel();
      _autoPopTimer = Timer(const Duration(milliseconds: 1800), () {
        if (mounted) _return(outcome);
      });
    }
  }

  void _return(ProcessingOutcome outcome) {
    if (!mounted || _hasPopped) return;
    _hasPopped = true;

    final Object navResult =
        widget.returnDetailedResult ? outcome : outcome.success;

    // ⚡ OPTIMIZACIÓN: Detener animaciones de forma más suave para evitar conflictos con UiKitView
    _autoPopTimer?.cancel();

    try {
      if (_processingAnimationController.isAnimating) {
        _processingAnimationController.stop();
      }
      if (_resultAnimationController.isAnimating) {
        _resultAnimationController.stop();
      }
      if (_slideInAnimationController.isAnimating) {
        _slideInAnimationController.stop();
      }
    } catch (e) {
      debugPrint('ProcessingView: Animation stop error (ignored): $e');
    }

    // ⚡ OPTIMIZACIÓN: Delay mínimo para permitir que iOS libere recursos nativos
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(navResult);
      } else {
        debugPrint('ProcessingView: No route to pop, returning silently.');
      }
    });
  }

  @override
  void dispose() {
    if (_disposed) return; // ⚡ OPTIMIZACIÓN: Prevenir múltiples dispose
    _disposed = true;

    // ⚡ OPTIMIZACIÓN: Cancelar timers y detener animaciones de forma más robusta
    _autoPopTimer?.cancel();
    _autoPopTimer = null;

    // Detener animaciones de forma segura
    try {
      if (_processingAnimationController.isAnimating) {
        _processingAnimationController.stop();
      }
    } catch (e) {
      debugPrint('ProcessingView: Error stopping processing animation: $e');
    }

    try {
      if (_resultAnimationController.isAnimating) {
        _resultAnimationController.stop();
      }
    } catch (e) {
      debugPrint('ProcessingView: Error stopping result animation: $e');
    }

    try {
      if (_slideInAnimationController.isAnimating) {
        _slideInAnimationController.stop();
      }
    } catch (e) {
      debugPrint('ProcessingView: Error stopping slide animation: $e');
    }

    // Dispose controllers de forma segura
    try {
      _processingAnimationController.dispose();
    } catch (e) {
      debugPrint('ProcessingView: Error disposing processing controller: $e');
    }

    try {
      _resultAnimationController.dispose();
    } catch (e) {
      debugPrint('ProcessingView: Error disposing result controller: $e');
    }

    try {
      _slideInAnimationController.dispose();
    } catch (e) {
      debugPrint('ProcessingView: Error disposing slide controller: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayMode == ProcessingDisplayMode.headless) {
      // ➜ Usamos la misma vista de "Procesando" que ya incluye el
      //    recuadro "Código Escaneado", para que SIEMPRE se vea el código.
      final screenSize = MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _buildProcessingView(screenSize),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          if (_isProcessing) _buildProcessingView(screenSize),
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
                SizedBox(
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
                Text(
                  'Procesando',
                  style: AppTheme.getH1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: AppTheme.getMediumPadding(screenSize)),
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
                            child: const Icon(
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
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
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
                          Padding(
                            padding: EdgeInsets.all(
                                AppTheme.getMediumPadding(screenSize)),
                            child: Column(
                              children: [
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
                                _buildModernInfoCard(
                                  'Hora de Registro',
                                  _accessData != null
                                      ? _formatTime12h(
                                          DateTime.parse(_accessData!['time'])
                                              .toLocal())
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

  String _formatTime12h(DateTime dt) {
    final local = dt.toLocal();
    int hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:$minute $period';
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
                            ),
                            child: const Icon(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
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

    canvas.drawArc(
      rect,
      -1.57,
      4.71,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
