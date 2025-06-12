import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/comunicado.dart';
import 'selectable_students_directory_view.dart';

class NotificationSendView extends StatefulWidget {
  final String? preselectedType;

  const NotificationSendView({
    super.key,
    this.preselectedType,
  });

  @override
  State<NotificationSendView> createState() => _NotificationSendViewState();
}

class _NotificationSendViewState extends State<NotificationSendView>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedRecipient = 'individual';
  String _selectedType = 'permiso';
  bool _sendPushNotification = true;

  // Comunicado specific fields
  TipoComunicado _selectedComunicadoType = TipoComunicado.informativo;
  PrioridadComunicado _selectedPriority = PrioridadComunicado.media;
  DateTime? _scheduledDate;

  // Selection variables
  Map<String, dynamic>? _selectedStudent;
  String? _selectedClass;
  String? _selectedShift;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Handle preselected type
    if (widget.preselectedType != null && widget.preselectedType!.isNotEmpty) {
      _selectedType = widget.preselectedType!;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                NavHeader(
                  title: 'Enviar Notificación',
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message Type Section
                        _buildSection(
                          title: 'Tipo de Mensaje',
                          child: Column(
                            children: [
                              _buildTypeOption(
                                'Permiso Especial',
                                'permiso',
                                Icons.assignment_turned_in_rounded,
                                AppTheme.accentBlue,
                                'Solicitar permisos especiales para estudiantes',
                                screenSize,
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              _buildTypeOption(
                                'Comunicado',
                                'comunicado',
                                Icons.campaign_rounded,
                                AppTheme.warningColor,
                                'Enviar comunicados oficiales a los destinatarios',
                                screenSize,
                              ),
                            ],
                          ),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Comunicado Type Section (only show when comunicado is selected)
                        if (_selectedType == 'comunicado') ...[
                          _buildSection(
                            title: 'Tipo de Comunicado',
                            child: _buildComunicadoTypeSelector(screenSize),
                            screenSize: screenSize,
                          ),
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),

                          // Priority Section
                          _buildSection(
                            title: 'Prioridad',
                            child: _buildPrioritySelector(screenSize),
                            screenSize: screenSize,
                          ),
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),
                        ],

                        // Recipients Section
                        _buildSection(
                          title: 'Destinatarios',
                          child: Column(
                            children: [
                              _buildRecipientOption(
                                'Estudiante Individual',
                                'individual',
                                Icons.person_rounded,
                                'Seleccionar un estudiante específico',
                                screenSize,
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              _buildRecipientOption(
                                'Grupo/Clase',
                                'grupo',
                                Icons.group_rounded,
                                'Enviar a una clase completa',
                                screenSize,
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              _buildRecipientOption(
                                'Turno Completo',
                                'turno',
                                Icons.schedule_rounded,
                                'Todos los estudiantes del turno',
                                screenSize,
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              _buildRecipientOption(
                                'Todos los Estudiantes',
                                'todos',
                                Icons.school_rounded,
                                'Toda la institución educativa',
                                screenSize,
                              ),

                              // Dynamic selection based on recipient type
                              if (_selectedRecipient == 'individual') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                _buildStudentSelector(screenSize),
                              ],
                              if (_selectedRecipient == 'grupo') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                _buildClassSelector(screenSize),
                              ],
                              if (_selectedRecipient == 'turno') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                _buildShiftSelector(screenSize),
                              ],
                            ],
                          ),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Message Content Section
                        _buildSection(
                          title: 'Contenido del Mensaje',
                          child: _buildMessageContent(screenSize),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Delivery Options Section
                        _buildSection(
                          title: 'Opciones de Entrega',
                          child: Column(
                            children: [
                              _buildSwitchOption(
                                'Notificación Push',
                                'Enviar notificación inmediata al dispositivo',
                                Icons.notifications_active_rounded,
                                _sendPushNotification,
                                (value) => setState(
                                    () => _sendPushNotification = value),
                                AppTheme.accentOrange,
                                screenSize,
                              ),
                            ],
                          ),
                          screenSize: screenSize,
                        ),

                        SizedBox(
                            height: AppTheme.getLargePadding(screenSize) * 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
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
                  Expanded(
                    child: CustomOutlineButton(
                      color: AppTheme.getTextPrimaryColor(context)
                          .withOpacity(0.5),
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      screenSize: screenSize,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    flex: 2,
                    child: SolidButton(
                      label: _selectedType == 'comunicado'
                          ? 'Enviar Comunicado'
                          : 'Enviar Ahora',
                      onPressed: _sendNotification,
                      screenSize: screenSize,
                      icon: Icons.send_rounded,
                      backgroundColor: _canSendMessage()
                          ? AppTheme.accentPurple
                          : AppTheme.accentPurple.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required Size screenSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(color: AppTheme.getBorderColor(context)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTypeOption(String title, String value, IconData icon,
      Color color, String description, Size screenSize) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppTheme.getBackgroundColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: isSelected ? color : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getMediumPadding(screenSize) * 0.8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.getBorderColor(context).withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : AppTheme.getTextSecondaryColor(context),
                size: screenSize.height * 0.03,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyLarge(screenSize).copyWith(
                      color: isSelected
                          ? color
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    description,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: screenSize.height * 0.018,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientOption(String title, String value, IconData icon,
      String description, Size screenSize) {
    final isSelected = _selectedRecipient == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRecipient = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentOrange.withValues(alpha: 0.1)
              : AppTheme.getBackgroundColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentOrange
                : AppTheme.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentOrange.withValues(alpha: 0.2)
                    : AppTheme.getBorderColor(context).withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.accentOrange
                    : AppTheme.getTextSecondaryColor(context),
                size: screenSize.height * 0.022,
              ),
            ),
            SizedBox(width: AppTheme.getMediumPadding(screenSize)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: isSelected
                          ? AppTheme.accentOrange
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                  Text(
                    description,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentOrange,
                size: screenSize.height * 0.025,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption(
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    Color color,
    Size screenSize,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.05)
            : AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.3)
              : AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
            decoration: BoxDecoration(
              color: value
                  ? color.withValues(alpha: 0.1)
                  : AppTheme.getBorderColor(context).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              icon,
              color: value ? color : AppTheme.getTextSecondaryColor(context),
              size: screenSize.height * 0.022,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  description,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector(Size screenSize) {
    return Column(
      children: [
        // Header with instructions
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentOrange.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentOrange,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  'Selecciona un estudiante del directorio',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Student selector button
        GestureDetector(
          onTap: () => _navigateToStudentDirectory(),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: _selectedStudent != null
                  ? AppTheme.accentOrange.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: _selectedStudent != null
                    ? AppTheme.accentOrange
                    : AppTheme.getBorderColor(context),
                width: _selectedStudent != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: (_selectedStudent != null
                            ? AppTheme.accentOrange
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    _selectedStudent != null
                        ? Icons.person_rounded
                        : Icons.search_rounded,
                    color: _selectedStudent != null
                        ? AppTheme.accentOrange
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedStudent != null
                            ? _selectedStudent!['name']
                            : 'Buscar en Directorio',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: _selectedStudent != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: _selectedStudent != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        _selectedStudent != null
                            ? 'Grado: ${_selectedStudent!['grade']} - ${_selectedStudent!['section']}'
                            : 'Navegar al directorio de estudiantes',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: _selectedStudent != null
                        ? AppTheme.accentOrange.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    _selectedStudent != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: _selectedStudent != null
                        ? AppTheme.accentOrange
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector(Size screenSize) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  'Elige la clase para enviar la notificación',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Class selector button
        GestureDetector(
          onTap: () => _showClassSelectionDialog(),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: _selectedClass != null
                  ? AppTheme.accentBlue.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: _selectedClass != null
                    ? AppTheme.accentBlue
                    : AppTheme.getBorderColor(context),
                width: _selectedClass != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: (_selectedClass != null
                            ? AppTheme.accentBlue
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.class_rounded,
                    color: _selectedClass != null
                        ? AppTheme.accentBlue
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedClass ?? 'Seleccionar Clase',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: _selectedClass != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: _selectedClass != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        _selectedClass != null
                            ? 'Clase seleccionada'
                            : 'Toca para elegir una clase',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: _selectedClass != null
                        ? AppTheme.accentBlue.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    _selectedClass != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: _selectedClass != null
                        ? AppTheme.accentBlue
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSelector(Size screenSize) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.05),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentPurple,
                size: screenSize.height * 0.02,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  'Selecciona el turno al que enviar',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Shift selector button
        GestureDetector(
          onTap: () => _showShiftSelectionDialog(),
          child: Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: _selectedShift != null
                  ? AppTheme.accentPurple.withValues(alpha: 0.1)
                  : AppTheme.getCardColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: _selectedShift != null
                    ? AppTheme.accentPurple
                    : AppTheme.getBorderColor(context),
                width: _selectedShift != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: (_selectedShift != null
                            ? AppTheme.accentPurple
                            : AppTheme.getBorderColor(context))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: _selectedShift != null
                        ? AppTheme.accentPurple
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedShift ?? 'Seleccionar Turno',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: _selectedShift != null
                              ? AppTheme.getTextPrimaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          fontWeight: _selectedShift != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        _selectedShift != null
                            ? 'Turno seleccionado'
                            : 'Toca para elegir un turno',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.6),
                  decoration: BoxDecoration(
                    color: _selectedShift != null
                        ? AppTheme.accentPurple.withValues(alpha: 0.15)
                        : AppTheme.getBorderColor(context)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    _selectedShift != null
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: _selectedShift != null
                        ? AppTheme.accentPurple
                        : AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToStudentDirectory() async {
    // Navigate to the selectable student directory view
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectableStudentsDirectoryView(
          selectionMode: true,
          allowMultiSelect: false,
        ),
      ),
    );

    // Handle the selected student result
    if (result != null) {
      setState(() {
        _selectedStudent = result;
      });
    }
  }

  void _showClassSelectionDialog() {
    final classes = [
      {'id': '1A', 'name': '1ro A', 'students': 25, 'teacher': 'Prof. García'},
      {'id': '1B', 'name': '1ro B', 'students': 23, 'teacher': 'Prof. López'},
      {
        'id': '2A',
        'name': '2do A',
        'students': 27,
        'teacher': 'Prof. Martínez'
      },
      {
        'id': '2B',
        'name': '2do B',
        'students': 24,
        'teacher': 'Prof. Rodríguez'
      },
      {
        'id': '3A',
        'name': '3ro A',
        'students': 26,
        'teacher': 'Prof. Fernández'
      },
      {'id': '3B', 'name': '3ro B', 'students': 22, 'teacher': 'Prof. Morales'},
    ];

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    AppTheme.getLargeRadius(MediaQuery.of(context).size)),
              ),
              elevation: 8,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: EdgeInsets.all(
                    AppTheme.getMediumPadding(MediaQuery.of(context).size)),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(MediaQuery.of(context).size)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.getSmallPadding(
                                  MediaQuery.of(context).size) *
                              0.8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(
                                    MediaQuery.of(context).size)),
                          ),
                          child: Icon(
                            Icons.class_rounded,
                            color: AppTheme.accentBlue,
                            size: MediaQuery.of(context).size.height * 0.025,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getMediumPadding(
                                MediaQuery.of(context).size)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seleccionar Clase',
                                style:
                                    AppTheme.getH2(MediaQuery.of(context).size)
                                        .copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Elige la clase que recibirá la notificación',
                                style: AppTheme.getCaptionSmall(
                                        MediaQuery.of(context).size)
                                    .copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getMediumPadding(
                            MediaQuery.of(context).size)),
                    // Classes grid
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 2 : 1,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: AppTheme.getSmallPadding(
                              MediaQuery.of(context).size),
                          mainAxisSpacing: AppTheme.getSmallPadding(
                              MediaQuery.of(context).size),
                        ),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classData = classes[index];
                          return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedClass =
                                      classData['name'] as String);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getMediumRadius(
                                        MediaQuery.of(context).size)),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      AppTheme.getMediumPadding(
                                          MediaQuery.of(context).size)),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(
                                            MediaQuery.of(context).size)),
                                    border: Border.all(
                                      color: AppTheme.getBorderColor(context),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentBlue
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.getSmallRadius(
                                                  MediaQuery.of(context).size)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            classData['id'] as String,
                                            style: AppTheme.getBodyMedium(
                                                    MediaQuery.of(context).size)
                                                .copyWith(
                                              color: AppTheme.accentBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: AppTheme.getMediumPadding(
                                              MediaQuery.of(context).size)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              classData['name'] as String,
                                              style: AppTheme.getBodyMedium(
                                                      MediaQuery.of(context)
                                                          .size)
                                                  .copyWith(
                                                color: AppTheme
                                                    .getTextPrimaryColor(
                                                        context),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size) *
                                                        0.3),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people_outline_rounded,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.016,
                                                  color: AppTheme
                                                      .getTextSecondaryColor(
                                                          context),
                                                ),
                                                SizedBox(
                                                    width: AppTheme
                                                            .getSmallPadding(
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size) *
                                                        0.5),
                                                Text(
                                                  '${classData['students']} estudiantes',
                                                  style:
                                                      AppTheme.getCaptionSmall(
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size)
                                                          .copyWith(
                                                    color: AppTheme
                                                        .getTextSecondaryColor(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.018,
                                        color: AppTheme.getTextSecondaryColor(
                                            context),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void _showShiftSelectionDialog() {
    final shifts = [
      {
        'id': 'morning',
        'name': 'Matutino',
        'time': '7:00 AM - 12:00 PM',
        'students': 156,
        'classes': 6,
        'icon': Icons.wb_sunny_rounded,
        'color': AppTheme.accentOrange,
      },
      {
        'id': 'afternoon',
        'name': 'Vespertino',
        'time': '1:00 PM - 6:00 PM',
        'students': 134,
        'classes': 5,
        'icon': Icons.brightness_6_rounded,
        'color': AppTheme.accentPurple,
      },
    ];

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    AppTheme.getLargeRadius(MediaQuery.of(context).size)),
              ),
              elevation: 8,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                padding: EdgeInsets.all(
                    AppTheme.getMediumPadding(MediaQuery.of(context).size)),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(MediaQuery.of(context).size)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.getSmallPadding(
                                  MediaQuery.of(context).size) *
                              0.8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(
                                    MediaQuery.of(context).size)),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            color: AppTheme.accentPurple,
                            size: MediaQuery.of(context).size.height * 0.025,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getMediumPadding(
                                MediaQuery.of(context).size)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seleccionar Turno',
                                style:
                                    AppTheme.getH2(MediaQuery.of(context).size)
                                        .copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Elige el turno que recibirá la notificación',
                                style: AppTheme.getCaptionSmall(
                                        MediaQuery.of(context).size)
                                    .copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColor(context),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getMediumPadding(
                            MediaQuery.of(context).size)),
                    // Shifts list - Fixed layout to prevent overflow
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: shifts.map((shift) {
                        final color = shift['color'] as Color;
                        final isLast =
                            shifts.indexOf(shift) == shifts.length - 1;

                        return Container(
                            margin: EdgeInsets.only(
                              bottom: isLast
                                  ? 0
                                  : AppTheme.getSmallPadding(
                                      MediaQuery.of(context).size),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() =>
                                      _selectedShift = shift['name'] as String);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getMediumRadius(
                                        MediaQuery.of(context).size)),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(
                                      AppTheme.getMediumPadding(
                                          MediaQuery.of(context).size)),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(
                                            MediaQuery.of(context).size)),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon container with fixed size
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        constraints: BoxConstraints(
                                          maxWidth: 60,
                                          maxHeight: 60,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.getMediumRadius(
                                                  MediaQuery.of(context).size)),
                                        ),
                                        child: Icon(
                                          shift['icon'] as IconData,
                                          color: color,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.028,
                                        ),
                                      ),
                                      SizedBox(
                                          width: AppTheme.getMediumPadding(
                                              MediaQuery.of(context).size)),
                                      // Content with flexible layout
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              shift['name'] as String,
                                              style: AppTheme.getBodyLarge(
                                                      MediaQuery.of(context)
                                                          .size)
                                                  .copyWith(
                                                color: AppTheme
                                                    .getTextPrimaryColor(
                                                        context),
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size) *
                                                        0.3),
                                            Text(
                                              shift['time'] as String,
                                              style: AppTheme.getBodyMedium(
                                                      MediaQuery.of(context)
                                                          .size)
                                                  .copyWith(
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                                height:
                                                    AppTheme.getSmallPadding(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size) *
                                                        0.3),
                                            // Stats row with flexible layout
                                            Wrap(
                                              spacing:
                                                  AppTheme.getMediumPadding(
                                                      MediaQuery.of(context)
                                                          .size),
                                              runSpacing:
                                                  AppTheme.getSmallPadding(
                                                          MediaQuery.of(context)
                                                              .size) *
                                                      0.5,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .people_outline_rounded,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.016,
                                                      color: AppTheme
                                                          .getTextSecondaryColor(
                                                              context),
                                                    ),
                                                    SizedBox(
                                                        width: AppTheme
                                                                .getSmallPadding(
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size) *
                                                            0.5),
                                                    Text(
                                                      '${shift['students']} estudiantes',
                                                      style: AppTheme
                                                              .getCaptionSmall(
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size)
                                                          .copyWith(
                                                        color: AppTheme
                                                            .getTextSecondaryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.class_rounded,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.016,
                                                      color: AppTheme
                                                          .getTextSecondaryColor(
                                                              context),
                                                    ),
                                                    SizedBox(
                                                        width: AppTheme
                                                                .getSmallPadding(
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size) *
                                                            0.5),
                                                    Text(
                                                      '${shift['classes']} clases',
                                                      style: AppTheme
                                                              .getCaptionSmall(
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size)
                                                          .copyWith(
                                                        color: AppTheme
                                                            .getTextSecondaryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Arrow icon
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.020,
                                        color: color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget _buildComunicadoTypeSelector(Size screenSize) {
    final comunicadoTypes = [
      {
        'value': TipoComunicado.informativo,
        'label': 'Informativo',
        'icon': Icons.info_rounded
      },
      {
        'value': TipoComunicado.emergencia,
        'label': 'Emergencia',
        'icon': Icons.emergency_rounded
      },
      {
        'value': TipoComunicado.evento,
        'label': 'Evento',
        'icon': Icons.event_rounded
      },
      {
        'value': TipoComunicado.recordatorioPago,
        'label': 'Recordatorio de Pago',
        'icon': Icons.payment_rounded
      },
      {
        'value': TipoComunicado.citatorio,
        'label': 'Citatorio',
        'icon': Icons.gavel_rounded
      },
      {
        'value': TipoComunicado.celebracion,
        'label': 'Celebración',
        'icon': Icons.celebration_rounded
      },
      {
        'value': TipoComunicado.suspencionClases,
        'label': 'Suspensión de Clases',
        'icon': Icons.cancel_rounded
      },
      {
        'value': TipoComunicado.cambioHorario,
        'label': 'Cambio de Horario',
        'icon': Icons.schedule_rounded
      },
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      runSpacing: AppTheme.getSmallPadding(screenSize),
      children: comunicadoTypes.map((type) {
        final isSelected = _selectedComunicadoType == type['value'];
        return GestureDetector(
          onTap: () => setState(
              () => _selectedComunicadoType = type['value'] as TipoComunicado),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getMediumPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.warningColor.withValues(alpha: 0.1)
                  : AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: isSelected
                    ? AppTheme.warningColor
                    : AppTheme.getBorderColor(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected
                      ? AppTheme.warningColor
                      : AppTheme.getTextSecondaryColor(context),
                  size: screenSize.height * 0.022,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                Text(
                  type['label'] as String,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: isSelected
                        ? AppTheme.warningColor
                        : AppTheme.getTextPrimaryColor(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(Size screenSize) {
    final priorities = [
      {
        'value': PrioridadComunicado.baja,
        'label': 'Baja',
        'color': AppTheme.accentBlue
      },
      {
        'value': PrioridadComunicado.media,
        'label': 'Media',
        'color': AppTheme.accentOrange
      },
      {
        'value': PrioridadComunicado.alta,
        'label': 'Alta',
        'color': AppTheme.warningColor
      },
      {
        'value': PrioridadComunicado.critica,
        'label': 'Crítica',
        'color': AppTheme.errorColor
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
        mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
      ),
      itemCount: priorities.length,
      itemBuilder: (context, index) {
        final priority = priorities[index];
        final isSelected = _selectedPriority == priority['value'];

        return GestureDetector(
          onTap: () => setState(() =>
              _selectedPriority = priority['value'] as PrioridadComunicado),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: isSelected
                  ? (priority['color'] as Color).withValues(alpha: 0.1)
                  : AppTheme.getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: isSelected
                    ? priority['color'] as Color
                    : AppTheme.getBorderColor(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: screenSize.width * 0.08,
                  height: screenSize.width * 0.08,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                    maxWidth: 40,
                    maxHeight: 40,
                  ),
                  decoration: BoxDecoration(
                    color: (priority['color'] as Color)
                        .withValues(alpha: isSelected ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: priority['color'] as Color,
                    size: screenSize.height * 0.02,
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.8),
                Expanded(
                  child: Text(
                    priority['label'] as String,
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: isSelected
                          ? priority['color'] as Color
                          : AppTheme.getTextPrimaryColor(context),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: priority['color'] as Color,
                    size: screenSize.height * 0.018,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(Size screenSize) {
    return Column(
      children: [
        // Title field (always present)
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _titleController,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
            decoration: InputDecoration(
              labelText: 'Título del mensaje',
              labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              hintText: _selectedType == 'comunicado'
                  ? 'Ej: Suspensión de clases por evento especial'
                  : 'Ej: Reunión de padres programada',
              hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context)
                    .withValues(alpha: 0.7),
              ),
              prefixIcon: Container(
                margin:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.6),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.title_rounded,
                  color: AppTheme.accentOrange,
                  size: screenSize.height * 0.022,
                ),
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                borderSide: BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getMediumPadding(screenSize),
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
        // Message field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 6,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              height: 1.5,
            ),
            decoration: InputDecoration(
              labelText: 'Mensaje',
              labelStyle: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              hintText: _selectedType == 'comunicado'
                  ? 'Escribe el contenido oficial del comunicado...\n\nIncluye detalles como fechas, motivos, acciones a tomar, y cualquier información relevante para la comunidad educativa.'
                  : 'Escribe el contenido completo de tu mensaje aquí...\n\nPuedes incluir detalles importantes como fechas, horarios, y cualquier información relevante para los destinatarios.',
              hintStyle: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context)
                    .withValues(alpha: 0.7),
                height: 1.4,
              ),
              alignLabelWithHint: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                borderSide: BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            ),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        // Tips
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.accentOrange.withValues(alpha: 0.7),
              size: screenSize.height * 0.018,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
            Expanded(
              child: Text(
                _selectedType == 'comunicado'
                    ? 'Tip: Los comunicados oficiales deben ser claros, precisos y contener toda la información necesaria.'
                    : 'Tip: Sé claro y conciso. Los mensajes efectivos comunican la información esencial.',
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectScheduleDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentPurple,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppTheme.accentPurple,
                  ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  bool _canSendMessage() {
    bool hasValidRecipient = true;

    if (_selectedRecipient == 'individual') {
      hasValidRecipient = _selectedStudent != null;
    } else if (_selectedRecipient == 'grupo') {
      hasValidRecipient = _selectedClass != null;
    } else if (_selectedRecipient == 'turno') {
      hasValidRecipient = _selectedShift != null;
    }

    return _titleController.text.isNotEmpty &&
        _messageController.text.isNotEmpty &&
        _sendPushNotification &&
        hasValidRecipient;
  }

  void _sendNotification() {
    final messageType =
        _selectedType == 'comunicado' ? 'Comunicado' : 'Permiso especial';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(
                width: AppTheme.getSmallPadding(MediaQuery.of(context).size)),
            Expanded(
              child: Text(
                '$messageType ${_scheduledDate != null ? 'programado' : 'enviado'} exitosamente',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
    Navigator.pop(context);
  }
}
