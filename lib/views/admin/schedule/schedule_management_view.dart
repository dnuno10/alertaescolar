import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../models/models.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String _selectedGradeGroup = '1°A';
  DiaSemana? _selectedDay;

  // Mock data
  List<Materia> _subjects = [];
  Map<String, List<ClaseHorario>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _subjects = [
      const Materia(
        id: 'mat_001',
        nombre: 'Matemáticas',
        profesor: 'Prof. María González',
        aula: 'Aula 101',
        color: '#3A86FF',
      ),
      const Materia(
        id: 'mat_002',
        nombre: 'Español',
        profesor: 'Prof. Luis Rodríguez',
        aula: 'Aula 102',
        color: '#00C896',
      ),
      const Materia(
        id: 'mat_003',
        nombre: 'Ciencias Naturales',
        profesor: 'Prof. Ana Martínez',
        aula: 'Laboratorio',
        color: '#9B5DE5',
      ),
      const Materia(
        id: 'mat_004',
        nombre: 'Historia',
        profesor: 'Prof. Carlos López',
        aula: 'Aula 103',
        color: '#FF6B35',
      ),
      const Materia(
        id: 'mat_005',
        nombre: 'Educación Física',
        profesor: 'Prof. Roberto Silva',
        aula: 'Gimnasio',
        color: '#FDCB5A',
      ),
    ];

    _generateMockSchedules();
  }

  void _generateMockSchedules() {
    // Generate schedules for different grades
    final grades = ['1°A', '1°B', '2°A', '2°B', '3°A', '3°B'];

    for (String grade in grades) {
      _schedules[grade] = [
        ClaseHorario(
          id: 'clase_${grade}_001',
          materiaId: 'mat_001',
          alumnoId: '',
          dia: DiaSemana.lunes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Aula 101',
        ),
        ClaseHorario(
          id: 'clase_${grade}_002',
          materiaId: 'mat_002',
          alumnoId: '',
          dia: DiaSemana.lunes,
          horaInicio: '08:20',
          horaFin: '09:10',
          aula: 'Aula 102',
        ),
        ClaseHorario(
          id: 'clase_${grade}_003',
          materiaId: 'mat_003',
          alumnoId: '',
          dia: DiaSemana.martes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Laboratorio',
        ),
        ClaseHorario(
          id: 'clase_${grade}_004',
          materiaId: 'mat_004',
          alumnoId: '',
          dia: DiaSemana.miercoles,
          horaInicio: '09:10',
          horaFin: '10:00',
          aula: 'Aula 103',
        ),
        ClaseHorario(
          id: 'clase_${grade}_005',
          materiaId: 'mat_005',
          alumnoId: '',
          dia: DiaSemana.jueves,
          horaInicio: '10:20',
          horaFin: '11:10',
          aula: 'Gimnasio',
        ),
        ClaseHorario(
          id: 'clase_${grade}_006',
          materiaId: 'mat_001',
          alumnoId: '',
          dia: DiaSemana.viernes,
          horaInicio: '07:30',
          horaFin: '08:20',
          aula: 'Aula 101',
        ),
      ];
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.scheduleManagement),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header and Grade Selector
                      _buildGradeSelector(screenSize, context),

                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                      // Day Filter
                      _buildDayFilter(screenSize, context),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Schedule Display
                      _buildScheduleDisplay(screenSize, context),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Contact Information Card
                      _buildContactInfoCard(screenSize, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradeSelector(Size screenSize, BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Horarios por Grupo',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              formattedDate,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

        // Modern Grade selector
        Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border:
                Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school_rounded,
                size: screenSize.height * 0.02,
                color: AppTheme.accentPurple,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Grupo: ',
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.2),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showModernGradeSelector(context, screenSize),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(screenSize),
                      vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple,
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedGradeGroup,
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: screenSize.height * 0.018,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayFilter(Size screenSize, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por día',
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDayChip('Todos', null, screenSize, context),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              ...DiaSemana.values.take(5).map((day) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: AppTheme.getSmallPadding(screenSize) * 0.5),
                  child:
                      _buildDayChip(_getDayName(day), day, screenSize, context),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayChip(
      String label, DiaSemana? day, Size screenSize, BuildContext context) {
    final isSelected = _selectedDay == day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.accentBlue : AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.getBorderColor(context),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.getTextPrimaryColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showModernGradeSelector(BuildContext context, Size screenSize) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screenSize.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin:
                  EdgeInsets.only(top: AppTheme.getSmallPadding(screenSize)),
              width: screenSize.width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.getTextSecondaryColor(context)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: AppTheme.accentPurple,
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                  Expanded(
                    child: Text(
                      'Seleccionar Grupo',
                      style: AppTheme.getH2(screenSize).copyWith(
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
                    ),
                  ),
                ],
              ),
            ),

            // Grade Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
                    mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final grades = [
                      '1°A',
                      '1°B',
                      '1°C',
                      '2°A',
                      '2°B',
                      '2°C',
                      '3°A',
                      '3°B',
                      '3°C',
                      '4°A',
                      '4°B',
                      '4°C',
                    ];
                    final grade = grades[index];
                    final isSelected = grade == _selectedGradeGroup;

                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGradeGroup = grade;
                          });
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentPurple
                                : AppTheme.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize)),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentPurple
                                  : AppTheme.getBorderColor(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: AppTheme.getSubtitle1(screenSize).copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleDisplay(Size screenSize, BuildContext context) {
    final currentSchedules = _schedules[_selectedGradeGroup] ?? [];
    final filteredSchedules = _selectedDay == null
        ? currentSchedules
        : currentSchedules
            .where((schedule) => schedule.dia == _selectedDay)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Horario de $_selectedGradeGroup',
                style: AppTheme.getSubtitle1(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_selectedDay != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Text(
                  _getDayName(_selectedDay!),
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        if (filteredSchedules.isEmpty)
          _buildEmptySchedule(screenSize, context)
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSchedules.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            itemBuilder: (context, index) {
              return _ClassCard(
                clase: filteredSchedules[index],
                index: index,
                screenSize: screenSize,
                subject: _getSubjectById(filteredSchedules[index].materiaId),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptySchedule(Size screenSize, BuildContext context) {
    final message = _selectedDay == null
        ? 'No hay horarios disponibles'
        : 'No hay clases para ${_getDayName(_selectedDay!)}';
    final subtitle = _selectedDay == null
        ? 'Para este grupo aún no se han configurado horarios'
        : 'Este grupo no tiene clases programadas para este día';

    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            message,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            subtitle,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(Size screenSize, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
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
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppTheme.accentBlue,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  '¿Necesitas cambios en el horario?',
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Si necesitas realizar cambios en los horarios de algún grupo, contacta al equipo de Alerta Escolar. Estaremos encantados de ayudarte.',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  subtitle: 'soporte@alertaescolar.com',
                  color: AppTheme.accentBlue,
                  screenSize: screenSize,
                  onTap: () => _showContactInfo(
                      context, 'Email', 'soporte@alertaescolar.com'),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone_rounded,
                  label: 'Teléfono',
                  subtitle: '+52 55 1234 5678',
                  color: AppTheme.successColor,
                  screenSize: screenSize,
                  onTap: () =>
                      _showContactInfo(context, 'Teléfono', '+52 55 1234 5678'),
                ),
              ),
            ],
          ),
        ],
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
    }
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Size screenSize,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: screenSize.height * 0.025,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                label,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.25),
              Text(
                subtitle,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactInfo(BuildContext context, String method, String contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
        title: Text(
          'Contactar por $method',
          style: AppTheme.getSubtitle1(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          contact,
          style: AppTheme.getBodyMedium(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Materia? _getSubjectById(String materiaId) {
    try {
      return _subjects.firstWhere((subject) => subject.id == materiaId);
    } catch (e) {
      return null;
    }
  }
}

class _ClassCard extends StatelessWidget {
  final ClaseHorario clase;
  final int index;
  final Size screenSize;
  final Materia? subject;

  const _ClassCard({
    required this.clase,
    required this.index,
    required this.screenSize,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    if (subject == null) return const SizedBox();

    final Color cardColor = _getColorFromHex(subject!.color);

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
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
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
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      children: [
                        // Header con icono y nombre
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
                                _getSubjectIcon(subject!.nombre),
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
                                    subject!.nombre,
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
                                  SizedBox(height: screenSize.height * 0.003),
                                  Text(
                                    subject!.profesor,
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
                              ),
                            ),
                            // Day indicator
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppTheme.getSmallPadding(screenSize) * 0.75,
                                vertical:
                                    AppTheme.getSmallPadding(screenSize) * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                              ),
                              child: Text(
                                clase.diaNombre.substring(0, 3),
                                style: AppTheme.getCaptionSmall(screenSize)
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cardColor,
                                ),
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
                              flex: clase.aula.isNotEmpty ? 1 : 2,
                              child: _buildInfoChip(
                                icon: Icons.access_time_rounded,
                                text: clase.horarioTexto,
                                color: cardColor,
                                screenSize: screenSize,
                              ),
                            ),
                            if (clase.aula.isNotEmpty) ...[
                              SizedBox(
                                  width: AppTheme.getSmallPadding(screenSize) *
                                      0.5),
                              Expanded(
                                flex: 1,
                                child: _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  text: clase.aula,
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
            ));
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
          Flexible(
            child: Text(
              text,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
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
