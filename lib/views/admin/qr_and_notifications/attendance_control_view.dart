// lib/components/admin/qr_and_notifications/attendance_control_view.dart
// Modo automático alineado a TurnoProvider.resolveAccessPhase()
// SIN SOMBRAS en la UI principal.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../components/admin/qr_and_notifications/attendance_control_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/turno_provider.dart';

import '../../../managers/user_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/scanner_service.dart';
import '../../../widgets/custom_snack_bar.dart';

import 'camera_scanner_view.dart';
import 'notification_send_view.dart';
import 'physical_scanner_view.dart';
import 'scanner_configuration_view.dart';

class AttendanceControlView extends StatefulWidget {
  const AttendanceControlView({super.key});

  @override
  State<AttendanceControlView> createState() => _AttendanceControlViewState();
}

class _AttendanceControlViewState extends State<AttendanceControlView> {
  // --- Config local (tokens de UI; horas reales llegan de TurnoProvider) ---
  TimeOfDay _turnoAStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _turnoAEnd = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _turnoBStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _turnoBEnd = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 10;

  // Control de acceso
  AccessType _selectedAccessType = AccessType.default_config;
  bool _isDefaultEntryConfig = true; // true=Entrada, false=Salida (auto)

  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;

  // Timer para modo automático
  Timer? _accessTypeTimer;

  // Track de escuela para recargar turnos si cambia
  String? _observedEscuelaId;
  VoidCallback? _userListener;

  // Producción: integra ScannerService
  final ScannerService _scannerService = ScannerService();
  bool _isProcessingScan = false;

  // Helpers
  TimeOfDay _fallbackStartB() => const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _fallbackEndB() => const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _startAccessTypeTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Suscripción a cambios de UserProvider (escuelaId)
      final up = Provider.of<UserProvider>(context, listen: false);

      _userListener = () {
        final newId = up.currentUser?.escuelaId;
        if (newId != null && newId.isNotEmpty && newId != _observedEscuelaId) {
          _observedEscuelaId = newId;
          _loadTurnosAndConfigure();
        }
      };
      up.addListener(_userListener!);

      // Obtener escuelaId una sola vez
      String? escuelaId = up.currentUser?.escuelaId;

      // Si no hay escuelaId en memoria, intentar obtenerla
      if (escuelaId == null || escuelaId.isEmpty) {
        escuelaId = await up.ensureEscuelaIdLoaded();
      }

      _observedEscuelaId = escuelaId;

      if (!mounted) return;
      await _loadTurnosAndConfigure();
    });
  }

  /// Helper para mostrar snackbars con control de uno activo a la vez
  void _showSnackBar(String message, {bool isError = false}) {
    // Verificar si ya hay un snackbar activo - si es así, no mostrar nuevo
    if (CustomSnackBar.isActive) {
      debugPrint('SnackBar descartado: ya hay uno activo - $message');
      return;
    }

    CustomSnackBar.show(
      context: context,
      message: message,
      isError: isError,
    );
  }

  @override
  void dispose() {
    _accessTypeTimer?.cancel();
    _accessTypeTimer = null;

    // Quitar listener de UserProvider
    try {
      final up = Provider.of<UserProvider>(context, listen: false);
      if (_userListener != null) up.removeListener(_userListener!);
    } catch (_) {}
    super.dispose();
  }

  // ----------------- Timer auto -----------------
  void _startAccessTypeTimer() {
    _accessTypeTimer?.cancel();
    _accessTypeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      if (_selectedAccessType == AccessType.default_config) {
        final prev = _isDefaultEntryConfig;
        _updateAutomaticModeFromTurnoProvider();
        if (!mounted) return;
        if (prev != _isDefaultEntryConfig) {
          final newType = _isDefaultEntryConfig ? 'Entrada' : 'Salida';
          _showSnackBar('Modo automático actualizado a: $newType');
        }
      }
    });
  }

  // ELIMINADO: Ya no se usa _bootstrapUserAndSchool, se simplificó en initState

  //?!? - No deberiamos de hardcodear 2 turnos
  // ----------------- Carga turnos -----------------
  Future<void> _loadTurnosAndConfigure() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      // Usar el escuelaId ya almacenado en memoria
      final escuelaId = _observedEscuelaId;

      if (escuelaId == null || escuelaId.trim().isEmpty) {
        setState(() {
          _errorMessage = 'No se pudo identificar la escuela del usuario.';
          _isLoading = false;
        });
        return;
      }

      await turnoProvider.loadTurnos(escuelaId: escuelaId);

      final turnos = List.of(turnoProvider.turnos);
      if (turnos.isEmpty) {
        setState(() {
          _errorMessage = 'La escuela no tiene turnos configurados.';
          _isLoading = false;
        });
        return;
      }

      TimeOfDay? p(dynamic v) => turnoProvider.parseTimeString(v);
      // Orden por hora de inicio
      turnos.sort((a, b) {
        final ta = p(a.horaInicio) ?? const TimeOfDay(hour: 0, minute: 0);
        final tb = p(b.horaInicio) ?? const TimeOfDay(hour: 0, minute: 0);
        return (ta.hour * 60 + ta.minute).compareTo(tb.hour * 60 + tb.minute);
      });

      // Turno A (primero)
      final tA = turnos.first;
      final tAStart = p(tA.horaInicio);
      final tAEnd = p(tA.horaFin);
      if (tAStart != null) _turnoAStart = tAStart;
      if (tAEnd != null) _turnoAEnd = tAEnd;

      // Tolerancia base
      _toleranceMinutes = tA.tolerancia;

      // Turno B si existe (solo para prellenar UI)
      if (turnos.length >= 2) {
        final tB = turnos[1];
        final tBStart = p(tB.horaInicio);
        final tBEnd = p(tB.horaFin);
        _turnoBStart = tBStart ?? _fallbackStartB();
        _turnoBEnd = tBEnd ?? _fallbackEndB();
        if (_toleranceMinutes == 0) {
          _toleranceMinutes = tB.tolerancia;
        }
      } else {
        _turnoBStart = _fallbackStartB();
        _turnoBEnd = _fallbackEndB();
      }

      // Determinar modo automático basado en TurnoProvider.resolveAccessPhase()
      _updateAutomaticModeFromTurnoProvider();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final currentMode = _isDefaultEntryConfig ? 'entrada' : 'salida';
      _showSnackBar('Configuración cargada. Modo automático: $currentMode');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar la configuración: $e';
        _isLoading = false;
      });
    }
  }

  void _updateAutomaticModeFromTurnoProvider() {
    final tpv = Provider.of<TurnoProvider>(context, listen: false);
    final phase = tpv.resolveAccessPhase();

    setState(() {
      _isDefaultEntryConfig = (phase.type == ScannerAccessType.entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.accentBlue),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              Text('Cargando configuración...',
                  style: AppTheme.getBodyMedium(screenSize)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: AppTheme.errorColor, size: 64),
                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: screenSize.height * 0.4),
                    child: SingleChildScrollView(
                      child: Text(
                        _errorMessage!,
                        style: AppTheme.getBodyLarge(screenSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.getLargePadding(screenSize)),
                  _retryButton(screenSize),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Consumer2<ThemeProvider, AttendanceScannerProvider>(
      builder: (context, themeProvider, scannerProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AttendanceControlHeader(
                  isScanning: scannerProvider.isScanning,
                  screenSize: screenSize,
                  onConfigurationTap: _onConfigurationTapGuarded,
                  onNotificationTap: _showNotificationDialog,
                  selectedAccessType: _selectedAccessType,
                  isDefaultEntryConfig: _isDefaultEntryConfig,
                  onAccessTypeChanged: _handleAccessTypeChange,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      _buildMainScannerSection(context, screenSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _retryButton(Size screenSize) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentBlue,
        minimumSize: Size(screenSize.width * 0.5, 44),
      ),
      onPressed: _loadTurnosAndConfigure,
      icon: const Icon(Icons.refresh, color: Colors.white),
      label: const Text('Reintentar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMainScannerSection(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: _buildScannerSelection(context, screenSize, l10n),
    );
  }

  Widget _buildScannerSelection(
      BuildContext context, Size screenSize, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          _buildEnhancedScannerOption(
            context: context,
            screenSize: screenSize,
            title: 'Escáner Físico',
            subtitle: 'Conectar dispositivo externo',
            description: 'Ideal para uso intensivo y profesional',
            icon: Icons.scanner_rounded,
            secondaryIcon: Icons.bluetooth_rounded,
            color: AppTheme.accentOrange,
            onTap: _navigateToPhysicalScanner,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          _buildEnhancedScannerOption(
            context: context,
            screenSize: screenSize,
            title: 'Cámara del Dispositivo',
            subtitle: 'Escanear usando la cámara integrada',
            description: 'Rápido y preciso para códigos QR',
            icon: Icons.camera_alt_rounded,
            secondaryIcon: Icons.flash_on_rounded,
            color: AppTheme.accentBlue,
            onTap: _navigateToCameraScanner,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.getTextSecondaryColor(context).withOpacity(0.05),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              border: Border.all(
                // ignore: deprecated_member_use
                color: AppTheme.getTextSecondaryColor(context).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppTheme.getTextSecondaryColor(context), size: 20),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    'Selecciona el método de escaneo que prefieras. Ambos registran la asistencia automáticamente.',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontSize:
                          AppTheme.getBodyMedium(screenSize).fontSize! * 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedScannerOption({
    required BuildContext context,
    required Size screenSize,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required IconData secondaryIcon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Tokens responsivos
    final padS = AppTheme.getSmallPadding(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);
    final padL = AppTheme.getLargePadding(screenSize);
    final radiusS = AppTheme.getSmallRadius(screenSize);
    final radiusL = AppTheme.getLargeRadius(screenSize);

    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final surface = AppTheme.getSurfaceColor(context);
    final borderColor = AppTheme.getBorderColor(context);

    // Contraste legible del CTA respecto al color de acento
    final onAccentColor =
        (color.computeLuminance() > 0.5) ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      label: '$title. $subtitle. $description',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radiusL),
          // ignore: deprecated_member_use
          splashColor: color.withOpacity(0.10),

          // ignore: deprecated_member_use
          highlightColor: color.withOpacity(0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight:
                  screenSize.shortestSide * 0.24, // se “lee” como botón grande
            ),
            padding: EdgeInsets.all(padL),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(radiusL),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    SizedBox(width: padM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: screenSize.shortestSide * 0.10,
                          height: screenSize.shortestSide * 0.10,
                          alignment: Alignment.center,
                          child: Icon(
                            secondaryIcon,
                            color: color,
                            size: screenSize.shortestSide * 0.045,
                          ),
                        ),
                        SizedBox(height: padS),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: screenSize.shortestSide * 0.035,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: padM),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: padM, vertical: padS),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(radiusS),
                    border:
                        // ignore: deprecated_member_use
                        Border.all(color: color.withOpacity(0.35), width: 1),
                  ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getBodyLarge(screenSize).copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: padM),
                Text(
                  description,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: padS),
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenSize.shortestSide * 0.08,
                    ),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(padS * 1.8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: padM,
                          vertical: padS * 0.9,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(padS * 1.8),
                          border: Border.all(color: color, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: onAccentColor,
                              size: screenSize.shortestSide * 0.040,
                            ),
                            SizedBox(width: padS * 0.7),
                            Text(
                              'Usar ahora',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: onAccentColor,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
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
          ),
        ),
      ),
    );
  }

  void _handleAccessTypeChange(AccessType newType) {
    setState(() {
      _selectedAccessType = newType;
    });

    String message;
    switch (newType) {
      case AccessType.default_config:
        _updateAutomaticModeFromTurnoProvider();
        final currentDefault = _isDefaultEntryConfig ? 'entrada' : 'salida';
        message = 'Modo automático inteligente (actualmente: $currentDefault)';
        break;
      case AccessType.fixed_entry:
        message = 'Modo: Entrada fija';
        break;
      case AccessType.fixed_exit:
        message = 'Modo: Salida fija';
        break;
      case AccessType.extracurricular_entry:
        message = 'Modo: Entrada extracurricular';
        break;
      case AccessType.extracurricular_exit:
        message = 'Modo: Salida extracurricular';
        break;
    }
    _showSnackBar(message);
  }

  void _navigateToCameraScanner() {
    final bool isExtracurricular =
        _selectedAccessType == AccessType.extracurricular_entry ||
            _selectedAccessType == AccessType.extracurricular_exit;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerView(
          onCodeScanned: _handleScannedCode,
          accessType: _convertToScannerAccessType(_selectedAccessType),
          isDefaultEntryConfig: _isDefaultEntryConfig,
          isExtracurricular: isExtracurricular,
        ),
      ),
    );
  }

  void _navigateToPhysicalScanner() {
    final bool isExtracurricular =
        _selectedAccessType == AccessType.extracurricular_entry ||
            _selectedAccessType == AccessType.extracurricular_exit;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhysicalScannerView(
          onCodeScanned: _handleScannedCode,
          accessType: _convertToScannerAccessType(_selectedAccessType),
          isDefaultEntryConfig: _isDefaultEntryConfig,
          isExtracurricular: isExtracurricular,
        ),
      ),
    );
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    try {
      final userProvider = context.read<UserProvider>();
      final adminId = userProvider.currentUser?.id;

      if (adminId == null || adminId.isEmpty) {
        CustomSnackBar.show(
          context: context,
          message: 'No hay sesión activa para registrar asistencia.',
          isError: true,
        );
        return;
      }

      // Usar el escuelaId ya almacenado en memoria para evitar queries adicionales
      String? escuelaId = _observedEscuelaId;

      // Solo si no está en memoria, intentar obtenerla
      if (escuelaId == null || escuelaId.isEmpty) {
        escuelaId = userProvider.currentUser?.escuelaId;
      }

      if (escuelaId == null || escuelaId.isEmpty) {
        CustomSnackBar.show(
          // ignore: use_build_context_synchronously
          context: context,
          message: 'No se pudo determinar la escuela del usuario.',
          isError: true,
        );
        return;
      }

      final accessType = _convertToScannerAccessType(_selectedAccessType);

      final bool isExtracurricular =
          _selectedAccessType == AccessType.extracurricular_entry ||
              _selectedAccessType == AccessType.extracurricular_exit;

      final bool isFixedAccess =
          _selectedAccessType == AccessType.fixed_entry ||
              _selectedAccessType == AccessType.fixed_exit ||
              _selectedAccessType == AccessType.extracurricular_entry ||
              _selectedAccessType == AccessType.extracurricular_exit;

      final result = await _scannerService.processScannedCode(
        escuelaIdFromContext: escuelaId,
        scannedCode: code,
        adminId: adminId,
        accessType: accessType,
        isDefaultEntryConfig: _isDefaultEntryConfig,
        isExtracurricular: isExtracurricular,
        isFixedAccess: isFixedAccess,
      );

      if (result['success'] == true) {
        final accessMsg =
            (result['access']?['message'] as String?) ?? 'Registro realizado';
        CustomSnackBar.show(
          // ignore: use_build_context_synchronously
          context: context,
          message: accessMsg,
          isError: false,
        );
      } else {
        final msg = (result['error'] as String?) ??
            'No se pudo registrar la asistencia';
        // ignore: use_build_context_synchronously
        CustomSnackBar.show(context: context, message: msg, isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Error al procesar el escaneo: $e',
        isError: true,
      );
    } finally {
      _isProcessingScan = false;
    }
  }

  ScannerAccessType _convertToScannerAccessType(AccessType accessType) {
    switch (accessType) {
      case AccessType.default_config:
        return ScannerAccessType.automatic;
      case AccessType.fixed_entry:
        return ScannerAccessType.entry;
      case AccessType.fixed_exit:
        return ScannerAccessType.exit;
      case AccessType.extracurricular_entry:
        return ScannerAccessType.entry;
      case AccessType.extracurricular_exit:
        return ScannerAccessType.exit;
    }
  }

  void _onConfigurationTapGuarded() {
    final isAdmin = context.read<UserProvider>().isAdmin();
    if (!isAdmin) {
      CustomSnackBar.show(
        context: context,
        message: 'Solo administradores pueden configurar turnos',
        isError: true,
      );
      return;
    }
    _showConfigurationDialog();
  }

  void _showConfigurationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerConfigurationView(
          morningStartTime: _turnoAStart,
          morningEndTime: _turnoAEnd,
          afternoonStartTime: _turnoBStart,
          afternoonEndTime: _turnoBEnd,
          toleranceMinutes: _toleranceMinutes,
          onSave: (aStart, aEnd, bStart, bEnd, tol) {
            setState(() {
              _turnoAStart = aStart;
              _turnoAEnd = aEnd;
              _turnoBStart = bStart;
              _turnoBEnd = bEnd;
              _toleranceMinutes = tol;
              _updateAutomaticModeFromTurnoProvider();
            });
          },
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationSendView()),
    );
  }
}
