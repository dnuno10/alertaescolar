import 'package:alertaescolar/components/admin/notifications/section_container.dart';
import 'package:alertaescolar/components/admin/notifications/message_type_option.dart';
import 'package:alertaescolar/components/admin/notifications/recipient_option.dart';
import 'package:alertaescolar/components/admin/notifications/switch_option_card.dart';
import 'package:alertaescolar/components/admin/notifications/student_selector.dart';
import 'package:alertaescolar/components/admin/notifications/comunicado_type_selector.dart';
import 'package:alertaescolar/components/admin/notifications/priority_selector.dart';
import 'package:alertaescolar/components/admin/notifications/message_content_form.dart';
import 'package:alertaescolar/components/buttons/custom_outline_button.dart';
import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/student_provider.dart';
import '../../../managers/group_provider.dart';
import '../../../managers/turno_provider.dart';
import '../../../managers/user_provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/comunicado.dart';
import '../students/selectable_students_directory_view.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../models/grupo.dart';
import '../../../models/turno.dart';

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
  List<Grupo> _selectedGroups = []; // Changed to list for multiple selection
  List<String> _selectedNivelesEducativos = []; // For educational levels
  Turno? _selectedShift;

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

    // Load data when widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final escuelaId = userProvider.currentUser?.escuelaId;
    if (escuelaId == null) return;

    try {
      // Load groups, turnos, and students for the school
      await Future.wait([
        groupProvider.loadGroups(escuelaId: escuelaId),
        turnoProvider.loadTurnos(escuelaId: escuelaId),
        studentProvider.loadStudents(escuelaId: escuelaId),
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
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

    return Consumer4<ThemeProvider, GroupProvider, TurnoProvider,
        StudentProvider>(
      builder: (context, themeProvider, groupProvider, turnoProvider,
          studentProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                NavHeader(
                  title: l10n.sendNotification,
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
                        SectionContainer(
                          title: l10n.messageType,
                          screenSize: screenSize,
                          child: Column(
                            children: [
                              MessageTypeOption(
                                title: l10n.specialPermission,
                                value: 'permiso',
                                icon: Icons.assignment_turned_in_rounded,
                                color: AppTheme.accentBlue,
                                description: l10n.requestSpecialPermissionDesc,
                                screenSize: screenSize,
                                selectedType: _selectedType,
                                onSelect: (type) =>
                                    setState(() => _selectedType = type),
                              ),
                              SizedBox(
                                  height:
                                      AppTheme.getMediumPadding(screenSize)),
                              MessageTypeOption(
                                title: l10n.communication,
                                value: 'comunicado',
                                icon: Icons.campaign_rounded,
                                color: AppTheme.warningColor,
                                description: l10n.sendOfficialCommunicationDesc,
                                screenSize: screenSize,
                                selectedType: _selectedType,
                                onSelect: (type) =>
                                    setState(() => _selectedType = type),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Comunicado Type Section (only show when comunicado is selected)
                        if (_selectedType == 'comunicado') ...[
                          SectionContainer(
                            title: l10n.communicationType,
                            screenSize: screenSize,
                            child: ComunicadoTypeSelector(
                              selectedType: _selectedComunicadoType,
                              onTypeSelected: (type) => setState(
                                  () => _selectedComunicadoType = type),
                              screenSize: screenSize,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),

                          // Priority Section
                          SectionContainer(
                            title: l10n.priority,
                            screenSize: screenSize,
                            child: PrioritySelector(
                              selectedPriority: _selectedPriority,
                              onPriorityChanged: (priority) =>
                                  setState(() => _selectedPriority = priority),
                              screenSize: screenSize,
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),
                        ],

                        // Recipients Section
                        SectionContainer(
                          title: l10n.recipients,
                          screenSize: screenSize,
                          child: Column(
                            children: [
                              RecipientOption(
                                title: l10n.individualStudent,
                                value: 'individual',
                                icon: Icons.person_rounded,
                                description: l10n.selectSpecificStudent,
                                screenSize: screenSize,
                                selectedRecipient: _selectedRecipient,
                                onSelect: (recipient) => setState(
                                    () => _selectedRecipient = recipient),
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              RecipientOption(
                                title: l10n.groupClass,
                                value: 'grupo',
                                icon: Icons.group_rounded,
                                description: l10n.sendToEntireClass,
                                screenSize: screenSize,
                                selectedRecipient: _selectedRecipient,
                                onSelect: (recipient) => setState(
                                    () => _selectedRecipient = recipient),
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              RecipientOption(
                                title: l10n.entireShift,
                                value: 'turno',
                                icon: Icons.schedule_rounded,
                                description: l10n.allStudentsInShift,
                                screenSize: screenSize,
                                selectedRecipient: _selectedRecipient,
                                onSelect: (recipient) => setState(
                                    () => _selectedRecipient = recipient),
                              ),
                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                              RecipientOption(
                                title: l10n.allStudents,
                                value: 'todos',
                                icon: Icons.school_rounded,
                                description: l10n.entireEducationalInstitution,
                                screenSize: screenSize,
                                selectedRecipient: _selectedRecipient,
                                onSelect: (recipient) => setState(
                                    () => _selectedRecipient = recipient),
                              ),

                              // Dynamic selection based on recipient type
                              if (_selectedRecipient == 'individual') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                StudentSelector(
                                  selectedStudent: _selectedStudent,
                                  screenSize: screenSize,
                                  onSelectStudent: _navigateToStudentDirectory,
                                ),
                              ],
                              if (_selectedRecipient == 'grupo') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                _buildGroupSelector(context, screenSize),
                              ],
                              if (_selectedRecipient == 'turno') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                _buildShiftSelector(context, screenSize),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Message Content Section
                        SectionContainer(
                          title: l10n.messageContent,
                          screenSize: screenSize,
                          child: MessageContentForm(
                            titleController: _titleController,
                            messageController: _messageController,
                            selectedType: _selectedType,
                            screenSize: screenSize,
                          ),
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Delivery Options Section
                        SectionContainer(
                          title: l10n.deliveryOptions,
                          screenSize: screenSize,
                          child: Column(
                            children: [
                              SwitchOptionCard(
                                title: l10n.pushNotification,
                                description:
                                    l10n.sendImmediateNotificationToDevice,
                                icon: Icons.notifications_active_rounded,
                                value: _sendPushNotification,
                                onChanged: (value) => setState(
                                    () => _sendPushNotification = value),
                                color: AppTheme.accentOrange,
                                screenSize: screenSize,
                              ),
                            ],
                          ),
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
                      label: l10n.cancel,
                      onPressed: () => Navigator.pop(context),
                      screenSize: screenSize,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    flex: 2,
                    child: SolidButton(
                      label: _selectedType == 'comunicado'
                          ? l10n.sendCommunication
                          : l10n.sendNow,
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

  Widget _buildGroupSelector(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final groupedByLevel = <String, List<Grupo>>{};
        for (final grupo in groupProvider.grupos) {
          groupedByLevel.putIfAbsent(grupo.nivelEducativo, () => []).add(grupo);
        }

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
                    color: AppTheme.accentBlue.withValues(alpha: 0.2)),
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
                      l10n.chooseClassForNotification,
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

            // Group selector button
            GestureDetector(
              onTap: () => _showGroupSelectionDialog(context, groupedByLevel),
              child: Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: _selectedGroups.isNotEmpty
                      ? AppTheme.accentBlue.withValues(alpha: 0.1)
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  border: Border.all(
                    color: _selectedGroups.isNotEmpty
                        ? AppTheme.accentBlue
                        : AppTheme.getBorderColor(context),
                    width: _selectedGroups.isNotEmpty ? 2 : 1,
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
                        color: (_selectedGroups.isNotEmpty
                                ? AppTheme.accentBlue
                                : AppTheme.getBorderColor(context))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        Icons.class_rounded,
                        color: _selectedGroups.isNotEmpty
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
                            _selectedGroups.isNotEmpty
                                ? '${_selectedGroups.length} grupos seleccionados'
                                : l10n.selectClass,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: _selectedGroups.isNotEmpty
                                  ? AppTheme.getTextPrimaryColor(context)
                                  : AppTheme.getTextSecondaryColor(context),
                              fontWeight: _selectedGroups.isNotEmpty
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                              height:
                                  AppTheme.getSmallPadding(screenSize) * 0.3),
                          Text(
                            _selectedGroups.isNotEmpty
                                ? _selectedGroups.map((g) => g.grupo).join(', ')
                                : l10n.tapToChooseClass,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                          AppTheme.getSmallPadding(screenSize) * 0.6),
                      decoration: BoxDecoration(
                        color: _selectedGroups.isNotEmpty
                            ? AppTheme.accentBlue.withValues(alpha: 0.15)
                            : AppTheme.getBorderColor(context)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        _selectedGroups.isNotEmpty
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded,
                        color: _selectedGroups.isNotEmpty
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
      },
    );
  }

  Widget _buildShiftSelector(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Consumer<TurnoProvider>(
      builder: (context, turnoProvider, child) {
        return Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.05),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                    color: AppTheme.accentOrange.withValues(alpha: 0.2)),
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
                      l10n.allStudentsInShift,
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

            // Shift selector button
            GestureDetector(
              onTap: () =>
                  _showShiftSelectionDialog(context, turnoProvider.turnos),
              child: Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: _selectedShift != null
                      ? AppTheme.accentOrange.withValues(alpha: 0.1)
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(screenSize)),
                  border: Border.all(
                    color: _selectedShift != null
                        ? AppTheme.accentOrange
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
                      padding:
                          EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                      decoration: BoxDecoration(
                        color: (_selectedShift != null
                                ? AppTheme.accentOrange
                                : AppTheme.getBorderColor(context))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize)),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: _selectedShift != null
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
                            _selectedShift?.turno ?? 'Seleccionar turno',
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
                              height:
                                  AppTheme.getSmallPadding(screenSize) * 0.3),
                          Text(
                            _selectedShift != null
                                ? '${_selectedShift!.horaInicio} - ${_selectedShift!.horaFin}'
                                : 'Toca para elegir turno',
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
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
                            ? AppTheme.accentOrange.withValues(alpha: 0.15)
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
      },
    );
  }

  void _showGroupSelectionDialog(
      BuildContext context, Map<String, List<Grupo>> groupedByLevel) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Move these outside the builder to maintain state
    List<Grupo> tempSelectedGroups = List<Grupo>.from(_selectedGroups);
    List<String> tempSelectedLevels =
        List<String>.from(_selectedNivelesEducativos);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
            ),
            elevation: 8,
            child: Container(
              width: screenSize.width * 0.9,
              constraints: BoxConstraints(maxHeight: screenSize.height * 0.7),
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius:
                    BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.class_rounded,
                          color: AppTheme.accentBlue,
                          size: screenSize.height * 0.025,
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectClass,
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.chooseClassForNotification,
                              style:
                                  AppTheme.getCaptionSmall(screenSize).copyWith(
                                color: AppTheme.getTextSecondaryColor(context),
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
                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Groups by educational level
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedByLevel.entries.map((entry) {
                          final level = entry.key;
                          final groups = entry.value;
                          final isLevelSelected =
                              tempSelectedLevels.contains(level);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Educational level header
                              CheckboxListTile(
                                title: Text(
                                  level,
                                  style: AppTheme.getBodyLarge(screenSize)
                                      .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        AppTheme.getTextPrimaryColor(context),
                                  ),
                                ),
                                subtitle: Text(
                                  '${groups.length} grupos',
                                  style: AppTheme.getCaptionSmall(screenSize)
                                      .copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                                value: isLevelSelected,
                                activeColor: AppTheme.accentBlue,
                                onChanged: (bool? selected) {
                                  setDialogState(() {
                                    if (selected == true) {
                                      tempSelectedLevels.add(level);
                                      for (final group in groups) {
                                        if (!tempSelectedGroups
                                            .contains(group)) {
                                          tempSelectedGroups.add(group);
                                        }
                                      }
                                    } else {
                                      tempSelectedLevels.remove(level);
                                      tempSelectedGroups.removeWhere(
                                          (g) => groups.contains(g));
                                    }
                                  });
                                },
                              ),

                              // Individual groups
                              ...groups.map((group) {
                                final isSelected =
                                    tempSelectedGroups.contains(group);
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left:
                                          AppTheme.getLargePadding(screenSize)),
                                  child: CheckboxListTile(
                                    title: Text(
                                      group.grupo,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                      ),
                                    ),
                                    value: isSelected,
                                    activeColor: AppTheme.accentBlue,
                                    onChanged: (bool? selected) {
                                      setDialogState(() {
                                        if (selected == true) {
                                          tempSelectedGroups.add(group);
                                          // Check if all groups in level are selected
                                          if (groups.every((g) =>
                                              tempSelectedGroups.contains(g))) {
                                            if (!tempSelectedLevels
                                                .contains(level)) {
                                              tempSelectedLevels.add(level);
                                            }
                                          }
                                        } else {
                                          tempSelectedGroups.remove(group);
                                          tempSelectedLevels.remove(level);
                                        }
                                      });
                                    },
                                  ),
                                );
                              }).toList(),

                              SizedBox(
                                  height: AppTheme.getSmallPadding(screenSize)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.getMediumPadding(screenSize),
                            ),
                            side: BorderSide(
                                color: AppTheme.getBorderColor(context)),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedGroups = tempSelectedGroups;
                              _selectedNivelesEducativos = tempSelectedLevels;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.getMediumPadding(screenSize),
                            ),
                          ),
                          child: Text(
                            'Confirmar',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showShiftSelectionDialog(BuildContext context, List<Turno> turnos) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
        elevation: 8,
        child: Container(
          width: screenSize.width * 0.9,
          constraints: BoxConstraints(maxHeight: screenSize.height * 0.6),
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        AppTheme.getSmallPadding(screenSize) * 0.8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppTheme.getSmallRadius(screenSize)),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: AppTheme.accentOrange,
                      size: screenSize.height * 0.025,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar turno',
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.allStudentsInShift,
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
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
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Shifts list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: turnos.map((turno) {
                      return Card(
                        margin: EdgeInsets.only(
                            bottom: AppTheme.getSmallPadding(screenSize)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.getMediumRadius(screenSize)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          leading: Container(
                            padding: EdgeInsets.all(
                                AppTheme.getSmallPadding(screenSize)),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.getSmallRadius(screenSize)),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              color: AppTheme.accentOrange,
                              size: screenSize.height * 0.025,
                            ),
                          ),
                          title: Text(
                            turno.turno,
                            style: AppTheme.getBodyLarge(screenSize).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                          subtitle: Text(
                            '${turno.horaInicio} - ${turno.horaFin}',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppTheme.getTextSecondaryColor(context),
                            size: screenSize.height * 0.02,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedShift = turno;
                            });
                            Navigator.pop(context);
                          },
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
    );
  }

  void _navigateToStudentDirectory() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectableStudentsDirectoryView(
          selectionMode: true,
          allowMultiSelect: false,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedStudent = result;
      });
    }
  }

  bool _canSendMessage() {
    bool hasValidRecipient = true;

    if (_selectedRecipient == 'individual') {
      hasValidRecipient = _selectedStudent != null;
    } else if (_selectedRecipient == 'grupo') {
      hasValidRecipient = _selectedGroups.isNotEmpty;
    } else if (_selectedRecipient == 'turno') {
      hasValidRecipient = _selectedShift != null;
    }

    return _titleController.text.isNotEmpty &&
        _messageController.text.isNotEmpty &&
        _sendPushNotification &&
        hasValidRecipient;
  }

  void _sendNotification() {
    final l10n = AppLocalizations.of(context);
    final messageType = _selectedType == 'comunicado'
        ? l10n.communication
        : l10n.specialPermission;

    CustomSnackBar.show(
      context: context,
      message:
          '$messageType ${_scheduledDate != null ? l10n.scheduled : l10n.sentSuccessfully}',
      isError: false,
    );
    Navigator.pop(context);
  }
}
