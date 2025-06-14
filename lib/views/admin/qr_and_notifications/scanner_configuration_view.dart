import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/admin/scanner_config/modern_shift_section.dart';
import '../../../components/admin/scanner_config/tolerance_display_card.dart';
import '../../../components/admin/scanner_config/tolerance_slider_control.dart';
import '../../../components/admin/scanner_config/quick_tolerance_selector.dart';
import '../../../components/admin/scanner_config/step_indicator.dart';
import '../../../components/admin/scanner_config/progress_line.dart';
import '../../../components/admin/scanner_config/schedule_step_card.dart';
import '../../../components/admin/scanner_config/shift_summary.dart';
import '../../../components/admin/scanner_config/tolerance_summary_card.dart';
import '../../../widgets/custom_snack_bar.dart';

class ScannerConfigurationView extends StatefulWidget {
  final TimeOfDay morningStartTime;
  final TimeOfDay morningEndTime;
  final TimeOfDay afternoonStartTime;
  final TimeOfDay afternoonEndTime;
  final int toleranceMinutes;
  final Function(TimeOfDay, TimeOfDay, TimeOfDay, TimeOfDay, int) onSave;

  const ScannerConfigurationView({
    super.key,
    required this.morningStartTime,
    required this.morningEndTime,
    required this.afternoonStartTime,
    required this.afternoonEndTime,
    required this.toleranceMinutes,
    required this.onSave,
  });

  @override
  State<ScannerConfigurationView> createState() =>
      _ScannerConfigurationViewState();
}

class _ScannerConfigurationViewState extends State<ScannerConfigurationView>
    with TickerProviderStateMixin {
  late TimeOfDay _morningStart;
  late TimeOfDay _morningEnd;
  late TimeOfDay _afternoonStart;
  late TimeOfDay _afternoonEnd;
  late int _tolerance;
  int _currentStep = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _stepAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _morningStart = widget.morningStartTime;
    _morningEnd = widget.morningEndTime;
    _afternoonStart = widget.afternoonStartTime;
    _afternoonEnd = widget.afternoonEndTime;
    _tolerance = widget.toleranceMinutes;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                NavHeader(
                  title: l10n.scannerConfiguration,
                ),

                // Progress indicator
                SliverToBoxAdapter(
                  child: Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Row(
                      children: [
                        StepIndicator(
                          step: 0,
                          currentStep: _currentStep,
                          label: l10n.schedules,
                          icon: Icons.schedule_rounded,
                          screenSize: screenSize,
                        ),
                        Expanded(
                          child: ProgressLine(
                            step: 0,
                            currentStep: _currentStep,
                            screenSize: screenSize,
                          ),
                        ),
                        StepIndicator(
                          step: 1,
                          currentStep: _currentStep,
                          label: l10n.tolerance,
                          icon: Icons.timer_rounded,
                          screenSize: screenSize,
                        ),
                        Expanded(
                          child: ProgressLine(
                            step: 1,
                            currentStep: _currentStep,
                            screenSize: screenSize,
                          ),
                        ),
                        StepIndicator(
                          step: 2,
                          currentStep: _currentStep,
                          label: l10n.summary,
                          icon: Icons.check_circle_rounded,
                          screenSize: screenSize,
                        ),
                      ],
                    ),
                  ),
                ),

                // Main content
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding:
                          EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                      child: _buildCurrentStep(screenSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                        child: CustomOutlineButton(
                      onPressed: _previousStep,
                      label: l10n.previous,
                      icon: Icons.arrow_back_rounded,
                      color: AppTheme.getTextPrimaryColor(context)
                          .withOpacity(0.5),
                      screenSize: screenSize,
                    )),
                  if (_currentStep > 0)
                    SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                      flex: _currentStep == 0 ? 1 : 2,
                      child: SolidButton(
                        onPressed:
                            _currentStep < 2 ? _nextStep : _saveConfiguration,
                        label: _currentStep < 2
                            ? l10n.next
                            : l10n.saveConfiguration,
                        icon: _currentStep < 2
                            ? Icons.arrow_forward_rounded
                            : Icons.save_rounded,
                        backgroundColor: AppTheme.accentBlue,
                        screenSize: screenSize,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep(Size screenSize) {
    switch (_currentStep) {
      case 0:
        return ScheduleStepCard(
          morningStartTime: _morningStart,
          morningEndTime: _morningEnd,
          afternoonStartTime: _afternoonStart,
          afternoonEndTime: _afternoonEnd,
          onMorningStartChanged: (start) =>
              setState(() => _morningStart = start),
          onMorningEndChanged: (end) => setState(() => _morningEnd = end),
          onAfternoonStartChanged: (start) =>
              setState(() => _afternoonStart = start),
          onAfternoonEndChanged: (end) => setState(() => _afternoonEnd = end),
          screenSize: screenSize,
        );
      case 1:
        return _buildToleranceStep(screenSize);
      case 2:
        return _buildSummaryStep(screenSize);
      default:
        return Container();
    }
  }

  Widget _buildToleranceStep(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Tolerance Display Card
        ToleranceDisplayCard(
          tolerance: _tolerance,
          screenSize: screenSize,
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Slider Control Card
        ToleranceSliderControl(
          tolerance: _tolerance,
          onToleranceChanged: (value) => setState(() => _tolerance = value),
          screenSize: screenSize,
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Quick Selection Card
        QuickToleranceSelector(
          tolerance: _tolerance,
          onToleranceChanged: (value) => setState(() => _tolerance = value),
          screenSize: screenSize,
        ),
      ],
    );
  }

  Widget _buildSummaryStep(Size screenSize) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ShiftSummary(
          title: l10n.morningShift,
          icon: Icons.wb_sunny_rounded,
          color: AppTheme.accentBlue,
          startTime: _morningStart,
          endTime: _morningEnd,
          tolerance: _tolerance,
          screenSize: screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        ShiftSummary(
          title: l10n.afternoonShift,
          icon: Icons.wb_twilight_rounded,
          color: AppTheme.accentOrange,
          startTime: _afternoonStart,
          endTime: _afternoonEnd,
          tolerance: _tolerance,
          screenSize: screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        ToleranceSummaryCard(
          tolerance: _tolerance,
          screenSize: screenSize,
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _stepAnimationController.reset();
      setState(() => _currentStep++);
      _stepAnimationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _stepAnimationController.reset();
      setState(() => _currentStep--);
      _stepAnimationController.forward();
    }
  }

  void _saveConfiguration() {
    final l10n = AppLocalizations.of(context);
    widget.onSave(
        _morningStart, _morningEnd, _afternoonStart, _afternoonEnd, _tolerance);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(
                width: AppTheme.getSmallPadding(MediaQuery.of(context).size)),
            Expanded(child: Text(l10n.configurationSavedSuccessfully)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
    Navigator.pop(context);
  }
}
