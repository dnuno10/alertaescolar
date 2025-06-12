import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../models/models.dart';

class ScheduleCreationModal extends StatefulWidget {
  final Size screenSize;
  final List<Materia> subjects;
  final String gradeGroup;
  final List<ClaseHorario> existingSchedules;
  final ClaseHorario? editingClass;
  final DiaSemana? preselectedDay;
  final String? preselectedTimeSlot;
  final Function(ClaseHorario) onClassCreated;

  const ScheduleCreationModal({
    super.key,
    required this.screenSize,
    required this.subjects,
    required this.gradeGroup,
    required this.existingSchedules,
    this.editingClass,
    this.preselectedDay,
    this.preselectedTimeSlot,
    required this.onClassCreated,
  });

  @override
  State<ScheduleCreationModal> createState() => _ScheduleCreationModalState();
}

class _ScheduleCreationModalState extends State<ScheduleCreationModal> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubjectId;
  DiaSemana _selectedDay = DiaSemana.lunes;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);
  final _classroomController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.editingClass != null) {
      _selectedSubjectId = widget.editingClass!.materiaId;
      _selectedDay = widget.editingClass!.dia;
      _startTime = _parseTime(widget.editingClass!.horaInicio);
      _endTime = _parseTime(widget.editingClass!.horaFin);
      _classroomController.text = widget.editingClass!.aula;
    } else if (widget.preselectedDay != null &&
        widget.preselectedTimeSlot != null) {
      _selectedDay = widget.preselectedDay!;
      final times = widget.preselectedTimeSlot!.split('-');
      _startTime = _parseTime(times[0]);
      _endTime = _parseTime(times[1]);
    }
  }

  @override
  void dispose() {
    _classroomController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingClass != null;

    return Container(
      height: widget.screenSize.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        ),
      ),
      child: Column(
        children: [
          // Handle
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

          // Enhanced Header (without extra spacing)
          Container(
            margin: EdgeInsets.only(
                top: AppTheme.getSmallPadding(widget.screenSize)),
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.08),
                  AppTheme.accentPurple.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(AppTheme.getLargeRadius(widget.screenSize)),
                topRight:
                    Radius.circular(AppTheme.getLargeRadius(widget.screenSize)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Icon(
                    isEditing
                        ? Icons.edit_calendar_rounded
                        : Icons.add_box_rounded,
                    color: Colors.white,
                    size: widget.screenSize.height * 0.022,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Editar Clase' : 'Nueva Clase',
                        style: AppTheme.getH2(widget.screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                          fontSize: widget.screenSize.height * 0.022,
                        ),
                      ),
                      Text(
                        widget.gradeGroup,
                        style: AppTheme.getCaption(widget.screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Selection
                    _buildSection(
                      'Materia',
                      DropdownButtonFormField<String>(
                        value: _selectedSubjectId,
                        decoration: _getInputDecoration('Seleccionar materia'),
                        items: widget.subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getColorFromHex(subject.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(
                                    width: AppTheme.getSmallPadding(
                                        widget.screenSize)),
                                Text(subject.nombre),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubjectId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleccione una materia';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Day Selection
                    _buildSection(
                      'Día de la Semana',
                      DropdownButtonFormField<DiaSemana>(
                        value: _selectedDay,
                        isExpanded: true, // Fix overflow
                        decoration: _getInputDecoration('Día de la semana'),
                        items: DiaSemana.values.map((day) {
                          // Include all 7 days
                          return DropdownMenuItem(
                            value: day,
                            child: Text(_getDayName(day)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDay = value;
                            });
                          }
                        },
                      ),
                    ),

                    // Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildSection(
                            'Hora de Inicio',
                            _TimeSelector(
                              screenSize: widget.screenSize,
                              selectedTime: _startTime,
                              onTimeChanged: (time) {
                                setState(() {
                                  _startTime = time;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                            width:
                                AppTheme.getMediumPadding(widget.screenSize)),
                        Expanded(
                          child: _buildSection(
                            'Hora de Fin',
                            _TimeSelector(
                              screenSize: widget.screenSize,
                              selectedTime: _endTime,
                              onTimeChanged: (time) {
                                setState(() {
                                  _endTime = time;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Classroom
                    _buildSection(
                      'Aula (Opcional)',
                      TextFormField(
                        controller: _classroomController,
                        decoration: _getInputDecoration(
                            'Ej: Aula 101, Laboratorio, Gimnasio'),
                      ),
                    ),

                    SizedBox(
                        height: AppTheme.getLargePadding(widget.screenSize)),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.getTextSecondaryColor(context),
                              side: BorderSide(
                                  color: AppTheme.getBorderColor(context)),
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.getMediumPadding(
                                    widget.screenSize),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(widget.screenSize)),
                              ),
                            ),
                            child: Text('Cancelar'),
                          ),
                        ),
                        SizedBox(
                            width:
                                AppTheme.getMediumPadding(widget.screenSize)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveClass,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.getMediumPadding(
                                    widget.screenSize),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(widget.screenSize)),
                              ),
                              elevation: 0,
                            ),
                            child: Text(isEditing ? 'Actualizar' : 'Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        child,
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.getBackgroundColor(context),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(widget.screenSize)),
        borderSide: BorderSide(color: AppTheme.accentPurple, width: 2),
      ),
    );
  }

  String _getDayName(DiaSemana day) {
    switch (day) {
      case DiaSemana.lunes:
        return 'Lunes';
      case DiaSemana.martes:
        return 'Martes';
      case DiaSemana.miercoles:
        return 'Miércoles';
      case DiaSemana.jueves:
        return 'Jueves';
      case DiaSemana.viernes:
        return 'Viernes';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
      default:
        return '';
    }
  }

  void _saveClass() {
    if (_formKey.currentState!.validate()) {
      final newClass = ClaseHorario(
        id: widget.editingClass?.id ??
            'clase_${DateTime.now().millisecondsSinceEpoch}',
        materiaId: _selectedSubjectId!,
        alumnoId: '',
        dia: _selectedDay,
        horaInicio:
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        horaFin:
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        aula: _classroomController.text.trim(),
      );

      widget.onClassCreated(newClass);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editingClass != null
                ? 'Clase actualizada exitosamente'
                : 'Clase creada exitosamente',
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

class _TimeSelector extends StatelessWidget {
  final Size screenSize;
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;

  const _TimeSelector({
    required this.screenSize,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(context),
          border: Border.all(color: AppTheme.getBorderColor(context)),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.022,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Text(
              selectedTime.format(context),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}
