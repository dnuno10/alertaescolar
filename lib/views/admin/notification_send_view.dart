import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class NotificationSendView extends StatefulWidget {
  const NotificationSendView({super.key});

  @override
  State<NotificationSendView> createState() => _NotificationSendViewState();
}

class _NotificationSendViewState extends State<NotificationSendView>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedRecipient = 'individual';
  String _selectedType = 'permiso';
  bool _sendPushNotification = true; // Already set to true by default

  // Selection variables
  Map<String, dynamic>? _selectedStudent;
  String? _selectedClass;
  String? _selectedShift;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
                                'Alerta',
                                'alerta',
                                Icons.warning_rounded,
                                AppTheme.warningColor,
                                'Enviar alertas importantes a los destinatarios',
                                screenSize,
                              ),
                            ],
                          ),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

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
                          child: Column(
                            children: [
                              // Title field
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Título del mensaje',
                                  hintText: 'Ej: Reunión de padres programada',
                                  prefixIcon: Icon(
                                    Icons.title_rounded,
                                    color: AppTheme.accentOrange,
                                  ),
                                  filled: true,
                                  fillColor:
                                      AppTheme.getBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getBorderColor(context)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getBorderColor(context)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color: AppTheme.accentOrange),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              // Message field
                              TextField(
                                controller: _messageController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  labelText: 'Mensaje',
                                  hintText:
                                      'Escribe el contenido completo de tu mensaje aquí...',
                                  alignLabelWithHint: true,
                                  filled: true,
                                  fillColor:
                                      AppTheme.getBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getBorderColor(context)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color:
                                            AppTheme.getBorderColor(context)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.getMediumRadius(screenSize)),
                                    borderSide: BorderSide(
                                        color: AppTheme.accentOrange),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Delivery Options Section
                        _buildSection(
                          title: 'Opciones de Entrega',
                          child: _buildSwitchOption(
                            'Notificación Push',
                            'Enviar notificación inmediata al dispositivo',
                            Icons.notifications_active_rounded,
                            _sendPushNotification,
                            (value) =>
                                setState(() => _sendPushNotification = value),
                            AppTheme.accentOrange,
                            screenSize,
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
                      label: 'Enviar Ahora',
                      onPressed:
                          _canSendMessage() ? () => _sendNotification() : () {},
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
                  _selectedStudent != null
                      ? 'Estudiante seleccionado del directorio'
                      : 'Selecciona un estudiante del directorio',
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

        // Show selected student info if available
        if (_selectedStudent != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(
                color: AppTheme.successColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.successColor,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedStudent!['name'] ?? 'Estudiante',
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        'Grado: ${_selectedStudent!['grade']} - Sección: ${_selectedStudent!['section']}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      if (_selectedStudent!['id'] != null)
                        Text(
                          'ID: ${_selectedStudent!['id']}',
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
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    size: screenSize.height * 0.022,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Change selection button
          GestureDetector(
            onTap: () => _navigateToStudentDirectory(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(screenSize),
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                    size: screenSize.height * 0.02,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Text(
                    'Cambiar estudiante',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Student selector button when no student is selected
          GestureDetector(
            onTap: () => _navigateToStudentDirectory(),
            child: Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
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
                    padding:
                        EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                    decoration: BoxDecoration(
                      color: AppTheme.getBorderColor(context)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buscar en Directorio',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                            height: AppTheme.getSmallPadding(screenSize) * 0.3),
                        Text(
                          'Navegar al directorio de estudiantes',
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
                      color: AppTheme.getBorderColor(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: screenSize.height * 0.022,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        // Class selector
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
        // Shift selector
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
    // Navigate to the actual student directory view
    final result = await Navigator.pushNamed(
      context,
      '/admin/students', // Replace with your actual student directory route
      arguments: {
        'selectionMode': true, // Enable selection mode
        'allowMultiSelect': false, // Only single selection for notifications
        'showFilters': true, // Show grade/section filters
      },
    );

    // Handle the selected student result
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedStudent = result;
      });
    }
  }

  void _showStudentSearchDialog() {
    // Mock data - replace with actual student data
    final students = [
      {
        'id': 'STU001',
        'name': 'Juan Pérez',
        'grade': '5to',
        'section': 'A',
        'avatar': null,
      },
      {
        'id': 'STU002',
        'name': 'María González',
        'grade': '4to',
        'section': 'B',
        'avatar': null,
      },
      {
        'id': 'STU003',
        'name': 'Carlos Rodríguez',
        'grade': '6to',
        'section': 'A',
        'avatar': null,
      },
      {
        'id': 'STU004',
        'name': 'Ana Martínez',
        'grade': '3ro',
        'section': 'C',
        'avatar': null,
      },
      {
        'id': 'STU005',
        'name': 'Luis Fernández',
        'grade': '5to',
        'section': 'B',
        'avatar': null,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getMediumRadius(MediaQuery.of(context).size)),
        ),
        child: Container(
          padding: EdgeInsets.all(
              AppTheme.getMediumPadding(MediaQuery.of(context).size)),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentOrange,
                    size: MediaQuery.of(context).size.height * 0.025,
                  ),
                  SizedBox(
                      width: AppTheme.getSmallPadding(
                          MediaQuery.of(context).size)),
                  Text(
                    'Seleccionar Estudiante',
                    style: AppTheme.getSubtitle1(MediaQuery.of(context).size)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(
                  height:
                      AppTheme.getMediumPadding(MediaQuery.of(context).size)),

              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(MediaQuery.of(context).size)),
                  ),
                ),
              ),
              SizedBox(
                  height:
                      AppTheme.getMediumPadding(MediaQuery.of(context).size)),

              // Students list
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: AppTheme.getSmallPadding(
                              MediaQuery.of(context).size)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.accentOrange.withValues(alpha: 0.1),
                          child: Text(
                            student['name']![0],
                            style: TextStyle(
                              color: AppTheme.accentOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          student['name']!,
                          style: AppTheme.getBodyMedium(
                                  MediaQuery.of(context).size)
                              .copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                            '${student['grade']} - ${student['section']} • ID: ${student['id']}'),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: MediaQuery.of(context).size.height * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(
                                  MediaQuery.of(context).size)),
                        ),
                        onTap: () {
                          setState(() => _selectedStudent = student);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassSelectionDialog() {
    final classes = ['1ro A', '1ro B', '2do A', '2do B', '3ro A', '3ro B'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar Clase'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.1),
                  child: Icon(Icons.class_rounded, color: AppTheme.accentBlue),
                ),
                title: Text(classes[index]),
                onTap: () {
                  setState(() => _selectedClass = classes[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showShiftSelectionDialog() {
    final shifts = ['Mañana', 'Tarde', 'Noche'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar Turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: shifts
              .map((shift) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.accentPurple.withValues(alpha: 0.1),
                      child: Icon(Icons.access_time_rounded,
                          color: AppTheme.accentPurple),
                    ),
                    title: Text(shift),
                    onTap: () {
                      setState(() => _selectedShift = shift);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
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
                'Notificación enviada exitosamente',
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
