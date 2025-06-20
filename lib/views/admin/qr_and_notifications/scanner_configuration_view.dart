import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/managers/user_provider.dart';
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
import '../../../managers/turno_provider.dart';
import '../../../models/turno.dart';
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

  // Track if data is being loaded from DB
  bool _isLoadingData = true;
  bool _isSaving = false;

  // To store the turno IDs
  String? _morningTurnoId;
  String? _afternoonTurnoId;
  String? _escuelaId;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with provided values (will be overridden by DB values)
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

    // Load data from database after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTurnosFromDatabase();
    });
  }

  Future<void> _loadTurnosFromDatabase() async {
    setState(() => _isLoadingData = true);

    try {
      // Get current user's school ID
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      _escuelaId = userProvider.currentUser?.escuelaId;

      if (_escuelaId == null) {
        setState(() {
          _errorMessage = 'No se pudo identificar la escuela del usuario.';
          _isLoadingData = false;
        });
        return;
      }

      // Load turnos for the school
      await turnoProvider.loadTurnos(escuelaId: _escuelaId!, context: context);

      // Get morning and afternoon shifts
      final morningShift = turnoProvider.getTurnoByType('Matutino');
      final afternoonShift = turnoProvider.getTurnoByType('Vespertino');

      if (morningShift != null) {
        _morningTurnoId = morningShift.id;
        final morningStartTime =
            turnoProvider.parseTimeString(morningShift.horaInicio);
        final morningEndTime =
            turnoProvider.parseTimeString(morningShift.horaFin);

        if (morningStartTime != null) _morningStart = morningStartTime;
        if (morningEndTime != null) _morningEnd = morningEndTime;

        // If tolerance is the same across shifts, use the first one found
        _tolerance = morningShift.tolerancia;
      }

      if (afternoonShift != null) {
        _afternoonTurnoId = afternoonShift.id;
        final afternoonStartTime =
            turnoProvider.parseTimeString(afternoonShift.horaInicio);
        final afternoonEndTime =
            turnoProvider.parseTimeString(afternoonShift.horaFin);

        if (afternoonStartTime != null) _afternoonStart = afternoonStartTime;
        if (afternoonEndTime != null) _afternoonEnd = afternoonEndTime;
      }

      setState(() => _isLoadingData = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar la configuración: $e';
        _isLoadingData = false;
      });
    }
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
          body: _isLoadingData
              ? _buildLoadingState(screenSize)
              : _errorMessage != null
                  ? _buildErrorState(screenSize, l10n)
                  : FadeTransition(
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
                              padding: EdgeInsets.all(
                                  AppTheme.getMediumPadding(screenSize)),
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
                                padding: EdgeInsets.all(
                                    AppTheme.getMediumPadding(screenSize)),
                                child: _buildCurrentStep(screenSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          bottomNavigationBar: _isLoadingData || _errorMessage != null
              ? null
              : Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
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
                          SizedBox(
                              width: AppTheme.getMediumPadding(screenSize)),
                        Expanded(
                            flex: _currentStep == 0 ? 1 : 2,
                            child: SolidButton(
                              onPressed: _isSaving
                                  ? () {} // Empty callback when saving
                                  : _currentStep < 2
                                      ? _nextStep
                                      : _saveConfiguration,
                              label: _isSaving
                                  ? l10n.saving
                                  : _currentStep < 2
                                      ? l10n.next
                                      : l10n.saveConfiguration,
                              icon: _isSaving
                                  ? null
                                  : _currentStep < 2
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

  Widget _buildLoadingState(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.accentBlue,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Cargando configuración...',
            style: AppTheme.getBodyMedium(screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Size screenSize, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: SingleChildScrollView(
          // Added scroll view to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 64,
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      screenSize.height * 0.3, // Limit error message height
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _errorMessage ?? 'Error desconocido',
                    style: AppTheme.getBodyLarge(screenSize),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: AppTheme.getLargePadding(screenSize)),
              SolidButton(
                onPressed: () {
                  setState(() => _errorMessage = null);
                  _loadTurnosFromDatabase();
                },
                label: 'Reintentar',
                icon: Icons.refresh,
                backgroundColor: AppTheme.accentBlue,
                screenSize: screenSize,
                width: screenSize.width * 0.5,
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              CustomOutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Volver',
                icon: Icons.arrow_back,
                color: AppTheme.getTextPrimaryColor(context),
                screenSize: screenSize,
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _saveConfiguration() async {
    final l10n = AppLocalizations.of(context);

    if (_morningTurnoId == null ||
        _afternoonTurnoId == null ||
        _escuelaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo identificar los turnos o la escuela.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      // Update turnos in the database
      final success = await turnoProvider.updateScannerConfiguration(
        escuelaId: _escuelaId!,
        morningTurnoId: _morningTurnoId!,
        morningStartTime: _morningStart,
        morningEndTime: _morningEnd,
        afternoonTurnoId: _afternoonTurnoId!,
        afternoonStartTime: _afternoonStart,
        afternoonEndTime: _afternoonEnd,
        tolerance: _tolerance,
        context: context,
      );

      if (success) {
        // Call the original onSave callback for backward compatibility
        widget.onSave(_morningStart, _morningEnd, _afternoonStart,
            _afternoonEnd, _tolerance);

        CustomSnackBar.show(
          message: l10n.configurationSavedSuccessfully,
          isError: false,
          context: context,
        );
        Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          message: turnoProvider.error ?? 'Error al guardar la configuración.',
          isError: true,
          context: context,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        message: 'Error al guardar la configuración: $e',
        isError: true,
        context: context,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
