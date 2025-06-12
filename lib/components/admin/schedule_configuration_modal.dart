import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ScheduleConfigurationModal extends StatefulWidget {
  final Size screenSize;
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final int initialClassDuration;
  final int initialBreakDuration;
  final int initialLongBreakDuration;
  final TimeOfDay initialLongBreakStart;
  final Function(
    TimeOfDay startTime,
    TimeOfDay endTime,
    int classDuration,
    int breakDuration,
    int longBreakDuration,
    TimeOfDay longBreakStart,
  ) onConfigurationSaved;

  const ScheduleConfigurationModal({
    super.key,
    required this.screenSize,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.initialClassDuration,
    required this.initialBreakDuration,
    required this.initialLongBreakDuration,
    required this.initialLongBreakStart,
    required this.onConfigurationSaved,
  });

  @override
  State<ScheduleConfigurationModal> createState() =>
      _ScheduleConfigurationModalState();
}

class _ScheduleConfigurationModalState extends State<ScheduleConfigurationModal>
    with TickerProviderStateMixin {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _classDuration;
  late int _breakDuration;
  late int _longBreakDuration;
  late TimeOfDay _longBreakStart;
  late int _classesPerDay;
  late int _breaksPerDay;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _classDuration = widget.initialClassDuration;
    _breakDuration = widget.initialBreakDuration;
    _longBreakDuration = widget.initialLongBreakDuration;
    _longBreakStart = widget.initialLongBreakStart;
    _classesPerDay = 8; // Default value
    _breaksPerDay = 2; // Default value

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: widget.screenSize.height * 0.9,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                      AppTheme.getLargeRadius(widget.screenSize)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: widget.screenSize.height * 0.015,
                    offset: Offset(0, -widget.screenSize.height * 0.005),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(
                        top: AppTheme.getSmallPadding(widget.screenSize)),
                    width: widget.screenSize.width * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextSecondaryColor(context)
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getMediumPadding(widget.screenSize)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              AppTheme.getSmallPadding(widget.screenSize) *
                                  0.5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(widget.screenSize)),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            color: AppTheme.accentPurple,
                            size: widget.screenSize.height * 0.025,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(widget.screenSize)),
                        Expanded(
                          child: Text(
                            'Configuración de Horarios',
                            style: AppTheme.getH2(widget.screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppTheme.getTextSecondaryColor(context),
                            size: widget.screenSize.height * 0.025,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(
                          AppTheme.getMediumPadding(widget.screenSize)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Schedule Preview
                          _buildSchedulePreview(),

                          SizedBox(
                              height:
                                  AppTheme.getLargePadding(widget.screenSize)),

                          // School Hours Section
                          _buildConfigSection(
                            'Horario Escolar',
                            Icons.access_time_rounded,
                            AppTheme.accentBlue,
                            [
                              _buildTimeSlider(
                                'Hora de Inicio',
                                _startTime,
                                (time) => setState(() => _startTime = time),
                                Icons.play_circle_outline_rounded,
                              ),
                              SizedBox(
                                  height: AppTheme.getMediumPadding(
                                      widget.screenSize)),
                              _buildTimeSlider(
                                'Hora de Fin',
                                _endTime,
                                (time) => setState(() => _endTime = time),
                                Icons.stop_circle_outlined,
                              ),
                            ],
                          ),

                          SizedBox(
                              height:
                                  AppTheme.getLargePadding(widget.screenSize)),

                          // Schedule Structure Section
                          _buildConfigSection(
                            'Estructura del Horario',
                            Icons.view_module_rounded,
                            AppTheme.accentPurple,
                            [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCountSlider(
                                      'Clases por Día',
                                      _classesPerDay,
                                      4,
                                      12,
                                      (value) => setState(
                                          () => _classesPerDay = value),
                                      'clases',
                                      Icons.class_rounded,
                                      AppTheme.accentPurple,
                                    ),
                                  ),
                                  SizedBox(
                                      width: AppTheme.getMediumPadding(
                                          widget.screenSize)),
                                  Expanded(
                                    child: _buildCountSlider(
                                      'Recreos por Día',
                                      _breaksPerDay,
                                      1,
                                      4,
                                      (value) =>
                                          setState(() => _breaksPerDay = value),
                                      'recreos',
                                      Icons.coffee_rounded,
                                      AppTheme.warningColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(
                              height:
                                  AppTheme.getLargePadding(widget.screenSize)),

                          // Class Duration Section
                          _buildConfigSection(
                            'Duración de Clases',
                            Icons.timer_rounded,
                            AppTheme.successColor,
                            [
                              _buildDurationSlider(
                                'Duración de cada clase',
                                _classDuration,
                                15,
                                120,
                                (value) =>
                                    setState(() => _classDuration = value),
                                'min',
                              ),
                              SizedBox(
                                  height: AppTheme.getMediumPadding(
                                      widget.screenSize)),
                              _buildDurationSlider(
                                'Descanso entre clases',
                                _breakDuration,
                                5,
                                30,
                                (value) =>
                                    setState(() => _breakDuration = value),
                                'min',
                              ),
                            ],
                          ),

                          SizedBox(
                              height:
                                  AppTheme.getLargePadding(widget.screenSize)),

                          // Long Break Section
                          _buildConfigSection(
                            'Recreo Principal',
                            Icons.coffee_rounded,
                            AppTheme.warningColor,
                            [
                              _buildTimeSlider(
                                'Hora del Recreo',
                                _longBreakStart,
                                (time) =>
                                    setState(() => _longBreakStart = time),
                                Icons.free_breakfast_rounded,
                              ),
                              SizedBox(
                                  height: AppTheme.getMediumPadding(
                                      widget.screenSize)),
                              _buildDurationSlider(
                                'Duración del recreo',
                                _longBreakDuration,
                                10,
                                60,
                                (value) =>
                                    setState(() => _longBreakDuration = value),
                                'min',
                              ),
                            ],
                          ),

                          SizedBox(
                              height:
                                  AppTheme.getLargePadding(widget.screenSize) *
                                      2),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getMediumPadding(widget.screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.getBorderColor(context)
                              .withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close_rounded),
                              label: Text('Cancelar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppTheme.getTextSecondaryColor(context),
                                side: BorderSide(
                                  color: AppTheme.getBorderColor(context),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.getMediumPadding(
                                          widget.screenSize) *
                                      1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(
                                          widget.screenSize)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  AppTheme.getMediumPadding(widget.screenSize)),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _saveConfiguration,
                              icon:
                                  Icon(Icons.save_rounded, color: Colors.white),
                              label: Text('Aplicar Configuración'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentPurple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.getMediumPadding(
                                          widget.screenSize) *
                                      1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(
                                          widget.screenSize)),
                                ),
                                elevation: 0,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildSchedulePreview() {
    final totalHours = _calculateTotalHours();

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_rounded,
                color: AppTheme.accentPurple,
                size: widget.screenSize.height * 0.022,
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Text(
                'Vista Previa del Horario',
                style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildPreviewStat(
                  'Horario Escolar',
                  '${_formatTime(_startTime)} - ${_formatTime(_endTime)}',
                  Icons.schedule_rounded,
                  AppTheme.accentBlue,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: _buildPreviewStat(
                  'Clases por Día',
                  '$_classesPerDay clases',
                  Icons.class_rounded,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildPreviewStat(
                  'Duración Total',
                  totalHours,
                  Icons.timer_rounded,
                  AppTheme.warningColor,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: _buildPreviewStat(
                  'Recreos por Día',
                  '$_breaksPerDay recreos',
                  Icons.coffee_rounded,
                  AppTheme.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: widget.screenSize.height * 0.02),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
          Text(
            label,
            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.2),
          Text(
            value,
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
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
                    AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: widget.screenSize.height * 0.022,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Text(
                title,
                style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeSlider(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
    IconData icon,
  ) {
    final hourValue = time.hour.toDouble();
    final minuteValue = time.minute.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and current time display
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                  AppTheme.getSmallPadding(widget.screenSize) * 0.4),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize) * 0.6),
              ),
              child: Icon(
                icon,
                color: AppTheme.accentBlue,
                size: widget.screenSize.height * 0.015,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
            Text(
              label,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(widget.screenSize),
                vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize)),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _formatTime(time),
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

        // Hour slider
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hora',
                    style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${hourValue.round().toString().padLeft(2, '0')}h',
                    key: ValueKey('hour_${hourValue.round()}'),
                    style: AppTheme.getCaption(widget.screenSize).copyWith(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.accentBlue,
                  inactiveTrackColor:
                      AppTheme.accentBlue.withValues(alpha: 0.3),
                  thumbColor: AppTheme.accentBlue,
                  overlayColor: AppTheme.accentBlue.withValues(alpha: 0.2),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                  trackHeight: 4,
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 18),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: AppTheme.accentBlue,
                  valueIndicatorTextStyle:
                      AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  showValueIndicator: ShowValueIndicator.onlyForContinuous,
                ),
                child: Slider(
                  value: hourValue,
                  min: 6,
                  max: 22,
                  divisions: 16,
                  label: '${hourValue.round()}h',
                  onChanged: (value) {
                    onChanged(TimeOfDay(
                      hour: value.round(),
                      minute: time.minute,
                    ));
                  },
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

        // Minute slider
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Minutos',
                    style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${minuteValue.round().toString().padLeft(2, '0')} min',
                    key: ValueKey('minute_${minuteValue.round()}'),
                    style: AppTheme.getCaption(widget.screenSize).copyWith(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.accentBlue,
                  inactiveTrackColor:
                      AppTheme.accentBlue.withValues(alpha: 0.3),
                  thumbColor: AppTheme.accentBlue,
                  overlayColor: AppTheme.accentBlue.withValues(alpha: 0.2),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                  trackHeight: 4,
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 18),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: AppTheme.accentBlue,
                  valueIndicatorTextStyle:
                      AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  showValueIndicator: ShowValueIndicator.onlyForContinuous,
                ),
                child: Slider(
                  value: minuteValue,
                  min: 0,
                  max: 55,
                  divisions: 11,
                  label: '${minuteValue.round()} min',
                  onChanged: (value) {
                    onChanged(TimeOfDay(
                      hour: time.hour,
                      minute: value.round(),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                  AppTheme.getSmallPadding(widget.screenSize) * 0.4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize) * 0.6),
              ),
              child: Icon(
                icon,
                color: color,
                size: widget.screenSize.height * 0.015,
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
            Expanded(
              child: Text(
                label,
                style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        Text(
          '$value $unit',
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.3),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: color,
            valueIndicatorTextStyle:
                AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            showValueIndicator: ShowValueIndicator.onlyForContinuous,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value $unit',
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        Text(
          '$value $unit',
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            color: AppTheme.warningColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.warningColor,
            inactiveTrackColor: AppTheme.warningColor.withValues(alpha: 0.3),
            thumbColor: AppTheme.warningColor,
            overlayColor: AppTheme.warningColor.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: AppTheme.warningColor,
            valueIndicatorTextStyle:
                AppTheme.getCaptionSmall(widget.screenSize).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            showValueIndicator: ShowValueIndicator.onlyForContinuous,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: ((max - min) / 5).round(),
            label: '$value $unit',
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateTotalHours() {
    final startMinutes = (_startTime.hour * 60) + _startTime.minute;
    final endMinutes = (_endTime.hour * 60) + _endTime.minute;
    final totalMinutes = endMinutes - startMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
  }

  void _saveConfiguration() {
    widget.onConfigurationSaved(
      _startTime,
      _endTime,
      _classDuration,
      _breakDuration,
      _longBreakDuration,
      _longBreakStart,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Configuración de horarios aplicada exitosamente',
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        ),
      ),
    );

    Navigator.pop(context);
  }
}
