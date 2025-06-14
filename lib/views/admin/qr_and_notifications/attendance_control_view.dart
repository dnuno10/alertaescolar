import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../components/admin/qr_and_notifications/qr_scanner_card.dart';
import '../../../components/admin/qr_and_notifications/attendance_control_header.dart';
import 'notification_send_view.dart';
import 'scanner_configuration_view.dart';
import '../../../widgets/custom_snack_bar.dart';

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
                child: AttendanceControlHeader(
                  isScanning: _isScanning,
                  screenSize: screenSize,
                  onConfigurationTap: _showConfigurationDialog,
                  onNotificationTap: _showNotificationDialog,
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
        builder: (context) => NotificationSendView(),
      ),
    );
  }
}
