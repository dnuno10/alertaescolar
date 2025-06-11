import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/headers/nav_header.dart';

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
                  title: 'Configuración de Escáner',
                ),

                // Progress indicator
                SliverToBoxAdapter(
                  child: Container(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Row(
                      children: [
                        _buildStepIndicator(
                            0, 'Horarios', Icons.schedule_rounded, screenSize),
                        Expanded(child: _buildProgressLine(0, screenSize)),
                        _buildStepIndicator(
                            1, 'Tolerancia', Icons.timer_rounded, screenSize),
                        Expanded(child: _buildProgressLine(1, screenSize)),
                        _buildStepIndicator(2, 'Resumen',
                            Icons.check_circle_rounded, screenSize),
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
                      label: 'Anterior',
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
                            ? 'Siguiente'
                            : 'Guardar Configuración',
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

  Widget _buildStepIndicator(
      int step, String label, IconData icon, Size screenSize) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: screenSize.height * 0.045,
          height: screenSize.height * 0.045,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.successColor
                : isActive
                    ? AppTheme.accentBlue
                    : AppTheme.getBackgroundColor(context),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                      ? AppTheme.accentBlue
                      : AppTheme.getBorderColor(context),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(screenSize.height * 0.025),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isCompleted || isActive
                ? Colors.white
                : AppTheme.getTextSecondaryColor(context),
            size: screenSize.height * 0.02,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: isActive
                ? AppTheme.getTextPrimaryColor(context)
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step, Size screenSize) {
    final isCompleted = step < _currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 2,
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successColor
            : AppTheme.getBorderColor(context),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildCurrentStep(Size screenSize) {
    switch (_currentStep) {
      case 0:
        return _buildScheduleStep(screenSize);
      case 1:
        return _buildToleranceStep(screenSize);
      case 2:
        return _buildSummaryStep(screenSize);
      default:
        return Container();
    }
  }

  Widget _buildScheduleStep(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
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
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: AppTheme.accentBlue,
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurar Horarios de Turnos',
                          style: AppTheme.getSubtitle1(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Establece las horas de entrada y salida para cada turno',
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getLargePadding(screenSize)),
              _buildModernShiftSection(
                'Turno Matutino',
                Icons.wb_sunny_rounded,
                AppTheme.accentBlue,
                _morningStart,
                _morningEnd,
                (start) => setState(() => _morningStart = start),
                (end) => setState(() => _morningEnd = end),
                screenSize,
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              _buildModernShiftSection(
                'Turno Vespertino',
                Icons.wb_twilight_rounded,
                AppTheme.accentOrange,
                _afternoonStart,
                _afternoonEnd,
                (start) => setState(() => _afternoonStart = start),
                (end) => setState(() => _afternoonEnd = end),
                screenSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToleranceStep(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Tolerance Display Card
        // Large time display
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getLargePadding(screenSize),
            vertical: AppTheme.getMediumPadding(screenSize),
          ),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            border: Border.all(
              color: AppTheme.warningColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_tolerance',
                style: AppTheme.getH1(screenSize).copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w800,
                  fontSize: screenSize.height * 0.05,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'minutos',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'de tolerancia',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Slider Control Card
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
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
              Text(
                'Ajustar Tolerancia',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Time markers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeMarker('0', 0 == _tolerance, screenSize),
                  _buildTimeMarker('15', 15 == _tolerance, screenSize),
                  _buildTimeMarker('30', 30 == _tolerance, screenSize),
                  _buildTimeMarker('45', 45 == _tolerance, screenSize),
                  _buildTimeMarker('60', 60 == _tolerance, screenSize),
                ],
              ),

              // Enhanced Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.warningColor,
                  inactiveTrackColor:
                      AppTheme.warningColor.withValues(alpha: 0.2),
                  thumbColor: AppTheme.warningColor,
                  overlayColor: AppTheme.warningColor.withValues(alpha: 0.1),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14),
                  trackHeight: 8,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: AppTheme.warningColor,
                  valueIndicatorTextStyle:
                      AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  value: _tolerance.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  label: '$_tolerance min',
                  onChanged: (value) =>
                      setState(() => _tolerance = value.round()),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Quick Selection Card
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
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
                    Icons.touch_app_rounded,
                    color: AppTheme.accentPurple,
                    size: screenSize.height * 0.02,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    'Selección Rápida',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              Row(
                children: [5, 10, 15, 20, 30].map((minutes) {
                  final isSelected = _tolerance == minutes;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tolerance = minutes),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.getSmallPadding(screenSize),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.warningColor
                              : AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.warningColor
                                : AppTheme.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.warningColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$minutes',
                              style:
                                  AppTheme.getBodyMedium(screenSize).copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'min',
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppTheme.getTextSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeMarker(String value, bool isActive, Size screenSize) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.warningColor
                : AppTheme.warningColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
        Text(
          '$value min',
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: isActive
                ? AppTheme.warningColor
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: screenSize.height * 0.012,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStep(Size screenSize) {
    return Column(
      children: [
        _buildShiftSummary(
          'Turno Matutino',
          Icons.wb_sunny_rounded,
          AppTheme.accentBlue,
          _morningStart,
          _morningEnd,
          screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        _buildShiftSummary(
          'Turno Vespertino',
          Icons.wb_twilight_rounded,
          AppTheme.accentOrange,
          _afternoonStart,
          _afternoonEnd,
          screenSize,
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Container(
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border:
                Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.warningColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tolerancia para Retrasos',
                      style: AppTheme.getSubtitle1(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Los estudiantes tienen $_tolerance minutos de tolerancia después de la hora de entrada',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize),
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  '$_tolerance min',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ...existing code for _buildModernShiftSection, _buildModernTimeSelector, _buildShiftSummary, _buildStatusCard methods...

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
    widget.onSave(
        _morningStart, _morningEnd, _afternoonStart, _afternoonEnd, _tolerance);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(
                width: AppTheme.getSmallPadding(MediaQuery.of(context).size)),
            Expanded(child: Text('Configuración guardada exitosamente')),
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

  Widget _buildModernShiftSection(
    String title,
    IconData icon,
    Color color,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Function(TimeOfDay) onStartChanged,
    Function(TimeOfDay) onEndChanged,
    Size screenSize,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child:
                    Icon(icon, color: color, size: screenSize.height * 0.025),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildModernTimeSelector(
                    'Entrada', startTime, onStartChanged, color, screenSize),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildModernTimeSelector(
                    'Salida', endTime, onEndChanged, color, screenSize),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
    Color color,
    Size screenSize,
  ) {
    return GestureDetector(
      onTap: () => _showModernTimePicker(time, onChanged),
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              time.format(context),
              style: AppTheme.getH2(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize) * 0.8,
                vertical: AppTheme.getSmallPadding(screenSize) * 0.3,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                'Toca para cambiar',
                textAlign: TextAlign.center,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSummary(
    String title,
    IconData icon,
    Color color,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Size screenSize,
  ) {
    final toleranceEnd = TimeOfDay(
      hour: startTime.hour,
      minute: startTime.minute + _tolerance,
    );

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
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
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child:
                    Icon(icon, color: color, size: screenSize.height * 0.025),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Presente',
                  '${startTime.format(context)} - ${toleranceEnd.format(context)}',
                  AppTheme.successColor,
                  Icons.check_circle_rounded,
                  screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildStatusCard(
                  'Retraso',
                  'Después de ${toleranceEnd.format(context)}',
                  AppTheme.warningColor,
                  Icons.schedule_rounded,
                  screenSize,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.018,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Expanded(
                  child: Text(
                    'Horario: ${startTime.format(context)} - ${endTime.format(context)}',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
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

  Widget _buildStatusCard(
      String title, String time, Color color, IconData icon, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenSize.height * 0.02),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
          Text(
            title,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.2),
          Text(
            time,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showModernTimePicker(
      TimeOfDay initialTime, Function(TimeOfDay) onChanged) {
    showDialog(
      context: context,
      builder: (context) => _ModernTimePickerDialog(
        initialTime: initialTime,
        onTimeSelected: onChanged,
      ),
    );
  }
}

// Include the _ModernTimePickerDialog class from the previous implementation
class _ModernTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const _ModernTimePickerDialog({
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<_ModernTimePickerDialog> createState() =>
      _ModernTimePickerDialogState();
}

class _ModernTimePickerDialogState extends State<_ModernTimePickerDialog> {
  late double _selectedHour;
  late double _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour.toDouble();
    _selectedMinute = widget.initialTime.minute.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
        child: Container(
          width: screenSize.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          AppTheme.getSmallPadding(screenSize) * 0.8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: AppTheme.accentBlue,
                        size: screenSize.height * 0.025,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar Hora',
                            style: AppTheme.getSubtitle1(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Usa los deslizadores para ajustar la hora',
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Time display
                Container(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.accentBlue.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeUnit(
                          _selectedHour.round().toString().padLeft(2, '0'),
                          'Hora'),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getSmallPadding(screenSize)),
                        child: Text(
                          ':',
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildTimeUnit(
                          _selectedMinute.round().toString().padLeft(2, '0'),
                          'Minuto'),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Hour slider
                _buildSliderSection(
                  'Hora',
                  Icons.schedule_rounded,
                  _selectedHour,
                  0,
                  23,
                  24,
                  (value) => setState(() => _selectedHour = value),
                  screenSize,
                ),

                SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                // Minute slider
                _buildSliderSection(
                  'Minuto',
                  Icons.timer_rounded,
                  _selectedMinute,
                  0,
                  55,
                  12,
                  (value) => setState(() => _selectedMinute = value),
                  screenSize,
                  step: 5,
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Quick time presets - Simplified
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horarios comunes',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPresetButton('07:00', 7, 0, screenSize),
                          _buildPresetButton('08:00', 8, 0, screenSize),
                          _buildPresetButton('12:00', 12, 0, screenSize),
                        ],
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPresetButton('13:00', 13, 0, screenSize),
                          _buildPresetButton('17:00', 17, 0, screenSize),
                          _buildPresetButton('18:00', 18, 0, screenSize),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomOutlineButton(
                        onPressed: () => Navigator.pop(context),
                        label: 'Cancelar',
                        color: AppTheme.getTextPrimaryColor(context)
                            .withOpacity(0.5),
                        screenSize: screenSize,
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      flex: 2,
                      child: SolidButton(
                        onPressed: () {
                          widget.onTimeSelected(TimeOfDay(
                            hour: _selectedHour.round(),
                            minute: _selectedMinute.round(),
                          ));
                          Navigator.pop(context);
                        },
                        label: 'Confirmar',
                        icon: Icons.check_rounded,
                        backgroundColor: AppTheme.accentBlue,
                        screenSize: screenSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSliderSection(
    String label,
    IconData icon,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    Size screenSize, {
    int step = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.6),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.015,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.8,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.6),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  value.round().toString().padLeft(2, '0'),
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accentBlue,
              inactiveTrackColor: AppTheme.accentBlue.withValues(alpha: 0.2),
              thumbColor: AppTheme.accentBlue,
              overlayColor: AppTheme.accentBlue.withValues(alpha: 0.1),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          // Time markers - Simplified
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                _buildTimeMarkers(min.round(), max.round(), step, screenSize),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeMarkers(int min, int max, int step, Size screenSize) {
    List<Widget> markers = [];
    int interval = ((max - min) / 4).round(); // Reduce to 4 markers
    if (interval < step) interval = step;

    for (int i = min; i <= max; i += interval) {
      markers.add(
        Text(
          i.toString().padLeft(2, '0'),
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
            fontSize: screenSize.height * 0.012, // Smaller font
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildPresetButton(
      String time, int hour, int minute, Size screenSize) {
    final isSelected =
        _selectedHour.round() == hour && _selectedMinute.round() == minute;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHour = hour.toDouble();
            _selectedMinute = minute.toDouble();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.getSmallPadding(screenSize) * 0.4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(screenSize) * 0.6),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentBlue
                  : AppTheme.getBorderColor(context),
            ),
          ),
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: isSelected
                  ? Colors.white
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
              fontSize: screenSize.height * 0.014,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.getH2(screenSize).copyWith(
            color: AppTheme.accentBlue,
            fontWeight: FontWeight.w800,
            fontSize: screenSize.height * 0.035,
            letterSpacing: 1,
          ),
        ),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
            fontSize: screenSize.height * 0.012,
          ),
        ),
      ],
    );
  }
}
