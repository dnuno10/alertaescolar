import 'dart:async';

import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/attendance_scanner_provider.dart';
import '../../../components/admin/qr_and_notifications/attendance_control_header.dart';
import '../../../managers/turno_provider.dart';
// Navegaciones
import 'notification_send_view.dart';
import 'scanner_configuration_view.dart';
import 'camera_scanner_view.dart';
import 'physical_scanner_view.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../l10n/app_localizations.dart';

class AttendanceControlView extends StatefulWidget {
  const AttendanceControlView({super.key});

  @override
  State<AttendanceControlView> createState() => _AttendanceControlViewState();
}

class _AttendanceControlViewState extends State<AttendanceControlView> {
  // Config local (se alimenta desde TurnoProvider)
  TimeOfDay _turnoAStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _turnoAEnd = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _turnoBStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _turnoBEnd = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 10;

  // Control de acceso
  AccessType _selectedAccessType = AccessType.default_config;
  bool _isDefaultEntryConfig = true;

  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;

  // Timer para actualizar modo automático
  Timer? _accessTypeTimer;

  // Helpers
  TimeOfDay _fallbackStartB() => const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _fallbackEndB() => const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTurnosAndConfigure();
    });
    _startAccessTypeTimer();
  }

  @override
  void dispose() {
    _accessTypeTimer?.cancel();
    _accessTypeTimer = null;
    super.dispose();
  }

  // ----------------- Timer auto -----------------

  void _startAccessTypeTimer() {
    _accessTypeTimer?.cancel();
    _accessTypeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      if (_selectedAccessType == AccessType.default_config) {
        final prev = _isDefaultEntryConfig;
        _determineDefaultAccessTypeFromAllTurnos();
        if (!mounted) return;
        if (prev != _isDefaultEntryConfig) {
          final newType = _isDefaultEntryConfig ? 'Entrada' : 'Salida';
          CustomSnackBar.show(
            message: 'Modo automático actualizado a: $newType',
            isError: false,
            context: context,
          );
        }
      }
    });
  }

  // ----------------- Carga turnos -----------------

  Future<void> _loadTurnosAndConfigure() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      final escuelaId = userProvider.currentUser?.escuelaId;
      if (escuelaId == null || escuelaId.trim().isEmpty) {
        setState(() {
          _errorMessage = 'No se pudo identificar la escuela del usuario.';
          _isLoading = false;
        });
        return;
      }

      await turnoProvider.loadTurnos(escuelaId: escuelaId);

      // Con los turnos cargados, seleccionamos 1er y 2do turno por hora de inicio
      final turnos = List.of(turnoProvider.turnos);

      if (turnos.isEmpty) {
        setState(() {
          _errorMessage = 'La escuela no tiene turnos configurados.';
          _isLoading = false;
        });
        return;
      }

      // Ordenar por hora de inicio
      TimeOfDay? _p(dynamic v) => turnoProvider.parseTimeString(v);
      turnos.sort((a, b) {
        final ta = _p(a.horaInicio) ?? const TimeOfDay(hour: 0, minute: 0);
        final tb = _p(b.horaInicio) ?? const TimeOfDay(hour: 0, minute: 0);
        return (ta.hour * 60 + ta.minute).compareTo(tb.hour * 60 + tb.minute);
      });

      // Turno A (primero)
      final tA = turnos.first;
      final tAStart = _p(tA.horaInicio);
      final tAEnd = _p(tA.horaFin);
      if (tAStart != null) _turnoAStart = tAStart;
      if (tAEnd != null) _turnoAEnd = tAEnd;

      // Tolerancia base (si hay varias diferentes, usamos la del primer turno)
      _toleranceMinutes = tA.tolerancia;

      // Turno B (segundo si existe)
      if (turnos.length >= 2) {
        final tB = turnos[1];
        final tBStart = _p(tB.horaInicio);
        final tBEnd = _p(tB.horaFin);
        _turnoBStart = tBStart ?? _fallbackStartB();
        _turnoBEnd = tBEnd ?? _fallbackEndB();
        // si la tolerancia base fuera 0 por alguna razón, toma la del segundo
        if (_toleranceMinutes == 0) {
          _toleranceMinutes = tB.tolerancia;
        }
      } else {
        // No hay segundo turno → fallbacks (solo para UI de config)
        _turnoBStart = _fallbackStartB();
        _turnoBEnd = _fallbackEndB();
      }

      _determineDefaultAccessTypeFromAllTurnos();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final currentMode = _isDefaultEntryConfig ? 'entrada' : 'salida';
      CustomSnackBar.show(
        message: 'Configuración cargada. Modo automático: $currentMode',
        isError: false,
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar la configuración: $e';
        _isLoading = false;
      });
    }
  }

  // ----------------- Lógica de modo automático -----------------

  // Convierte TimeOfDay a minutos desde 00:00
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  // Determina entrada/salida en base a TODA la lista de turnos
  void _determineDefaultAccessTypeFromAllTurnos() {
    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
    final now = TimeOfDay.now();
    final nowM = _toMinutes(now);

    // Construimos ventanas para cada turno
    // Entrada: [start-30, start+tolerancia]
    // Salida:  [end - tolerancia, end + 30]
    final windows = <_Window>[]; // lista de ventanas etiquetadas

    for (final t in turnoProvider.turnos) {
      final s = turnoProvider.parseTimeString(t.horaInicio);
      final e = turnoProvider.parseTimeString(t.horaFin);
      if (s == null || e == null) continue;

      final startM = _toMinutes(s);
      final endM = _toMinutes(e);
      final tol = (t.tolerancia is int) ? t.tolerancia : _toleranceMinutes;

      windows.addAll([
        _Window(label: _WLabel.entry, from: startM - 30, to: startM + tol),
        _Window(label: _WLabel.exit, from: endM - tol, to: endM + 30),
      ]);
    }

    // Si no hay ventanas (sin turnos válidos), queda entrada por defecto
    if (windows.isEmpty) {
      setState(() => _isDefaultEntryConfig = true);
      return;
    }

    // ¿now cae en alguna ventana?
    for (final w in windows) {
      if (nowM >= w.from && nowM <= w.to) {
        final entry = w.label == _WLabel.entry;
        setState(() => _isDefaultEntryConfig = entry);
        return;
      }
    }

    // Si no cae en ninguna ventana:
    // 1) Si estamos antes del primer turno del día → entrada
    windows.sort((a, b) => a.from.compareTo(b.from));
    final firstStartWindow = windows
        .where((w) => w.label == _WLabel.entry)
        .toList()
      ..sort((a, b) => a.from.compareTo(b.from));
    if (firstStartWindow.isNotEmpty &&
        nowM < firstStartWindow.first.from - 30) {
      setState(() => _isDefaultEntryConfig = true);
      return;
    }

    // 2) Si estamos después de todas las ventanas → salida
    if (nowM > windows.last.to + 60) {
      setState(() => _isDefaultEntryConfig = false);
      return;
    }

    // 3) En un hueco entre ventanas → preferimos entrada por la siguiente ventana más cercana
    final nextEntry = firstStartWindow.firstWhere(
      (w) => nowM < w.from,
      orElse: () => firstStartWindow.last,
    );
    setState(() => _isDefaultEntryConfig = nowM <= nextEntry.from);
  }

  // ----------------- UI -----------------

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
                  SolidButton(
                    onPressed: _loadTurnosAndConfigure,
                    label: 'Reintentar',
                    icon: Icons.refresh,
                    backgroundColor: AppTheme.accentBlue,
                    screenSize: screenSize,
                    width: screenSize.width * 0.5,
                  ),
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
              // Header
              SliverToBoxAdapter(
                child: AttendanceControlHeader(
                  isScanning: false,
                  screenSize: screenSize,
                  onConfigurationTap: _showConfigurationDialog,
                  onNotificationTap: _showNotificationDialog,
                  selectedAccessType: _selectedAccessType,
                  isDefaultEntryConfig: _isDefaultEntryConfig,
                  onAccessTypeChanged: _handleAccessTypeChange,
                ),
              ),
              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      _buildMainScannerSection(context, screenSize),
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                      if (scannerProvider.scannedHistory.isNotEmpty)
                        _buildRecentScansSection(
                            context, screenSize, scannerProvider),
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

  Widget _buildMainScannerSection(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withOpacity(0.1),
            blurRadius: screenSize.height * 0.02,
            offset: Offset(0, screenSize.height * 0.008),
          ),
        ],
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
          // Opción: Escáner físico
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
          // Opción: Cámara
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

          // Info
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context).withOpacity(0.05),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              border: Border.all(
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
            ),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            border: Border.all(color: color.withOpacity(0.2), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTheme.getH2(screenSize).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:
                                  Icon(secondaryIcon, color: color, size: 18),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: color, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getMediumPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize),
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Text(
                      subtitle,
                      style: AppTheme.getBodyLarge(screenSize).copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getSmallPadding(screenSize),
                          vertical: AppTheme.getSmallPadding(screenSize) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded,
                                color: color, size: 16),
                            SizedBox(
                                width:
                                    AppTheme.getSmallPadding(screenSize) / 2),
                            Text(
                              'Tocar para usar',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentScansSection(BuildContext context, Size screenSize,
      AttendanceScannerProvider scannerProvider) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: AppTheme.accentBlue, size: 20),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                'Escaneos Recientes',
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ...scannerProvider.scannedHistory.take(5).map(
                (code) => Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize) / 2),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        '${l10n.studentId}: $code',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ----------------- Modo/acciones -----------------

  void _handleAccessTypeChange(AccessType newType) {
    setState(() {
      _selectedAccessType = newType;
    });

    String message;
    switch (newType) {
      case AccessType.default_config:
        final currentDefault = _isDefaultEntryConfig ? 'entrada' : 'salida';
        message = 'Modo automático activado (actualmente: $currentDefault)';
        _determineDefaultAccessTypeFromAllTurnos();
        break;
      case AccessType.entry:
        message = 'Modo fijo: Registro de entrada';
        break;
      case AccessType.exit:
        message = 'Modo fijo: Registro de salida';
        break;
    }

    CustomSnackBar.show(message: message, isError: false, context: context);
  }

  // ----------------- Navegación -----------------

  void _navigateToCameraScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerView(
          onCodeScanned: _handleScannedCode,
          accessType: _convertToScannerAccessType(_selectedAccessType),
          isDefaultEntryConfig: _isDefaultEntryConfig,
        ),
      ),
    );
  }

  void _navigateToPhysicalScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhysicalScannerView(
          onCodeScanned: _handleScannedCode,
          accessType: _convertToScannerAccessType(_selectedAccessType),
          isDefaultEntryConfig: _isDefaultEntryConfig,
        ),
      ),
    );
  }

  // ----------------- Utilidades varias -----------------

  ScannerAccessType _convertToScannerAccessType(AccessType accessType) {
    switch (accessType) {
      case AccessType.default_config:
        return ScannerAccessType.automatic;
      case AccessType.entry:
        return ScannerAccessType.entry;
      case AccessType.exit:
        return ScannerAccessType.exit;
    }
  }

  void _handleScannedCode(String code) {
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);
    scannerProvider.handlePhysicalScannerInput(code);
  }

  void _showConfigurationDialog() {
    // Compatibilidad hacia atrás: tomamos Turno A (más temprano) y Turno B (segundo si hay)
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
              _determineDefaultAccessTypeFromAllTurnos();
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

// ----------------- Modelos auxiliares para ventanas -----------------

enum _WLabel { entry, exit }

class _Window {
  final _WLabel label;
  final int from; // minutos
  final int to; // minutos
  _Window({required this.label, required this.from, required this.to});
}
