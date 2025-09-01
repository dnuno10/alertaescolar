import 'package:alertaescolar/components/admin/scanner_config/tolerance_display_card.dart';
import 'package:alertaescolar/components/admin/scanner_config/tolerance_slider_control.dart';
import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/admin/scanner_config/step_indicator.dart';
import '../../../components/admin/scanner_config/progress_line.dart';
import '../../../components/admin/scanner_config/shift_summary.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../managers/turno_provider.dart';

class ScannerConfigurationView extends StatefulWidget {
  /// Props por compatibilidad hacia atrás (se siguen enviando a onSave),
  /// pero la UI se construye dinámicamente desde BD.
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _stepAnimationController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _escuelaId;
  int _currentStep = 0; // 0=edición, 1=resumen

  /// Estructura editable por turno en la vista
  final List<_TurnoForm> _forms = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _stepAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _stepAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepAnimationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      _escuelaId = userProvider.currentUser?.escuelaId;
      if (_escuelaId == null || _escuelaId!.trim().isEmpty) {
        setState(() {
          _error = AppLocalizations.of(context).schoolNotIdentified;
          _isLoading = false;
        });
        return;
      }

      await turnoProvider.loadTurnos(escuelaId: _escuelaId!);

      _forms
        ..clear()
        ..addAll(turnoProvider.turnos.map((t) {
          final start = turnoProvider.parseTimeString(t.horaInicio) ??
              const TimeOfDay(hour: 7, minute: 0);
          final end = turnoProvider.parseTimeString(t.horaFin) ??
              const TimeOfDay(hour: 13, minute: 0);
          final tol = t.tolerancia;
          return _TurnoForm(
            id: t.id,
            nombre: t.turno,
            start: start,
            end: end,
            tolerancia: tol,
          );
        }))
        // Ordenar por hora de inicio (más temprano primero)
        ..sort((a, b) {
          final aMin = a.start.hour * 60 + a.start.minute;
          final bMin = b.start.hour * 60 + b.start.minute;
          return aMin.compareTo(bMin);
        });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)
            .errorLoadingConfiguration(e.toString());
        _isLoading = false;
      });
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Consumer<ThemeProvider>(
      builder: (context, theme, child) => Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: _isLoading
            ? _buildLoading(size)
            : _error != null
                ? _buildError(size, l10n)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        NavHeader(title: l10n.scannerConfiguration),
                        // Paso / progreso
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                EdgeInsets.all(AppTheme.getMediumPadding(size)),
                            child: Row(
                              children: [
                                StepIndicator(
                                  step: 0,
                                  currentStep: _currentStep,
                                  label: l10n.schedules,
                                  icon: Icons.schedule_rounded,
                                  screenSize: size,
                                ),
                                Expanded(
                                  child: ProgressLine(
                                    step: 0,
                                    currentStep: _currentStep,
                                    screenSize: size,
                                  ),
                                ),
                                StepIndicator(
                                  step: 1,
                                  currentStep: _currentStep,
                                  label: l10n.summary,
                                  icon: Icons.check_circle_rounded,
                                  screenSize: size,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Contenido
                        SliverToBoxAdapter(
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  AppTheme.getMediumPadding(size)),
                              child: _currentStep == 0
                                  ? _buildEditor(size)
                                  : _buildSummary(size),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: _isLoading || _error != null
            ? null
            : Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
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
                            onPressed: _prevStep,
                            label: l10n.previous,
                            icon: Icons.arrow_back_rounded,
                            color: AppTheme.getTextPrimaryColor(context)
                                .withOpacity(0.5),
                            screenSize: size,
                          ),
                        ),
                      if (_currentStep > 0)
                        SizedBox(width: AppTheme.getMediumPadding(size)),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Expanded(
                              child: SolidButton(
                                onPressed: _isSaving
                                    ? null
                                    : (_currentStep == 0 ? _nextStep : _save),
                                label: _isSaving
                                    ? l10n.saving
                                    : (_currentStep == 0
                                        ? l10n.next
                                        : l10n.saveConfiguration),
                                icon: _currentStep == 0
                                    ? Icons.arrow_forward_rounded
                                    : Icons.save_rounded,
                                backgroundColor: AppTheme.accentBlue,
                                screenSize: size,
                                isLoading: _isSaving,
                                showLoaderInIconSlot:
                                    true, // usa el loader del botón
                                loadingIndicatorSize: 20,
                                enableHaptics: true,
                                semanticsLabel: l10n.saveConfiguration,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoading(Size size) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.accentBlue),
            SizedBox(height: AppTheme.getMediumPadding(size)),
            Text('Cargando configuración...',
                style: AppTheme.getBodyMedium(size)),
          ],
        ),
      );

  Widget _buildError(Size size, AppLocalizations l10n) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getLargePadding(size)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppTheme.errorColor, size: 64),
              SizedBox(height: AppTheme.getMediumPadding(size)),
              Text(_error ?? 'Error desconocido',
                  style: AppTheme.getBodyLarge(size),
                  textAlign: TextAlign.center),
              SizedBox(height: AppTheme.getLargePadding(size)),
              SolidButton(
                onPressed: () {
                  setState(() => _error = null);
                  _load();
                },
                label: 'Reintentar',
                icon: Icons.refresh,
                backgroundColor: AppTheme.accentBlue,
                screenSize: size,
                width: size.width * 0.5,
              ),
              SizedBox(height: AppTheme.getMediumPadding(size)),
              CustomOutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Volver',
                icon: Icons.arrow_back,
                color: AppTheme.getTextPrimaryColor(context),
                screenSize: size,
              ),
            ],
          ),
        ),
      );

  // ----------- Paso 0: Editor dinámico de turnos -----------
  Widget _buildEditor(Size size) {
    Future<void> pickStart(_TurnoForm f) async {
      final res = await _showCupertinoTimePicker(
        context: context,
        initial: f.start,
        title: 'Selecciona hora',
      );
      if (res != null) setState(() => f.start = res);
    }

    Future<void> pickEnd(_TurnoForm f) async {
      final res = await _showCupertinoTimePicker(
        context: context,
        initial: f.end,
        title: 'Selecciona hora',
      );
      if (res != null) setState(() => f.end = res);
    }

    // Formateo 12h para las cajas clickeables (Inicio/Fin)
    String _formatTimeOfDay12(TimeOfDay t) {
      final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final mm = t.minute.toString().padLeft(2, '0');
      final period = t.hour >= 12 ? 'PM' : 'AM';
      return '${h12.toString().padLeft(2, '0')}:$mm $period';
    }

    return Column(
      children: [
        ..._forms.map((f) {
          return Container(
            margin: EdgeInsets.only(bottom: AppTheme.getMediumPadding(size)),
            padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(size)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.nombre,
                    style: AppTheme.getH2(size).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: AppTheme.getSmallPadding(size)),

                // Hora inicio / fin con picker iOS-like
                Row(
                  children: [
                    Expanded(
                      child: _TimeBox(
                        label: 'Inicio',
                        // Antes: turnoProvider.formatTimeOfDay(f.start)
                        value: _formatTimeOfDay12(f.start),
                        onTap: () => pickStart(f),
                      ),
                    ),
                    SizedBox(width: AppTheme.getMediumPadding(size)),
                    Expanded(
                      child: _TimeBox(
                        label: 'Fin',
                        // Antes: turnoProvider.formatTimeOfDay(f.end)
                        value: _formatTimeOfDay12(f.end),
                        onTap: () => pickEnd(f),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.getMediumPadding(size)),

                // Tolerancia por turno
                ToleranceDisplayCard(tolerance: f.tolerancia, screenSize: size),
                SizedBox(height: AppTheme.getSmallPadding(size)),
                ToleranceSliderControl(
                  tolerance: f.tolerancia,
                  onToleranceChanged: (val) =>
                      setState(() => f.tolerancia = val),
                  screenSize: size,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ----------- Paso 1: Resumen -----------
  Widget _buildSummary(Size size) {
    return Column(
      children: _forms.map((f) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.getMediumPadding(size)),
          child: ShiftSummary(
            title: f.nombre,
            icon: Icons.access_time_rounded,
            color: AppTheme.accentBlue,
            startTime: f.start,
            endTime: f.end,
            tolerance: f.tolerancia,
            screenSize: size,
          ),
        );
      }).toList(),
    );
  }

  // ----------- Navegación -----------
  void _nextStep() {
    // Validación rápida: start < end para todos
    for (final f in _forms) {
      final a = f.start.hour * 60 + f.start.minute;
      final b = f.end.hour * 60 + f.end.minute;
      if (a >= b) {
        CustomSnackBar.show(
          context: context,
          message:
              'En "${f.nombre}", la hora de inicio debe ser menor a la de fin.',
          isError: true,
        );
        return;
      }
    }
    if (_currentStep == 0) {
      _stepAnimationController.reset();
      setState(() => _currentStep = 1);
      _stepAnimationController.forward();
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      _stepAnimationController.reset();
      setState(() => _currentStep = 0);
      _stepAnimationController.forward();
    }
  }

  // ----------- Guardado -----------
  Future<void> _save() async {
    if (_escuelaId == null || _escuelaId!.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'No se pudo identificar la escuela.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);

      final patches = _forms
          .map((f) => TurnoPatch(
                id: f.id,
                start: f.start,
                end: f.end,
                tolerancia: f.tolerancia,
              ))
          .toList();

      final ok = await turnoProvider.updateTurnosBatch(patches);

      if (ok) {
        // Callback de compatibilidad hacia atrás (toma 1er y 2do turno si existen)
        final t0 = _forms.isNotEmpty ? _forms[0] : null;
        final t1 = _forms.length > 1 ? _forms[1] : null;

        widget.onSave(
          t0?.start ?? const TimeOfDay(hour: 7, minute: 0),
          t0?.end ?? const TimeOfDay(hour: 13, minute: 0),
          t1?.start ?? const TimeOfDay(hour: 13, minute: 0),
          t1?.end ?? const TimeOfDay(hour: 18, minute: 0),
          t0?.tolerancia ?? 10,
        );

        CustomSnackBar.show(
          context: context,
          message: AppLocalizations.of(context).configurationSavedSuccessfully,
          isError: false,
        );
        if (mounted) Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context: context,
          message: turnoProvider.error ?? 'Error al guardar la configuración.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: 'Error al guardar la configuración: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ----------- Picker estilo iOS (ruletas) -----------
  Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initial,
    String title = 'Selecciona hora',
  }) async {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Convertir inicial a 12h
    int hour12 = initial.hour % 12;
    if (hour12 == 0) hour12 = 12;
    int selectedHourIndex = hour12 - 1; // 0..11
    int selectedMinuteIndex = initial.minute; // 0..59
    int selectedPeriodIndex = initial.hour >= 12 ? 1 : 0; // 0=AM, 1=PM

    final hours = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    final minutes =
        List.generate(60, (i) => i.toString().padLeft(2, '0')); // 00..59
    final periods = const ['AM', 'PM'];

    final hourController =
        FixedExtentScrollController(initialItem: selectedHourIndex);
    final minuteController =
        FixedExtentScrollController(initialItem: selectedMinuteIndex);
    final periodController =
        FixedExtentScrollController(initialItem: selectedPeriodIndex);

    TimeOfDay buildTime() {
      final h12 = (selectedHourIndex + 1); // 1..12
      int h24;
      if (selectedPeriodIndex == 0) {
        // AM
        h24 = (h12 == 12) ? 0 : h12;
      } else {
        // PM
        h24 = (h12 == 12) ? 12 : h12 + 12;
      }
      return TimeOfDay(hour: h24, minute: selectedMinuteIndex);
    }

    final selectedTextStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppTheme.getTextPrimaryColor(context),
    );
    final unselectedTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppTheme.getTextSecondaryColor(context),
    );

    return await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Container(
            height: size.height * 0.38,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.getLargeRadius(size)),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (ctx, setStateSB) {
                return Column(
                  children: [
                    // Header con diseño consistente: Cancelar (izq), título (centro), Listo (der)
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx, null),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                foregroundColor: AppTheme.errorColor,
                              ),
                              child: Text('Cancelar',
                                  style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018)),
                            ),
                          ),
                          Center(
                            child: Text(
                              title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: size.height * 0.018,
                                color: AppTheme.getTextPrimaryColor(context),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx, buildTime()),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                foregroundColor: AppTheme.accentBlue,
                              ),
                              child: Text('Listo',
                                  style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Picker 12h con AM/PM
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getMediumPadding(size),
                        ),
                        child: Row(
                          children: [
                            // Horas
                            Expanded(
                              flex: 4,
                              child: CupertinoPicker(
                                scrollController: hourController,
                                itemExtent: 40,
                                magnification: 1.1,
                                useMagnifier: true,
                                squeeze: 1.2,
                                onSelectedItemChanged: (i) {
                                  setStateSB(() => selectedHourIndex = i);
                                },
                                selectionOverlay:
                                    const CupertinoPickerDefaultSelectionOverlay(),
                                children: List.generate(12, (i) {
                                  final isSel = i == selectedHourIndex;
                                  return Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 120),
                                      style: isSel
                                          ? (selectedTextStyle ??
                                              const TextStyle())
                                          : (unselectedTextStyle ??
                                              const TextStyle()),
                                      child: Text(hours[i]),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(width: AppTheme.getSmallPadding(size)),
                            // Minutos
                            Expanded(
                              flex: 4,
                              child: CupertinoPicker(
                                scrollController: minuteController,
                                itemExtent: 40,
                                magnification: 1.1,
                                useMagnifier: true,
                                squeeze: 1.2,
                                onSelectedItemChanged: (i) {
                                  setStateSB(() => selectedMinuteIndex = i);
                                },
                                selectionOverlay:
                                    const CupertinoPickerDefaultSelectionOverlay(),
                                children: List.generate(60, (i) {
                                  final isSel = i == selectedMinuteIndex;
                                  return Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 120),
                                      style: isSel
                                          ? (selectedTextStyle ??
                                              const TextStyle())
                                          : (unselectedTextStyle ??
                                              const TextStyle()),
                                      child: Text(minutes[i]),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(width: AppTheme.getSmallPadding(size)),
                            // AM/PM
                            Expanded(
                              flex: 3,
                              child: CupertinoPicker(
                                scrollController: periodController,
                                itemExtent: 40,
                                magnification: 1.1,
                                useMagnifier: true,
                                squeeze: 1.2,
                                onSelectedItemChanged: (i) {
                                  setStateSB(() => selectedPeriodIndex = i);
                                },
                                selectionOverlay:
                                    const CupertinoPickerDefaultSelectionOverlay(),
                                children: List.generate(periods.length, (i) {
                                  final isSel = i == selectedPeriodIndex;
                                  return Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 120),
                                      style: isSel
                                          ? (selectedTextStyle ??
                                              const TextStyle())
                                          : (unselectedTextStyle ??
                                              const TextStyle()),
                                      child: Text(periods[i]),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Modelo interno para edición en la vista
class _TurnoForm {
  final String id;
  final String nombre;
  TimeOfDay start;
  TimeOfDay end;
  int tolerancia;
  _TurnoForm({
    required this.id,
    required this.nombre,
    required this.start,
    required this.end,
    required this.tolerancia,
  });
}

/// Caja simple para mostrar un valor de hora y abrir el picker
class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TimeBox({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(size),
          vertical: AppTheme.getSmallPadding(size),
        ),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTheme.getCaption(size)
                    .copyWith(color: AppTheme.getTextSecondaryColor(context))),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: AppTheme.accentBlue),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTheme.getBodyLarge(size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
