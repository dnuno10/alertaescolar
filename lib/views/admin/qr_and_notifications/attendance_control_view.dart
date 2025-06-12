import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../components/admin/qr_and_notifications/qr_scanner_card.dart';
import 'notification_send_view.dart';
import 'scanner_configuration_view.dart';

class AttendanceControlView extends StatefulWidget {
  const AttendanceControlView({super.key});

  @override
  State<AttendanceControlView> createState() => _AttendanceControlViewState();
}

class _AttendanceControlViewState extends State<AttendanceControlView>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final List<Map<String, dynamic>> _attendanceRecords = [];

  // Configuration variables
  TimeOfDay _morningStartTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _morningEndTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _afternoonStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _afternoonEndTime = const TimeOfDay(hour: 18, minute: 0);
  int _toleranceMinutes = 15;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        AppTheme.getSmallPadding(screenSize),
                    left: AppTheme.getMediumPadding(screenSize),
                    right: AppTheme.getMediumPadding(screenSize),
                    bottom: AppTheme.getLargePadding(screenSize),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.attendanceControl,
                                  style: AppTheme.getH1(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        AppTheme.getSmallPadding(screenSize) *
                                            0.5),
                                Text(
                                  'Escanea códigos QR para registrar asistencia',
                                  style: AppTheme.getBodyMedium(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize)),
                              // Status indicator
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppTheme.getSmallPadding(screenSize),
                                  vertical:
                                      AppTheme.getSmallPadding(screenSize) *
                                          0.5,
                                ),
                                decoration: BoxDecoration(
                                  color: _isScanning
                                      ? AppTheme.successColor
                                          .withValues(alpha: 0.1)
                                      : AppTheme.getBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(screenSize)),
                                  border: Border.all(
                                    color: _isScanning
                                        ? AppTheme.successColor
                                            .withValues(alpha: 0.3)
                                        : AppTheme.getBorderColor(context),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: screenSize.height * 0.012,
                                      height: screenSize.height * 0.012,
                                      decoration: BoxDecoration(
                                        color: _isScanning
                                            ? AppTheme.successColor
                                            : AppTheme.getTextSecondaryColor(
                                                context),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(
                                        width: AppTheme.getSmallPadding(
                                                screenSize) *
                                            0.5),
                                    Text(
                                      _isScanning ? 'Escaneando' : 'Inactivo',
                                      style: AppTheme.getCaption(screenSize)
                                          .copyWith(
                                        color: _isScanning
                                            ? AppTheme.successColor
                                            : AppTheme.getTextSecondaryColor(
                                                context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getMediumRadius(screenSize)),
                              border: Border.all(
                                color:
                                    AppTheme.accentBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showConfigurationDialog,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getMediumRadius(screenSize)),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      AppTheme.getSmallPadding(screenSize)),
                                  child: Icon(
                                    Icons.settings_rounded,
                                    color: AppTheme.accentBlue,
                                    size: screenSize.height * 0.025,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          // Notification button
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getMediumRadius(screenSize)),
                              border: Border.all(
                                color: AppTheme.accentOrange
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showNotificationDialog,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getMediumRadius(screenSize)),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      AppTheme.getSmallPadding(screenSize)),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.notifications_rounded,
                                        color: AppTheme.accentOrange,
                                        size: screenSize.height * 0.025,
                                      ),
                                      Text(
                                        'Enviar Notificación',
                                        style:
                                            AppTheme.getBodyMedium(screenSize)
                                                .copyWith(
                                          color: AppTheme.accentOrange,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Scanner Section
                      QRScannerCard(
                        screenSize: screenSize,
                        isScanning: _isScanning,
                        scaleAnimation: _scaleAnimation,
                        onToggleScanning: _toggleScanning,
                        onStudentScanned: _addAttendanceRecord,
                      ),
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

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _addAttendanceRecord(Map<String, dynamic> record) {
    setState(() {
      _attendanceRecords.insert(0, record);
    });
  }

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
}
