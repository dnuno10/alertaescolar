import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class ScheduleEditor extends StatefulWidget {
  final Size screenSize;
  final String selectedGrade;
  final String selectedGroup;

  const ScheduleEditor({
    super.key,
    required this.screenSize,
    required this.selectedGrade,
    required this.selectedGroup,
  });

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  bool _isEditing = false;
  Map<String, List<Map<String, String>>> _schedule = {};

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  @override
  void didUpdateWidget(ScheduleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGrade != widget.selectedGrade ||
        oldWidget.selectedGroup != widget.selectedGroup) {
      _loadScheduleData();
    }
  }

  void _loadScheduleData() {
    // Mock schedule data
    _schedule = {
      'Lunes': [
        {'time': '07:30-08:20', 'subject': 'Matemáticas', 'teacher': 'Prof. García'},
        {'time': '08:20-09:10', 'subject': 'Español', 'teacher': 'Prof. López'},
        {'time': '09:10-10:00', 'subject': 'Ciencias', 'teacher': 'Prof. Martínez'},
        {'time': '10:00-10:20', 'subject': 'Recreo', 'teacher': ''},
        {'time': '10:20-11:10', 'subject': 'Historia', 'teacher': 'Prof. Rodríguez'},
        {'time': '11:10-12:00', 'subject': 'Educación Física', 'teacher': 'Prof. Hernández'},
      ],
      'Martes': [
        {'time': '07:30-08:20', 'subject': 'Español', 'teacher': 'Prof. López'},
        {'time': '08:20-09:10', 'subject': 'Matemáticas', 'teacher': 'Prof. García'},
        {'time': '09:10-10:00', 'subject': 'Arte', 'teacher': 'Prof. Jiménez'},
        {'time': '10:00-10:20', 'subject': 'Recreo', 'teacher': ''},
        {'time': '10:20-11:10', 'subject': 'Inglés', 'teacher': 'Prof. Smith'},
        {'time': '11:10-12:00', 'subject': 'Música', 'teacher': 'Prof. González'},
      ],
      'Miércoles': [
        {'time': '07:30-08:20', 'subject': 'Ciencias', 'teacher': 'Prof. Martínez'},
        {'time': '08:20-09:10', 'subject': 'Matemáticas', 'teacher': 'Prof. García'},
        {'time': '09:10-10:00', 'subject': 'Español', 'teacher': 'Prof. López'},
        {'time': '10:00-10:20', 'subject': 'Recreo', 'teacher': ''},
        {'time': '10:20-11:10', 'subject': 'Geografía', 'teacher': 'Prof. Morales'},
        {'time': '11:10-12:00', 'subject': 'Computación', 'teacher': 'Prof. Torres'},
      ],
      'Jueves': [
        {'time': '07:30-08:20', 'subject': 'Historia', 'teacher': 'Prof. Rodríguez'},
        {'time': '08:20-09:10', 'subject': 'Inglés', 'teacher': 'Prof. Smith'},
        {'time': '09:10-10:00', 'subject': 'Matemáticas', 'teacher': 'Prof. García'},
        {'time': '10:00-10:20', 'subject': 'Recreo', 'teacher': ''},
        {'time': '10:20-11:10', 'subject': 'Español', 'teacher': 'Prof. López'},
        {'time': '11:10-12:00', 'subject': 'Educación Física', 'teacher': 'Prof. Hernández'},
      ],
      'Viernes': [
        {'time': '07:30-08:20', 'subject': 'Arte', 'teacher': 'Prof. Jiménez'},
        {'time': '08:20-09:10', 'subject': 'Ciencias', 'teacher': 'Prof. Martínez'},
        {'time': '09:10-10:00', 'subject': 'Música', 'teacher': 'Prof. González'},
        {'time': '10:00-10:20', 'subject': 'Recreo', 'teacher': ''},
        {'time': '10:20-11:10', 'subject': 'Matemáticas', 'teacher': 'Prof. García'},
        {'time': '11:10-12:00', 'subject': 'Español', 'teacher': 'Prof. López'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.successColor,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: Text(
                  '${l10n.classSchedule ?? 'Horario de clases'} - ${widget.selectedGrade}${widget.selectedGroup}',
                  style: AppTheme.getH2(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                  color: AppTheme.successColor,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Schedule Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(
                minWidth: widget.screenSize.width,
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  AppTheme.getBackgroundColor(context),
                ),
                headingTextStyle: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
                dataTextStyle: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: widget.screenSize.width * 0.15,
                      child: Text(l10n.time ?? 'Hora'),
                    ),
                  ),
                  ..._schedule.keys.map((day) => DataColumn(
                    label: SizedBox(
                      width: widget.screenSize.width * 0.15,
                      child: Text(day),
                    ),
                  )),
                ],
                rows: _generateScheduleRows(),
              ),
            ),
          ),

          if (_isEditing) ...[
            SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),
            Row(
              children: [
                Expanded(
                  child: SolidButton(
                    backgroundColor: AppTheme.errorColor,
                    onPressed: _resetSchedule,
                    label: l10n.reset ?? 'Restablecer',
                    icon: Icons.refresh_rounded,
                    screenSize: widget.screenSize,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: SolidButton(
                    backgroundColor: AppTheme.successColor,
                    onPressed: _saveSchedule,
                    label: l10n.saveChanges,
                    icon: Icons.save_rounded,
                    screenSize: widget.screenSize,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<DataRow> _generateScheduleRows() {
    if (_schedule.isEmpty) return [];

    final firstDay = _schedule.keys.first;
    final timeSlots = _schedule[firstDay]!;

    return timeSlots.asMap().entries.map((entry) {
      final index = entry.key;
      final timeSlot = entry.value;

      return DataRow(
        color: MaterialStateProperty.all(
          timeSlot['subject'] == 'Recreo' 
              ? AppTheme.accentBlue.withOpacity(0.1)
              : null,
        ),
        cells: [
          DataCell(
            Container(
              width: widget.screenSize.width * 0.15,
              child: Text(
                timeSlot['time']!,
                style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ..._schedule.keys.map((day) {
            final daySchedule = _schedule[day]!;
            if (index < daySchedule.length) {
              final subject = daySchedule[index];
              return DataCell(
                GestureDetector(
                  onTap: _isEditing && subject['subject'] != 'Recreo'
                      ? () => _editSubject(day, index)
                      : null,
                  child: Container(
                    width: widget.screenSize.width * 0.15,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                    ),
                    decoration: _isEditing && subject['subject'] != 'Recreo'
                        ? BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(widget.screenSize) * 0.5),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subject['subject']!,
                          style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            color: subject['subject'] == 'Recreo'
                                ? AppTheme.accentBlue
                                : AppTheme.getTextPrimaryColor(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subject['teacher']!.isNotEmpty)
                          Text(
                            subject['teacher']!,
                            style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                              fontSize: widget.screenSize.height * 0.011,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (_isEditing && subject['subject'] != 'Recreo')
                          Icon(
                            Icons.edit_rounded,
                            size: widget.screenSize.height * 0.015,
                            color: AppTheme.successColor,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const DataCell(Text(''));
            }
          }),
        ],
      );
    }).toList();
  }

  void _editSubject(String day, int index) {
    final l10n = AppLocalizations.of(context);
    final currentSubject = _schedule[day]![index];
    final subjectController = TextEditingController(text: currentSubject['subject']);
    final teacherController = TextEditingController(text: currentSubject['teacher']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        ),
        title: Text(
          l10n.editSubject ?? 'Editar materia',
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: l10n.subject ?? 'Materia',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
            TextField(
              controller: teacherController,
              decoration: InputDecoration(
                labelText: l10n.teacher ?? 'Profesor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _schedule[day]![index]['subject'] = subjectController.text;
                _schedule[day]![index]['teacher'] = teacherController.text;
              });
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _resetSchedule() {
    setState(() {
      _loadScheduleData();
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).scheduleReset ?? 'Horario restablecido',
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(widget.screenSize)),
        ),
      ),
    );
  }

  void _saveSchedule() {
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).scheduleSaved ?? 'Horario guardado exitosamente',
          style: AppTheme.getCaption(widget.screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(widget.screenSize)),
        ),
      ),
    );
  }
}
