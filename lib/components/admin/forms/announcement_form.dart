import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../buttons/solid_button.dart';
import 'components/recipient_selector.dart';
import 'components/priority_selector.dart';
import '../../../widgets/custom_snack_bar.dart';

class AnnouncementForm extends StatefulWidget {
  final Size screenSize;

  const AnnouncementForm({
    super.key,
    required this.screenSize,
  });

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _recipientType = 'group'; // 'group' or 'student'
  String _selectedGrade = '';
  String _selectedGroup = '';
  String _selectedStudent = '';
  String _priority = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient Type Selector
            Text(
              l10n.selectRecipient,
              style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RecipientTypeButton(
                      text: l10n.sendToGroup,
                      isSelected: _recipientType == 'group',
                      onTap: () => setState(() => _recipientType = 'group'),
                      screenSize: widget.screenSize,
                    ),
                  ),
                  SizedBox(
                      width: AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                  Expanded(
                    child: _RecipientTypeButton(
                      text: l10n.sendToStudent,
                      isSelected: _recipientType == 'student',
                      onTap: () => setState(() => _recipientType = 'student'),
                      screenSize: widget.screenSize,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Recipient Selector
            RecipientSelector(
              screenSize: widget.screenSize,
              recipientType: _recipientType,
              selectedGrade: _selectedGrade,
              selectedGroup: _selectedGroup,
              selectedStudent: _selectedStudent,
              onGradeChanged: (grade) => setState(() => _selectedGrade = grade),
              onGroupChanged: (group) => setState(() => _selectedGroup = group),
              onStudentChanged: (student) =>
                  setState(() => _selectedStudent = student),
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Title Field
            Text(
              l10n.messageTitle,
              style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.enterMessageTitle,
                filled: true,
                fillColor: AppTheme.getInputFillColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(widget.screenSize)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(
                    AppTheme.getMediumPadding(widget.screenSize)),
              ),
              style: AppTheme.getBodyMedium(widget.screenSize),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.titleRequired;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Content Field
            Text(
              l10n.messageContent,
              style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.enterMessageContent,
                filled: true,
                fillColor: AppTheme.getInputFillColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppTheme.getMediumRadius(widget.screenSize)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(
                    AppTheme.getMediumPadding(widget.screenSize)),
              ),
              style: AppTheme.getBodyMedium(widget.screenSize),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.contentRequired;
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

            // Priority Selector
            PrioritySelector(
              screenSize: widget.screenSize,
              selectedPriority: _priority,
              onPriorityChanged: (priority) =>
                  setState(() => _priority = priority),
            ),

            SizedBox(height: AppTheme.getLargePadding(widget.screenSize)),

            // Send Button
            SolidButton(
              backgroundColor: AppTheme.accentPurple,
              onPressed: _isLoading ? () {} : _sendAnnouncement,
              label: _isLoading ? (l10n.sending) : l10n.send,
              icon: _isLoading ? null : Icons.send_rounded,
              screenSize: widget.screenSize,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  void _sendAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_recipientType == 'group' &&
        (_selectedGrade.isEmpty || _selectedGroup.isEmpty)) {
      _showError(context, 'Seleccione un grado y grupo');
      return;
    }

    if (_recipientType == 'student' && _selectedStudent.isEmpty) {
      _showError(context, 'Seleccione un estudiante');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        CustomSnackBar.show(
          context: context,
          message: l10n.announcementSent,
          isError: false,
        );

        // Clear form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedGrade = '';
          _selectedGroup = '';
          _selectedStudent = '';
          _priority = 'medium';
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(context, 'Error al enviar comunicado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    CustomSnackBar.show(
      context: context,
      message: message,
      isError: true,
    );
  }
}

class _RecipientTypeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Size screenSize;

  const _RecipientTypeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize) * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPurple : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize) * 0.8),
        ),
        child: Text(
          text,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
