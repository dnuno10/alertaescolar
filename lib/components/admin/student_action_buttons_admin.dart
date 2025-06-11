import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../components/buttons/solid_button.dart';

class StudentActionButtonsAdmin extends StatelessWidget {
  final Alumno student;
  final Size screenSize;

  const StudentActionButtonsAdmin({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          // Header
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppTheme.warningColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.adminActions ?? 'Acciones administrativas',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Primary Actions
          Text(
            l10n.primaryActions ?? 'Acciones principales',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          Row(
            children: [
              Expanded(
                child: SolidButton(
                  backgroundColor: AppTheme.accentBlue,
                  onPressed: () => _editStudentInfo(context),
                  label: l10n.editStudent,
                  icon: Icons.edit_rounded,
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: SolidButton(
                  backgroundColor: AppTheme.successColor,
                  onPressed: () => _contactParents(context),
                  label: l10n.contactParents,
                  icon: Icons.phone_rounded,
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Communication Actions
          Text(
            l10n.communicationActions ?? 'Acciones de comunicación',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
            mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
            childAspectRatio: 2.5,
            children: [
              _ActionCard(
                icon: Icons.message_rounded,
                title: l10n.sendMessage ?? 'Enviar mensaje',
                color: AppTheme.accentPurple,
                onTap: () => _sendMessage(context),
                screenSize: screenSize,
              ),
              _ActionCard(
                icon: Icons.email_rounded,
                title: l10n.sendEmail ?? 'Enviar email',
                color: AppTheme.accentBlue,
                onTap: () => _sendEmail(context),
                screenSize: screenSize,
              ),
              _ActionCard(
                icon: Icons.event_note_rounded,
                title: l10n.addNote ?? 'Agregar nota',
                color: AppTheme.warningColor,
                onTap: () => _addNote(context),
                screenSize: screenSize,
              ),
              _ActionCard(
                icon: Icons.calendar_today_rounded,
                title: l10n.scheduleCall ?? 'Programar llamada',
                color: AppTheme.successColor,
                onTap: () => _scheduleCall(context),
                screenSize: screenSize,
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Administrative Actions
          Text(
            l10n.administrativeActions ?? 'Acciones administrativas',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.description_rounded,
                  title: l10n.generateReport ?? 'Generar reporte',
                  color: AppTheme.accentBlue,
                  onTap: () => _generateReport(context),
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _ActionCard(
                  icon: Icons.print_rounded,
                  title: l10n.printProfile ?? 'Imprimir perfil',
                  color: AppTheme.warningColor,
                  onTap: () => _printProfile(context),
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Emergency Actions
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              border: Border.all(
                color: AppTheme.errorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: AppTheme.errorColor,
                  size: screenSize.height * 0.025,
                ),
                SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                Expanded(
                  child: Text(
                    l10n.emergencyActions ?? 'Acciones de emergencia',
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _emergencyContact(context),
                  child: Text(
                    l10n.emergencyContact ?? 'Contacto de emergencia',
                    style: AppTheme.getCaptionSmall(screenSize).copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editStudentInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.editStudent,
      l10n.editStudentConfirm ?? '¿Desea editar la información del estudiante?',
      l10n.edit ?? 'Editar',
    );
  }

  void _contactParents(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.contactParents,
      l10n.contactParentsConfirm ??
          '¿Desea contactar a los padres del estudiante?',
      l10n.contact ?? 'Contactar',
    );
  }

  void _sendMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.sendMessage ?? 'Enviar mensaje',
      l10n.sendMessageConfirm ?? '¿Desea enviar un mensaje a los padres?',
      l10n.send,
    );
  }

  void _sendEmail(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.sendEmail ?? 'Enviar email',
      l10n.sendEmailConfirm ?? '¿Desea enviar un email a los padres?',
      l10n.send,
    );
  }

  void _addNote(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.addNote ?? 'Agregar nota',
      l10n.addNoteConfirm ??
          '¿Desea agregar una nota al expediente del estudiante?',
      l10n.add ?? 'Agregar',
    );
  }

  void _scheduleCall(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.scheduleCall ?? 'Programar llamada',
      l10n.scheduleCallConfirm ??
          '¿Desea programar una llamada con los padres?',
      l10n.schedule ?? 'Programar',
    );
  }

  void _generateReport(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.generateReport ?? 'Generar reporte',
      l10n.generateReportConfirm ?? '¿Desea generar un reporte del estudiante?',
      l10n.generate ?? 'Generar',
    );
  }

  void _printProfile(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showActionDialog(
      context,
      l10n.printProfile ?? 'Imprimir perfil',
      l10n.printProfileConfirm ?? '¿Desea imprimir el perfil del estudiante?',
      l10n.print ?? 'Imprimir',
    );
  }

  void _emergencyContact(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.emergency_rounded,
              color: AppTheme.errorColor,
              size: screenSize.height * 0.03,
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Text(
              l10n.emergencyContact ?? 'Contacto de emergencia',
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.emergencyContactConfirm ??
              'Se iniciará el protocolo de contacto de emergencia. ¿Continuar?',
          style: AppTheme.getBodyMedium(screenSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(
                  context,
                  l10n.emergencyContactInitiated ??
                      'Protocolo de emergencia iniciado');
            },
            child: Text(
              l10n.emergency ?? 'Emergencia',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(
    BuildContext context,
    String title,
    String content,
    String actionText,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          title,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: AppTheme.getBodyMedium(screenSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context,
                  '$actionText ${l10n.completedSuccessfully ?? 'completado exitosamente'}');
            },
            child: Text(
              actionText,
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Size screenSize;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.5),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenSize.height * 0.02,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
