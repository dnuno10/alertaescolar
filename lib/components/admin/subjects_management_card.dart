import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../models/models.dart';

class SubjectsManagementCard extends StatefulWidget {
  final Size screenSize;
  final List<Materia> subjects;
  final Function(Materia) onSubjectAdded;
  final Function(Materia) onSubjectUpdated;
  final Function(String) onSubjectDeleted;

  const SubjectsManagementCard({
    super.key,
    required this.screenSize,
    required this.subjects,
    required this.onSubjectAdded,
    required this.onSubjectUpdated,
    required this.onSubjectDeleted,
  });

  @override
  State<SubjectsManagementCard> createState() => _SubjectsManagementCardState();
}

class _SubjectsManagementCardState extends State<SubjectsManagementCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: widget.screenSize.height * 0.02,
            offset: Offset(0, widget.screenSize.height * 0.008),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding:
                EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor.withValues(alpha: 0.15),
                  AppTheme.successColor.withValues(alpha: 0.05),
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
                      AppTheme.getSmallPadding(widget.screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
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
                        'Gestión de Materias',
                        style: AppTheme.getH2(widget.screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Crear y administrar materias',
                        style: AppTheme.getCaption(widget.screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getSmallPadding(widget.screenSize),
                    vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.book_rounded,
                        color: Colors.white,
                        size: widget.screenSize.height * 0.018,
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(widget.screenSize) *
                              0.5),
                      Text(
                        '${widget.subjects.length} materias',
                        style: AppTheme.getCaption(widget.screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content with enhanced add button
          Expanded(
            child: Column(
              children: [
                // Modern Add Subject Button
                Container(
                  margin: EdgeInsets.all(
                      AppTheme.getMediumPadding(widget.screenSize)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCreateSubjectModal(context),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(widget.screenSize)),
                      child: Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(widget.screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(widget.screenSize)),
                          border: Border.all(
                            color: AppTheme.successColor.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                  AppTheme.getSmallPadding(widget.screenSize) *
                                      0.5),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: widget.screenSize.height * 0.022,
                              ),
                            ),
                            SizedBox(
                                width: AppTheme.getMediumPadding(
                                    widget.screenSize)),
                            Text(
                              'Agregar Nueva Materia',
                              style: AppTheme.getSubtitle1(widget.screenSize)
                                  .copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Subjects List
                Expanded(
                  child: _SubjectsList(
                    screenSize: widget.screenSize,
                    subjects: widget.subjects,
                    onSubjectUpdated: widget.onSubjectUpdated,
                    onSubjectDeleted: widget.onSubjectDeleted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSubjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateSubjectModal(
        screenSize: widget.screenSize,
        onSubjectCreated: (subject) {
          widget.onSubjectAdded(subject);
        },
      ),
    );
  }
}

class _CreateSubjectModal extends StatefulWidget {
  final Size screenSize;
  final Function(Materia) onSubjectCreated;

  const _CreateSubjectModal({
    required this.screenSize,
    required this.onSubjectCreated,
  });

  @override
  State<_CreateSubjectModal> createState() => _CreateSubjectModalState();
}

class _CreateSubjectModalState extends State<_CreateSubjectModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _classroomController = TextEditingController();
  String _selectedColor = '#9B5DE5';

  final List<Map<String, dynamic>> _predefinedColors = [
    {'color': '#3A86FF', 'name': 'Azul'},
    {'color': '#00C896', 'name': 'Verde'},
    {'color': '#9B5DE5', 'name': 'Púrpura'},
    {'color': '#FF6B35', 'name': 'Naranja'},
    {'color': '#FDCB5A', 'name': 'Amarillo'},
    {'color': '#F72585', 'name': 'Rosa'},
    {'color': '#4CC9F0', 'name': 'Cian'},
    {'color': '#90E0EF', 'name': 'Azul claro'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _classroomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  AppTheme.successColor.withValues(alpha: 0.08),
                  AppTheme.successColor.withValues(alpha: 0.02),
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
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: widget.screenSize.height * 0.022,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(widget.screenSize)),
                Expanded(
                  child: Text(
                    'Nueva Materia',
                    style: AppTheme.getH2(widget.screenSize).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                      fontSize: widget.screenSize.height * 0.022,
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
                    // Subject Name
                    _buildInputSection(
                      'Nombre de la Materia',
                      TextFormField(
                        controller: _nameController,
                        decoration: _getInputDecoration(
                            'Ej: Matemáticas, Historia', Icons.book_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Teacher Name
                    _buildInputSection(
                      'Profesor(a)',
                      TextFormField(
                        controller: _teacherController,
                        decoration: _getInputDecoration(
                            'Ej: Prof. María González', Icons.person_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El profesor es requerido';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Classroom
                    _buildInputSection(
                      'Aula',
                      TextFormField(
                        controller: _classroomController,
                        decoration: _getInputDecoration(
                            'Ej: Aula 101, Laboratorio', Icons.room_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El aula es requerida';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Color Selection
                    Text(
                      'Color de Identificación',
                      style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(widget.screenSize)),
                    Container(
                      padding: EdgeInsets.all(
                          AppTheme.getMediumPadding(widget.screenSize)),
                      decoration: BoxDecoration(
                        color: AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(widget.screenSize)),
                        border:
                            Border.all(color: AppTheme.getBorderColor(context)),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing:
                              AppTheme.getSmallPadding(widget.screenSize),
                          mainAxisSpacing:
                              AppTheme.getSmallPadding(widget.screenSize),
                          childAspectRatio: 1,
                        ),
                        itemCount: _predefinedColors.length,
                        itemBuilder: (context, index) {
                          final colorData = _predefinedColors[index];
                          final color = colorData['color'] as String;
                          final name = colorData['name'] as String;
                          final isSelected = _selectedColor == color;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getColorFromHex(color),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(widget.screenSize)),
                                border: isSelected
                                    ? Border.all(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: widget.screenSize.width * 0.06,
                                    )
                                  : null,
                            ),
                          );
                        },
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
                          child: ElevatedButton.icon(
                            onPressed: _createSubject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
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
                            icon: Icon(Icons.add_rounded),
                            label: Text('Crear Materia'),
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

  Widget _buildInputSection(String label, Widget input) {
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
        input,
        SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hint, IconData icon) {
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
        borderSide: BorderSide(color: AppTheme.successColor, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppTheme.getTextSecondaryColor(context)),
    );
  }

  void _createSubject() {
    if (_formKey.currentState!.validate()) {
      final newSubject = Materia(
        id: 'mat_${DateTime.now().millisecondsSinceEpoch}',
        nombre: _nameController.text.trim(),
        profesor: _teacherController.text.trim(),
        aula: _classroomController.text.trim(),
        color: _selectedColor,
      );

      widget.onSubjectCreated(newSubject);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Materia creada exitosamente'),
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

class _SubjectsList extends StatelessWidget {
  final Size screenSize;
  final List<Materia> subjects;
  final Function(Materia) onSubjectUpdated;
  final Function(String) onSubjectDeleted;

  const _SubjectsList({
    required this.screenSize,
    required this.subjects,
    required this.onSubjectUpdated,
    required this.onSubjectDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: screenSize.height * 0.08,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              'No hay materias registradas',
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final color = _getColorFromHex(subject.color);

        return Container(
          margin: EdgeInsets.only(
            bottom: index == subjects.length - 1
                ? 0
                : AppTheme.getMediumPadding(screenSize),
          ),
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Center(
                  child: Text(
                    subject.nombre.isNotEmpty
                        ? subject.nombre[0].toUpperCase()
                        : 'M',
                    style: AppTheme.getSubtitle1(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.nombre,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      subject.profesor,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    if (subject.aula.isNotEmpty) ...[
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.25),
                      Row(
                        children: [
                          Icon(
                            Icons.room_rounded,
                            size: screenSize.height * 0.016,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                          SizedBox(width: screenSize.width * 0.01),
                          Text(
                            subject.aula,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteSubject(context, subject);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded,
                            size: screenSize.height * 0.02,
                            color: AppTheme.errorColor),
                        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                        Text('Eliminar',
                            style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteSubject(BuildContext context, Materia subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Materia'),
        content:
            Text('¿Estás seguro de que quieres eliminar "${subject.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSubjectDeleted(subject.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Materia eliminada exitosamente'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child:
                Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
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
}
