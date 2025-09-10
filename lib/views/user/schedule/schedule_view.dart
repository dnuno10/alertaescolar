// lib/views/schedule/schedule_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';

import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/managers/schedule_provider.dart';

// Reusamos tu chip selector minimalista del módulo de administración
import 'package:alertaescolar/components/admin/schedule/day_filter.dart';

class ScheduleView extends StatefulWidget {
  final Alumno student;

  const ScheduleView({
    super.key,
    required this.student,
  });

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  /// 'lunes'..'domingo' → lista de clases ordenadas por horaInicio
  Map<String, List<ClaseHorario>> _byDay = {
    for (final d in _orderedDays) d: <ClaseHorario>[],
  };

  /// Día seleccionado: null = "Todos" (igual que en DayFilter de admin)
  String? _selectedDayKey;

  bool _loading = true;
  String? _error;

  static const List<String> _orderedDays = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDayKey = null; // Arranca en "Todos" (coincide con DayFilter)
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ======================
  // Data loading
  // ======================
  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      // Catálogos necesarios
      await scheduleProvider.loadMaterias(
        escuelaId: widget.student.idEscuela,
        context: null,
      );

      await scheduleProvider.loadGrupos(
        escuelaId: widget.student.idEscuela,
        loadAll: true,
        context: null,
      );

      // Horarios del grupo del alumno
      await scheduleProvider.loadHorarios(
        escuelaId: widget.student.idEscuela,
        grupoId: widget.student.idGrupo,
        context: null,
      );

      if (!mounted) return;

      final horarios =
          scheduleProvider.getHorariosForGroupId(widget.student.idGrupo);

      setState(() {
        _byDay = _organizeByDay(horarios);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error al cargar el horario: $e';
      });
    }
  }

  Map<String, List<ClaseHorario>> _organizeByDay(List<ClaseHorario> horarios) {
    bool isOnDay(ClaseHorario s, String key) {
      switch (key) {
        case 'lunes':
          return s.lunes;
        case 'martes':
          return s.martes;
        case 'miercoles':
          return s.miercoles;
        case 'jueves':
          return s.jueves;
        case 'viernes':
          return s.viernes;
        case 'sabado':
          return s.sabado;
        case 'domingo':
          return s.domingo;
        default:
          return false;
      }
    }

    final map = {for (final d in _orderedDays) d: <ClaseHorario>[]};
    for (final s in horarios) {
      for (final d in _orderedDays) {
        if (isOnDay(s, d)) map[d]!.add(s);
      }
    }
    for (final d in _orderedDays) {
      map[d]!.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            NavHeader(title: l10n.weeklySchedule),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header alumne — minimal, sin sombras
                    _StudentHeader(student: widget.student, screenSize: size),

                    SizedBox(height: AppTheme.getMediumPadding(size)),

                    // DayFilter (mismo componente y UX del admin)
                    DayFilter(
                      selectedDayKey: _selectedDayKey, // null = "Todos"
                      onDaySelected: (key) {
                        HapticFeedback.mediumImpact();
                        setState(() => _selectedDayKey = key);
                      },
                      screenSize: size,
                    ),

                    SizedBox(height: AppTheme.getLargePadding(size)),

                    if (_loading)
                      _LoadingPlaceholder(screenSize: size)
                    else if (_error != null)
                      _ErrorBlock(
                        message: _error!,
                        onRetry: _loadAll,
                        screenSize: size,
                      )
                    else
                      _buildContent(size, l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Size size, AppLocalizations l10n) {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final subjects = scheduleProvider.materias;

    // ======================
    // Vista "Día"
    // ======================
    if (_selectedDayKey != null) {
      final key = _selectedDayKey!;
      final list = _byDay[key] ?? const <ClaseHorario>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderMinimal(
            title: _dayName(context, key),
            subtitle:
                '${widget.student.grupo} · ${list.length} ${list.length == 1 ? "clase" : "clases"}',
            color: _dayAccent(key),
            icon: _dayIcon(key),
            screenSize: size,
          ),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          if (list.isEmpty)
            _EmptyStrip(screenSize: size)
          else
            ...list.map((c) {
              final materia = _findMateria(subjects, c.idMateria);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: AppTheme.getSmallPadding(size),
                ),
                child: _MinimalClassRow(
                  start: _format12(c.horaInicio),
                  end: _format12(c.horaFin),
                  title: _subjectName(materia),
                  classroom: c.aula,
                  teacher: materia?.profesor,
                  screenSize: size,
                ),
              );
            }),
        ],
      );
    }

    // ======================
    // Vista "Semana completa"
    // ======================
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderMinimal(
          title: l10n.scheduleOf(widget.student.grupo),
          subtitle: l10n.filterByDay,
          screenSize: size,
        ),
        SizedBox(height: AppTheme.getMediumPadding(size)),
        ..._orderedDays.map((d) {
          final color = _dayAccent(d);
          final list = _byDay[d] ?? const <ClaseHorario>[];

          return Padding(
            padding: EdgeInsets.only(bottom: AppTheme.getMediumPadding(size)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayStrip(
                  color: color,
                  icon: _dayIcon(d),
                  label: _dayName(context, d),
                  trailing:
                      '${list.length} ${list.length == 1 ? "clase" : "clases"}',
                  screenSize: size,
                ),
                SizedBox(height: AppTheme.getSmallPadding(size)),
                if (list.isEmpty)
                  _EmptyStrip(screenSize: size)
                else
                  ...list.map((c) {
                    final materia = _findMateria(subjects, c.idMateria);
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppTheme.getSmallPadding(size) * 0.75,
                      ),
                      child: _MinimalClassRow(
                        start: _format12(c.horaInicio),
                        end: _format12(c.horaFin),
                        title: _subjectName(materia),
                        classroom: c.aula,
                        teacher: materia?.profesor,
                        screenSize: size,
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ======================
  // Helpers de presentación
  // ======================
  String _dayName(BuildContext context, String d) {
    final l = AppLocalizations.of(context);
    switch (d) {
      case 'lunes':
        return l.monday;
      case 'martes':
        return l.tuesday;
      case 'miercoles':
        return l.wednesday;
      case 'jueves':
        return l.thursday;
      case 'viernes':
        return l.friday;
      case 'sabado':
        return l.saturday;
      case 'domingo':
        return l.sunday;
      default:
        return l.unknown;
    }
  }

  Color _dayAccent(String d) {
    switch (d) {
      case 'lunes':
        return AppTheme.accentBlue;
      case 'martes':
        return AppTheme.accentPurple;
      case 'miercoles':
        return Colors.green;
      case 'jueves':
        return Colors.orange;
      case 'viernes':
        return Colors.red;
      case 'sabado':
        return Colors.indigo;
      case 'domingo':
        return Colors.pink;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _dayIcon(String d) {
    switch (d) {
      case 'lunes':
        return Icons.looks_one_rounded;
      case 'martes':
        return Icons.looks_two_rounded;
      case 'miercoles':
        return Icons.looks_3_rounded;
      case 'jueves':
        return Icons.looks_4_rounded;
      case 'viernes':
        return Icons.looks_5_rounded;
      case 'sabado':
        return Icons.looks_6_rounded;
      case 'domingo':
        return Icons.weekend_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Materia? _findMateria(List<Materia> list, String id) {
    try {
      return list.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  String _subjectName(Materia? m) {
    if (m == null) return 'Materia';
    final n = (m.nombre).toString().trim();
    return n.isEmpty ? 'Materia' : n;
  }

  /// Mismo formateo 12h de ScheduleManagement (robusto a "HH:mm" o "HH:mm:ss")
  String _format12(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h24 = int.tryParse(parts[0]) ?? 0;
    final m = parts[1].padLeft(2, '0');
    final period = (h24 >= 12) ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final h = h12.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

// ===================================================================
// =============== Widgets internos minimalistas (sin sombras) =======
// ===================================================================

/// Tarjeta minimalista con la info del alumno (sin sombras)
class _StudentHeader extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const _StudentHeader({
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final accentChoices = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    final accent = accentChoices[student.hashCode % accentChoices.length];

    final rad = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.16,
            height: screenSize.width * 0.16,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(rad),
              // ignore: deprecated_member_use
              border: Border.all(color: accent.withOpacity(0.30), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              (student.nombre.isNotEmpty ? student.nombre[0] : 'A')
                  .toUpperCase(),
              style: AppTheme.getH2(screenSize).copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
                Row(
                  children: [
                    _ChipTiny(
                      label: student.grupo,
                      color: accent,
                      screenSize: screenSize,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    _ChipTiny(
                      label: student.vinculado ? 'Activo' : 'Inactivo',
                      color: student.vinculado
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTiny extends StatelessWidget {
  final String label;
  final Color color;
  final Size screenSize;

  const _ChipTiny({
    required this.label,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final rad = AppTheme.getSmallRadius(screenSize);
    final pad = AppTheme.getSmallPadding(screenSize);
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: pad * 0.75, vertical: pad * 0.25),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(rad),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.28), width: 1),
      ),
      child: Text(
        label,
        style: AppTheme.getCaptionSmall(screenSize).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Encabezado simple (sin sombras) — mismo estilo que en management
class _HeaderMinimal extends StatelessWidget {
  final String title;
  final String subtitle;
  final Size screenSize;
  final Color? color;
  final IconData? icon;

  const _HeaderMinimal({
    required this.title,
    required this.subtitle,
    required this.screenSize,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.getMediumPadding(screenSize);
    final rad = AppTheme.getLargeRadius(screenSize);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: (color ?? AppTheme.accentBlue).withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: (color ?? AppTheme.accentBlue).withOpacity(0.28),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color ?? AppTheme.accentBlue,
                size: screenSize.width * 0.05,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getH2(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tira de día con contador — sin sombras
class _DayStrip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String trailing;
  final Size screenSize;

  const _DayStrip({
    required this.color,
    required this.icon,
    required this.label,
    required this.trailing,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final rad = AppTheme.getSmallRadius(screenSize);
    final padH = AppTheme.getMediumPadding(screenSize);
    final padV = AppTheme.getSmallPadding(screenSize);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(rad),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: screenSize.width * 0.045),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Text(
            trailing,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de clase minimalista — igual patrón que en management
class _MinimalClassRow extends StatelessWidget {
  final String start;
  final String? end;
  final String title;
  final String? classroom;
  final String? teacher;
  final Size screenSize;

  const _MinimalClassRow({
    required this.start,
    required this.title,
    required this.screenSize,
    this.end,
    this.classroom,
    this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final rad = AppTheme.getSmallRadius(screenSize);
    final border = AppTheme.getBorderColor(context);

    return Container(
      padding: EdgeInsets.all(padS),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(rad),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera línea: título + horario
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: padS),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: padS * 0.8, vertical: padS * 0.4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppTheme.accentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(rad),
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: AppTheme.accentBlue.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Text(
                  end == null ? start : '$start - $end',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: AppTheme.getCaption(screenSize).fontSize! * 0.9,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: padS * 0.75),

          // Segunda línea: Aula y Profesor (opcionales)
          Row(
            children: [
              if (classroom != null && classroom!.trim().isNotEmpty) ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: padS * 0.5),
                      Expanded(
                        child: Text(
                          'Aula $classroom',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (classroom != null &&
                  classroom!.trim().isNotEmpty &&
                  teacher != null &&
                  teacher!.trim().isNotEmpty)
                SizedBox(width: padS),
              if (teacher != null && teacher!.trim().isNotEmpty) ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: screenSize.width * 0.035,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(width: padS * 0.5),
                      Expanded(
                        child: Text(
                          teacher!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado vacío sobrio, consistente
class _EmptyStrip extends StatelessWidget {
  final Size screenSize;
  const _EmptyStrip({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.getTextSecondaryColor(context).withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.getTextSecondaryColor(context).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        'No hay clases programadas',
        textAlign: TextAlign.center,
        style: AppTheme.getCaption(screenSize).copyWith(
          color: AppTheme.getTextSecondaryColor(context),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Placeholder de carga minimal (sin diálogos modales aquí)
class _LoadingPlaceholder extends StatelessWidget {
  final Size screenSize;
  const _LoadingPlaceholder({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenSize.height * 0.28,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
    );
  }
}

/// Bloque de error sobrio, con reintento
class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Size screenSize;

  const _ErrorBlock({
    required this.message,
    required this.onRetry,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: screenSize.width * 0.12, color: AppTheme.errorColor),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'No se pudo cargar el horario',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onRetry();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize) * 0.8,
              ),
              foregroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
                side: BorderSide(
                    // ignore: deprecated_member_use
                    color: AppTheme.accentBlue.withOpacity(0.5),
                    width: 1),
              ),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
