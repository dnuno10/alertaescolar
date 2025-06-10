import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../services/mock_schedule_service.dart';
import '../../app/app_theme.dart';

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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final MockScheduleService _scheduleService = MockScheduleService();
  Map<DiaSemana, List<ClaseHorario>> _schedule = {};
  bool _isLoading = true;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadSchedule();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    try {
      final schedule =
          await _scheduleService.getStudentSchedule(widget.student.id);
      final organizedSchedule =
          _scheduleService.organizeScheduleByDay(schedule);

      setState(() {
        _schedule = organizedSchedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.errorLoadingSchedule}: $e',
              style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                color: AppTheme.onPrimaryColor,
              ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(MediaQuery.of(context).size)),
            ),
          ),
        );
      }
    }
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
            slivers: [
              _buildStickyHeader(context, l10n, screenSize),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildStudentCard(context, screenSize),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    _buildDaySelector(context, l10n, screenSize),
                  ],
                ),
              ),
              _isLoading
                  ? SliverToBoxAdapter(
                      child: _buildLoadingState(l10n, screenSize),
                    )
                  : _buildScheduleContent(context, l10n, screenSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize)),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.1,
                        height: screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.accentPurple,
                            size: screenSize.width * 0.05,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.weeklySchedule,
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Size screenSize) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[widget.student.hashCode % colors.length];

    return Container(
      width: screenSize.width * 0.9,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.15,
            height: screenSize.width * 0.15,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.student.nombre.isNotEmpty
                    ? widget.student.nombre[0].toUpperCase()
                    : 'A',
                style: AppTheme.getH2(screenSize).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.nombre,
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.002),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        widget.student.grado,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                        vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                      ),
                      decoration: BoxDecoration(
                        color: widget.student.activo
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize) * 0.5),
                      ),
                      child: Text(
                        widget.student.activo
                            ? 'Activo'
                            : 'Inactivo', // TODO: Add to l10n
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.student.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          height: 1.2,
                        ),
                      ),
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

  Widget _buildDaySelector(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    final dayNames = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Container(
      padding: EdgeInsets.only(
          left: AppTheme.getMediumPadding(screenSize),
          right: AppTheme.getMediumPadding(screenSize),
          bottom: AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Días de la semana', // TODO: Add to l10n
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SizedBox(
            height: screenSize.height * 0.06,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dayNames.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return Padding(
                  padding: EdgeInsets.only(
                      right: AppTheme.getSmallPadding(screenSize)),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBorderColor(context),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentPurple
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          dayNames[index],
                          style: AppTheme.getCaption(screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.onPrimaryColor
                                : AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, Size screenSize) {
    return Container(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.loadingSchedule,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    final selectedDay = DiaSemana.values[_selectedDayIndex];
    final daySchedule = _schedule[selectedDay] ?? [];

    return SliverPadding(
      padding: EdgeInsets.only(
          left: AppTheme.getMediumPadding(screenSize),
          right: AppTheme.getMediumPadding(screenSize),
          bottom: AppTheme.getMediumPadding(screenSize)),
      sliver: daySchedule.isEmpty
          ? SliverToBoxAdapter(
              child:
                  _buildEmptySchedule(context, selectedDay, l10n, screenSize),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final clase = daySchedule[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.getSmallPadding(screenSize)),
                    child: _buildClassCard(context, clase, screenSize, index),
                  );
                },
                childCount: daySchedule.length,
              ),
            ),
    );
  }

  Widget _buildEmptySchedule(BuildContext context, DiaSemana day,
      AppLocalizations l10n, Size screenSize) {
    return Container(
      height: screenSize.height * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width * 0.2,
              height: screenSize.width * 0.2,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: screenSize.width * 0.1,
                color: AppTheme.accentPurple,
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              l10n.noScheduledClasses,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.noClassesScheduledForDay(day.name),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(
      BuildContext context, ClaseHorario clase, Size screenSize, int index) {
    final materia = clase.materia;
    if (materia == null) return const SizedBox.shrink();

    final Color cardColor = _getColorFromHex(materia.color);
    final bool isReceso = materia.nombre.toLowerCase().contains('recreo');

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      children: [
                        // Header con icono, nombre y profesor
                        Row(
                          children: [
                            Container(
                              width: screenSize.width * 0.12,
                              height: screenSize.width * 0.12,
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                              ),
                              child: Icon(
                                isReceso
                                    ? Icons.free_breakfast_outlined
                                    : _getSubjectIcon(materia.nombre),
                                color: cardColor,
                                size: screenSize.width * 0.06,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getSmallPadding(screenSize)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    materia.nombre,
                                    style: AppTheme.getSubtitle1(screenSize)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (materia.profesor.isNotEmpty) ...[
                                    SizedBox(height: screenSize.height * 0.003),
                                    Text(
                                      materia.profesor,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Separador
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                        // Información de tiempo y lugar
                        Row(
                          children: [
                            Expanded(
                              flex: materia.aula.isNotEmpty ? 1 : 2,
                              child: _buildInfoChip(
                                icon: Icons.access_time_rounded,
                                text: clase.horarioTexto,
                                color: cardColor,
                                screenSize: screenSize,
                              ),
                            ),
                            if (materia.aula.isNotEmpty) ...[
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Expanded(
                                flex: 1,
                                child: _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  text: materia.aula,
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
                                  screenSize: screenSize,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required Size screenSize,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
        vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenSize.width * 0.035,
            color: color,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            text,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.accentPurple;
    }
  }

  IconData _getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('matemá')) return Icons.calculate_outlined;
    if (subjectLower.contains('español') || subjectLower.contains('lengua'))
      return Icons.menu_book_outlined;
    if (subjectLower.contains('ciencia')) return Icons.science_outlined;
    if (subjectLower.contains('historia')) return Icons.history_edu_outlined;
    if (subjectLower.contains('física') || subjectLower.contains('deporte'))
      return Icons.sports_soccer_outlined;
    if (subjectLower.contains('inglés') || subjectLower.contains('idioma'))
      return Icons.language_outlined;
    if (subjectLower.contains('arte') || subjectLower.contains('dibujo'))
      return Icons.palette_outlined;
    if (subjectLower.contains('música')) return Icons.music_note_outlined;
    if (subjectLower.contains('geografía')) return Icons.public_outlined;
    if (subjectLower.contains('química')) return Icons.biotech_outlined;
    if (subjectLower.contains('biología')) return Icons.eco_outlined;
    if (subjectLower.contains('tecnología') ||
        subjectLower.contains('informática')) return Icons.computer_outlined;
    return Icons.school_outlined;
  }
}
