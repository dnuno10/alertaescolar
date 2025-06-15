import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/schedule/schedule_student_card.dart';
import 'package:alertaescolar/components/schedule/day_selector.dart';
import 'package:alertaescolar/components/schedule/schedule_loading_state.dart';
import 'package:alertaescolar/components/schedule/schedule_empty_state.dart';
import 'package:alertaescolar/components/schedule/class_card.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';

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
      // final schedule =
      //     await _scheduleService.getStudentSchedule(widget.student.id);
      // final organizedSchedule =
      //     _scheduleService.organizeScheduleByDay(schedule);

      setState(() {
        // _schedule = organizedSchedule;
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
              NavHeader(title: l10n.weeklySchedule),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ScheduleStudentCard(
                      student: widget.student,
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    DaySelector(
                      selectedDayIndex: _selectedDayIndex,
                      onDaySelected: (index) {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? SliverToBoxAdapter(
                      child: ScheduleLoadingState(screenSize: screenSize),
                    )
                  : _buildScheduleContent(context, l10n, screenSize),
            ],
          ),
        );
      },
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
              child: ScheduleEmptyState(
                day: selectedDay,
                screenSize: screenSize,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final clase = daySchedule[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.getSmallPadding(screenSize)),
                    child: ClassCard(
                      clase: clase,
                      index: index,
                      screenSize: screenSize,
                    ),
                  );
                },
                childCount: daySchedule.length,
              ),
            ),
    );
  }
}
