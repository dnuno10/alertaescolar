import 'package:alertaescolar/components/admin/notifications/class_selection_dialog.dart';
import 'package:alertaescolar/components/admin/notifications/class_selector_component.dart';
import 'package:alertaescolar/components/admin/notifications/shift_selection_dialog.dart';
import 'package:alertaescolar/components/admin/notifications/shift_selector_component.dart';
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
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/comunicado.dart';
import '../students/selectable_students_directory_view.dart';

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
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion

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
                                ClassSelectorComponent(
                                  selectedClass: _selectedClass,
                                  screenSize: screenSize,
                                  onSelectClass: _showClassSelectionDialog,
                                ),
                              ],
                              if (_selectedRecipient == 'turno') ...[
                                SizedBox(
                                    height:
                                        AppTheme.getMediumPadding(screenSize)),
                                ShiftSelectorComponent(
                                  selectedShift: _selectedShift,
                                  screenSize: screenSize,
                                  onSelectShift: _showShiftSelectionDialog,
                                ),
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

  void _showClassSelectionDialog() {
    ClassSelectionDialog.show(context, (className) {
      setState(() => _selectedClass = className);
    });
  }

  void _showShiftSelectionDialog() {
    ShiftSelectionDialog.show(context, (shiftName) {
      setState(() => _selectedShift = shiftName);
    });
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
    final l10n = AppLocalizations.of(context)!; // Added non-null assertion
    final messageType = _selectedType == 'comunicado'
        ? l10n.communication
        : l10n.specialPermission;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(
                width: AppTheme.getSmallPadding(MediaQuery.of(context).size)),
            Expanded(
              child: Text(
                '$messageType ${_scheduledDate != null ? l10n.scheduled : l10n.sentSuccessfully}',
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
