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
  // Configuration variables with default values
  TimeOfDay _morningStartTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _morningEndTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _afternoonStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _afternoonEndTime = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 15;

  // Access type control variables
  AccessType _selectedAccessType = AccessType.default_config;
  bool _isDefaultEntryConfig = true; // Default to entry mode

  // Loading state for initial data fetch
  bool _isLoading = true;
  String? _errorMessage;

  // Add timer for real-time updates
  Timer? _accessTypeTimer;

  @override
  void initState() {
    super.initState();
    // Load configuration from database on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShiftConfiguration();
    });

    // Start timer for periodic access type updates
    _startAccessTypeTimer();
  }

  @override
  void dispose() {
    _accessTypeTimer?.cancel();
    super.dispose();
  }

  // Start timer to update access type every minute
  void _startAccessTypeTimer() {
    _accessTypeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _selectedAccessType == AccessType.default_config) {
        final previousDefault = _isDefaultEntryConfig;
        _determineDefaultAccessType();

        // Show notification if default changed
        if (previousDefault != _isDefaultEntryConfig && mounted) {
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

  // Enhanced determine default access type based on loaded configuration and current time
  void _determineDefaultAccessType() {
    final now = TimeOfDay.now();
    final currentTime = now.hour * 60 + now.minute;

    // Convert shift times to minutes for comparison
    final morningStartMinutes =
        _morningStartTime.hour * 60 + _morningStartTime.minute;
    final morningEndMinutes =
        _morningEndTime.hour * 60 + _morningEndTime.minute;
    final afternoonStartMinutes =
        _afternoonStartTime.hour * 60 + _afternoonStartTime.minute;
    final afternoonEndMinutes =
        _afternoonEndTime.hour * 60 + _afternoonEndTime.minute;

    // Enhanced logic with better time window detection
    bool newDefaultEntry = true;
    String reason = '';

    // Morning shift entry window (30 minutes before to tolerance after start)
    final morningEntryStart = morningStartMinutes - 30;
    final morningEntryEnd = morningStartMinutes + _toleranceMinutes;

    // Morning shift exit window (tolerance before to 30 minutes after end)
    final morningExitStart = morningEndMinutes - _toleranceMinutes;
    final morningExitEnd = morningEndMinutes + 30;

    // Afternoon shift entry window
    final afternoonEntryStart = afternoonStartMinutes - 30;
    final afternoonEntryEnd = afternoonStartMinutes + _toleranceMinutes;

    // Afternoon shift exit window
    final afternoonExitStart = afternoonEndMinutes - _toleranceMinutes;
    final afternoonExitEnd = afternoonEndMinutes + 30;

    if (currentTime >= morningEntryStart && currentTime <= morningEntryEnd) {
      // Morning entry period
      newDefaultEntry = true;
      reason = 'Período de entrada matutina';
    } else if (currentTime >= morningExitStart &&
        currentTime <= morningExitEnd) {
      // Morning exit period
      newDefaultEntry = false;
      reason = 'Período de salida matutina';
    } else if (currentTime >= afternoonEntryStart &&
        currentTime <= afternoonEntryEnd) {
      // Afternoon entry period
      newDefaultEntry = true;
      reason = 'Período de entrada vespertina';
    } else if (currentTime >= afternoonExitStart &&
        currentTime <= afternoonExitEnd) {
      // Afternoon exit period
      newDefaultEntry = false;
      reason = 'Período de salida vespertina';
    } else if (currentTime < morningStartMinutes - 60) {
      // Very early morning - likely entry preparation
      newDefaultEntry = true;
      reason = 'Preparación para entrada matutina';
    } else if (currentTime > morningEndMinutes &&
        currentTime < afternoonStartMinutes - 60) {
      // Between shifts - likely break time, default to entry for afternoon
      newDefaultEntry = true;
      reason = 'Entre turnos - preparación vespertina';
    } else if (currentTime > afternoonEndMinutes + 60) {
      // Late evening - likely exit
      newDefaultEntry = false;
      reason = 'Período de salida tardía';
    } else {
      // Default case - prefer entry during ambiguous times
      newDefaultEntry = true;
      reason = 'Horario no específico - entrada por defecto';
    }

    // Only update state if mounted and value changed
    if (mounted && _isDefaultEntryConfig != newDefaultEntry) {
      setState(() {
        _isDefaultEntryConfig = newDefaultEntry;
      });

      debugPrint(
          'Access type auto-updated: ${newDefaultEntry ? "Entry" : "Exit"} - $reason');
    }
  }

  // Enhanced handle access type change with more feedback
  void _handleAccessTypeChange(AccessType newType) {
    setState(() {
      _selectedAccessType = newType;
    });

    // Provide more detailed feedback
    String message;
    String typeName = _getAccessTypeName(newType);

    switch (newType) {
      case AccessType.default_config:
        final currentDefault = _isDefaultEntryConfig ? 'entrada' : 'salida';
        message = 'Modo automático activado (actualmente: $currentDefault)';
        // Re-determine in case time changed
        _determineDefaultAccessType();
        break;
      case AccessType.entry:
        message = 'Modo fijo: Registro de entrada';
        break;
      case AccessType.exit:
        message = 'Modo fijo: Registro de salida';
        break;
    }

    CustomSnackBar.show(
      message: message,
      isError: false,
      context: context,
    );
  }

  // Enhanced get display name for access type with current time context
  String _getAccessTypeName(AccessType type) {
    switch (type) {
      case AccessType.default_config:
        final currentMode = _isDefaultEntryConfig ? 'Entrada' : 'Salida';
        final timeContext = _getCurrentTimeContext();
        return 'Auto ($currentMode$timeContext)';
      case AccessType.entry:
        return 'Entrada';
      case AccessType.exit:
        return 'Salida';
    }
  }

  // Get current time context for better user understanding
  String _getCurrentTimeContext() {
    final now = TimeOfDay.now();
    final currentTime = now.hour * 60 + now.minute;

    final morningStartMinutes =
        _morningStartTime.hour * 60 + _morningStartTime.minute;
    final morningEndMinutes =
        _morningEndTime.hour * 60 + _morningEndTime.minute;
    final afternoonStartMinutes =
        _afternoonStartTime.hour * 60 + _afternoonStartTime.minute;
    final afternoonEndMinutes =
        _afternoonEndTime.hour * 60 + _afternoonEndTime.minute;

    if (currentTime >= morningStartMinutes - 30 &&
        currentTime <= morningEndMinutes + 30) {
      return ' - Turno matutino';
    } else if (currentTime >= afternoonStartMinutes - 30 &&
        currentTime <= afternoonEndMinutes + 30) {
      return ' - Turno vespertino';
    } else {
      return '';
    }
  }

  // Get icon for access type
  IconData _getAccessTypeIcon(AccessType type) {
    switch (type) {
      case AccessType.default_config:
        return Icons.access_time_rounded;
      case AccessType.entry:
        return Icons.login_rounded;
      case AccessType.exit:
        return Icons.logout_rounded;
    }
  }

  // Get color for access type
  Color _getAccessTypeColor(AccessType type) {
    switch (type) {
      case AccessType.default_config:
        return AppTheme.accentPurple;
      case AccessType.entry:
        return AppTheme.successColor;
      case AccessType.exit:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.accentBlue),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              Text(
                'Cargando configuración...',
                style: AppTheme.getBodyMedium(screenSize),
              )
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
                    constraints: BoxConstraints(
                      maxHeight:
                          screenSize.height * 0.4, // Limit error message height
                    ),
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
                    onPressed: _loadShiftConfiguration,
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
              // Custom Header with updated parameters
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

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      // Main Scanner Section
                      _buildMainScannerSection(context, screenSize, l10n),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Recent scans section
                      if (scannerProvider.scannedHistory.isNotEmpty)
                        _buildRecentScansSection(
                            context, screenSize, scannerProvider, l10n),
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

  Widget _buildMainScannerSection(
      BuildContext context, Size screenSize, AppLocalizations l10n) {
    final screenSize = MediaQuery.of(context).size;
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
          // Scanner Options mejorados
          Column(
            children: [
              // Physical Scanner
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
              // Camera Scanner
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
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Información adicional
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
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.getTextSecondaryColor(context),
                  size: 20,
                ),
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
                colors: [
                  color.withOpacity(0.08),
                  color.withOpacity(0.03),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Header Row with Icons and Title
                Row(
                  children: [
                    // Title and Secondary Icon Row
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
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

                          // Secondary Icon and Arrow
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
                                child: Icon(
                                  secondaryIcon,
                                  color: color,
                                  size: 18,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize)),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: color,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Content Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
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

                    // Description with icon
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

                    // Status indicator
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
                              color: color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: color,
                                size: 16,
                              ),
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
        ));
  }

  // Convert AccessType to ScannerAccessType for scanner views
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

  // Navigation methods
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

  Widget _buildRecentScansSection(BuildContext context, Size screenSize,
      AttendanceScannerProvider scannerProvider, AppLocalizations l10n) {
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
              Icon(
                Icons.history_rounded,
                color: AppTheme.accentBlue,
                size: 20,
              ),
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

  void _handleScannedCode(String code) {
    final scannerProvider =
        Provider.of<AttendanceScannerProvider>(context, listen: false);

    // Process the scanned code through the provider
    scannerProvider.handlePhysicalScannerInput(code);
  }

  // Configuration and notification dialogs
  void _showConfigurationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerConfigurationView(
          morningStartTime: _morningStartTime,
          morningEndTime: _morningEndTime,
          afternoonStartTime: _afternoonStartTime,
          afternoonEndTime: _afternoonEndTime,
          toleranceMinutes: _toleranceMinutes,
          onSave: (morningStart, morningEnd, afternoonStart, afternoonEnd,
              tolerance) {
            setState(() {
              _morningStartTime = morningStart;
              _morningEndTime = morningEnd;
              _afternoonStartTime = afternoonStart;
              _afternoonEndTime = afternoonEnd;
              _toleranceMinutes = tolerance;

              // Update default access type based on new configuration
              _determineDefaultAccessType();
            });
          },
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSendView(),
      ),
    );
  }

  Future<void> _loadShiftConfiguration() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      final escuelaId = userProvider.currentUser?.escuelaId;

      if (escuelaId == null) {
        setState(() {
          _errorMessage = 'No se pudo identificar la escuela del usuario.';
          _isLoading = false;
        });
        return;
      }

      // Load turnos for the school
      await turnoProvider.loadTurnos(escuelaId: escuelaId);

      // Get morning and afternoon shifts
      final morningShift = turnoProvider.getTurnoByType('Matutino');
      final afternoonShift = turnoProvider.getTurnoByType('Vespertino');

      if (morningShift != null) {
        final morningStartTime =
            turnoProvider.parseTimeString(morningShift.horaInicio);
        final morningEndTime =
            turnoProvider.parseTimeString(morningShift.horaFin);

        if (morningStartTime != null) _morningStartTime = morningStartTime;
        if (morningEndTime != null) _morningEndTime = morningEndTime;

        // Set tolerance from the morning shift
        _toleranceMinutes = morningShift.tolerancia;
      }

      if (afternoonShift != null) {
        final afternoonStartTime =
            turnoProvider.parseTimeString(afternoonShift.horaInicio);
        final afternoonEndTime =
            turnoProvider.parseTimeString(afternoonShift.horaFin);

        if (afternoonStartTime != null) {
          _afternoonStartTime = afternoonStartTime;
        }
        if (afternoonEndTime != null) _afternoonEndTime = afternoonEndTime;
      }

      // Now determine the default access type based on loaded configuration
      _determineDefaultAccessType();

      setState(() => _isLoading = false);

      // Show configuration loaded message
      if (mounted) {
        final currentMode = _isDefaultEntryConfig ? 'entrada' : 'salida';
        CustomSnackBar.show(
          message: 'Configuración cargada. Modo automático: $currentMode',
          isError: false,
          context: context,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar la configuración: $e';
        _isLoading = false;
      });
      _determineDefaultAccessType(); // Still determine default with fallback values
    }
  }
}
