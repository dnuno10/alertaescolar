import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../models/models.dart';

class ScheduleGridView extends StatefulWidget {
  final Size screenSize;
  final List<Materia> subjects;
  final List<ClaseHorario> schedules;
  final String gradeGroup;
  final Function(List<ClaseHorario>) onScheduleUpdated;
  final Function(ClaseHorario) onEditClass;
  final Function(ClaseHorario) onDeleteClass;
  final Function(DiaSemana, String) onCreateClassAtSlot;
  final VoidCallback onCreateNewClass;

  const ScheduleGridView({
    super.key,
    required this.screenSize,
    required this.subjects,
    required this.schedules,
    required this.gradeGroup,
    required this.onScheduleUpdated,
    required this.onEditClass,
    required this.onDeleteClass,
    required this.onCreateClassAtSlot,
    required this.onCreateNewClass,
  });

  @override
  State<ScheduleGridView> createState() => _ScheduleGridViewState();
}

class _ScheduleGridViewState extends State<ScheduleGridView> {
  late ScrollController _sharedHorizontalController;
  final List<ScrollController> _rowControllers = [];

  // Predefined schedule configuration - no modifications allowed
  final List<String> _predefinedTimeSlots = [
    '07:30-08:20',
    '08:20-09:10',
    '09:10-10:00',
    '10:00-10:20', // Recreo
    '10:20-11:10',
    '11:10-12:00',
    '12:00-12:50',
    '12:50-13:40',
    '13:40-14:30',
    '14:30-15:20',
  ];

  @override
  void initState() {
    super.initState();
    _sharedHorizontalController = ScrollController();

    // Initialize row controllers for predefined time slots
    _updateRowControllers(_predefinedTimeSlots.length);

    // Sync all row controllers with the shared controller
    _sharedHorizontalController.addListener(() {
      for (final controller in _rowControllers) {
        if (controller.hasClients &&
            controller.offset != _sharedHorizontalController.offset) {
          controller.jumpTo(_sharedHorizontalController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _sharedHorizontalController.dispose();
    for (final controller in _rowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateRowControllers(int requiredCount) {
    // Dispose excess controllers
    while (_rowControllers.length > requiredCount) {
      _rowControllers.removeLast().dispose();
    }

    // Add missing controllers
    while (_rowControllers.length < requiredCount) {
      final controller = ScrollController();
      // Sync new controller with shared controller
      controller.addListener(() {
        if (_sharedHorizontalController.hasClients &&
            controller.hasClients &&
            controller.offset != _sharedHorizontalController.offset) {
          _sharedHorizontalController.jumpTo(controller.offset);
        }
      });
      _rowControllers.add(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _predefinedTimeSlots;
    final days = DiaSemana.values.take(7).toList();

    return Column(
      children: [
        // Schedule Table
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                AppTheme.getLargeRadius(widget.screenSize)),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                border: Border.all(
                  color:
                      AppTheme.getBorderColor(context).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Days Header
                  Container(
                    height: widget.screenSize.height * 0.08,
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            AppTheme.getLargeRadius(widget.screenSize)),
                        topRight: Radius.circular(
                            AppTheme.getLargeRadius(widget.screenSize)),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.getBorderColor(context)
                              .withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Time column header
                        Container(
                          width: widget.screenSize.width * 0.15,
                          child: Center(
                            child: Icon(
                              Icons.schedule_rounded,
                              size: widget.screenSize.height * 0.024,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                        // Days headers
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _sharedHorizontalController,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: Row(
                              children: days
                                  .map((day) => Container(
                                        width: widget.screenSize.width * 0.18,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: AppTheme.getBorderColor(
                                                      context)
                                                  .withValues(alpha: 0.1),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getDayAbbreviation(day),
                                            style: AppTheme.getSubtitle1(
                                                    widget.screenSize)
                                                .copyWith(
                                              color:
                                                  AppTheme.getTextPrimaryColor(
                                                      context),
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  widget.screenSize.height *
                                                      0.015,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Schedule Content
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: timeSlots.asMap().entries.map((entry) {
                          final index = entry.key;
                          final timeSlot = entry.value;

                          return Container(
                            height: widget.screenSize.height * 0.15,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.getBorderColor(context)
                                      .withValues(alpha: 0.05),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Time column
                                Container(
                                  width: widget.screenSize.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: AppTheme.getBackgroundColor(context)
                                        .withValues(alpha: 0.3),
                                    border: Border(
                                      right: BorderSide(
                                        color: AppTheme.getBorderColor(context)
                                            .withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: _TimeDisplay(
                                      timeSlot: timeSlot,
                                      screenSize: widget.screenSize,
                                    ),
                                  ),
                                ),
                                // Days columns
                                Expanded(
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification notification) {
                                      if (notification
                                              is ScrollUpdateNotification &&
                                          notification.metrics.axis ==
                                              Axis.horizontal) {
                                        if (_sharedHorizontalController
                                                .hasClients &&
                                            _sharedHorizontalController
                                                    .offset !=
                                                notification.metrics.pixels) {
                                          _sharedHorizontalController.jumpTo(
                                              notification.metrics.pixels);
                                        }
                                      }
                                      return false;
                                    },
                                    child: SingleChildScrollView(
                                      controller: _rowControllers[index],
                                      scrollDirection: Axis.horizontal,
                                      physics: const ClampingScrollPhysics(),
                                      child: Row(
                                        children: days.map((day) {
                                          final classForSlot =
                                              _getClassForTimeSlot(
                                                  day, timeSlot);
                                          final isLastDay = day == days.last;

                                          return Container(
                                            width:
                                                widget.screenSize.width * 0.18,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: isLastDay
                                                      ? Colors.transparent
                                                      : AppTheme.getBorderColor(
                                                              context)
                                                          .withValues(
                                                              alpha: 0.05),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  AppTheme.getSmallPadding(
                                                      widget.screenSize)),
                                              child: classForSlot != null
                                                  ? _ClassCard(
                                                      claseHorario:
                                                          classForSlot,
                                                      subject: _getSubjectById(
                                                          classForSlot
                                                              .materiaId),
                                                      screenSize:
                                                          widget.screenSize,
                                                      onEdit: () =>
                                                          widget.onEditClass(
                                                              classForSlot),
                                                      onDelete: () =>
                                                          widget.onDeleteClass(
                                                              classForSlot),
                                                    )
                                                  : _EmptySlot(
                                                      screenSize:
                                                          widget.screenSize,
                                                      timeSlot: timeSlot,
                                                      day: day,
                                                      onTap: () => widget
                                                          .onCreateClassAtSlot(
                                                              day, timeSlot),
                                                    ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDayAbbreviation(DiaSemana day) {
    switch (day) {
      case DiaSemana.lunes:
        return 'LUN';
      case DiaSemana.martes:
        return 'MAR';
      case DiaSemana.miercoles:
        return 'MIE';
      case DiaSemana.jueves:
        return 'JUE';
      case DiaSemana.viernes:
        return 'VIE';
      case DiaSemana.sabado:
        return 'SAB';
      case DiaSemana.domingo:
        return 'DOM';
      default:
        return '';
    }
  }

  ClaseHorario? _getClassForTimeSlot(DiaSemana day, String timeSlot) {
    try {
      return widget.schedules.firstWhere(
        (clase) => clase.dia == day && clase.horarioTexto == timeSlot,
      );
    } catch (e) {
      return null;
    }
  }

  Materia? _getSubjectById(String materiaId) {
    try {
      return widget.subjects.firstWhere((subject) => subject.id == materiaId);
    } catch (e) {
      return null;
    }
  }
}

class _ClassCard extends StatelessWidget {
  final ClaseHorario claseHorario;
  final Materia? subject;
  final Size screenSize;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.claseHorario,
    required this.subject,
    required this.screenSize,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (subject == null) return const SizedBox();

    final color = _getColorFromHex(subject!.color);

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showClassOptions(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Subject name with color indicator
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: screenSize.height * 0.02,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Text(
                        subject!.nombre,
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                          fontSize: screenSize.height * 0.014,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (subject!.profesor.isNotEmpty) ...[
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    subject!.profesor,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontSize: screenSize.height * 0.011,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (claseHorario.aula.isNotEmpty) ...[
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: screenSize.height * 0.012,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.5),
                      Expanded(
                        child: Text(
                          claseHorario.aula,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontSize: screenSize.height * 0.010,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  void _showClassOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: AppTheme.getSmallPadding(screenSize)),
                width: screenSize.width * 0.15,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextSecondaryColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                child: Column(
                  children: [
                    Text(
                      subject!.nombre,
                      style: AppTheme.getH2(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      '${claseHorario.diaNombre} • ${claseHorario.horarioTexto}',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onEdit();
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accentBlue,
                              side: BorderSide(color: AppTheme.accentBlue),
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            icon: Icon(Icons.delete_rounded),
                            label: Text('Eliminar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                              side: BorderSide(color: AppTheme.errorColor),
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
        ),
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
}

class _EmptySlot extends StatelessWidget {
  final Size screenSize;
  final String timeSlot;
  final DiaSemana day;
  final VoidCallback onTap;

  const _EmptySlot({
    required this.screenSize,
    required this.timeSlot,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlot == '10:00-10:20') {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withValues(alpha: 0.08),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: AppTheme.accentBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.coffee_rounded,
                size: screenSize.height * 0.024,
                color: AppTheme.accentBlue,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Recreo',
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: screenSize.height * 0.012,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: screenSize.height * 0.035,
              color: AppTheme.getTextSecondaryColor(context)
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String timeSlot;
  final Size screenSize;

  const _TimeDisplay({
    required this.timeSlot,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final times = timeSlot.split('-');
    final startTime = times[0];
    final endTime = times[1];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          startTime,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w700,
            fontSize: screenSize.height * 0.014,
          ),
        ),
        Container(
          width: screenSize.width * 0.08,
          height: 1,
          margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.008),
          color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.3),
        ),
        Text(
          endTime,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w700,
            fontSize: screenSize.height * 0.014,
          ),
        ),
      ],
    );
  }
}
