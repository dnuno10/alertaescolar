import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import '../schedule/schedule_view.dart';

class StudentDetailView extends StatelessWidget {
  final Alumno student;

  const StudentDetailView({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor
    ];
    final color = colors[student.hashCode % colors.length];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              _buildStickyHeader(context, l10n, screenSize),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: AppTheme.getMediumPadding(screenSize),
                      right: AppTheme.getMediumPadding(screenSize),
                      bottom: AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                      _buildStudentProfile(context, color, l10n, screenSize),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      _buildScheduleButton(context, l10n, screenSize),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      _buildStudentInfo(context, l10n, screenSize),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                      _buildKeyInfo(context, l10n, screenSize),
                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                      _buildActionButtons(context, l10n, screenSize),
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

  Widget _buildScheduleButton(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _viewSchedule(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPurple,
          foregroundColor: AppTheme.onPrimaryColor,
          padding: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize)),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          elevation: 0,
        ),
        icon: Icon(
          Icons.schedule_rounded,
          color: AppTheme.onPrimaryColor,
          size: screenSize.width * 0.06,
        ),
        label: Text(
          l10n.viewSchedule,
          style: AppTheme.getBodyLarge(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.onPrimaryColor,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyHeader(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize)),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenSize.width * 0.1,
                        height: screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.accentPurple,
                            size: screenSize.width * 0.05,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                      Expanded(
                        child: Text(
                          l10n.details,
                          style: AppTheme.getH2(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentProfile(BuildContext context, Color color,
      AppLocalizations l10n, Size screenSize) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: AppTheme.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: screenSize.width * 0.25,
              height: screenSize.width * 0.25,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  student.nombre.isNotEmpty
                      ? student.nombre[0].toUpperCase()
                      : 'A',
                  style: AppTheme.getH1(screenSize).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onPrimaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              student.nombre,
              style: AppTheme.getH1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: screenSize.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: student.activo
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                student.activo ? l10n.active : l10n.inactive,
                style: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: student.activo
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.academicInformation,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          _DetailRow(
            icon: Icons.school_rounded,
            label: l10n.gradeLevel,
            value: student.grado,
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _DetailRow(
            icon: Icons.person_rounded,
            label: l10n.studentId,
            value: student.id.isNotEmpty
                ? student.id.substring(0, 8.clamp(0, student.id.length))
                : l10n.noId,
            iconColor: AppTheme.accentPurple,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfo(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.keyInformation,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          _DetailRow(
            icon: Icons.key_rounded,
            label: l10n.keyCode,
            value: student.llave.isNotEmpty ? student.llave : l10n.notAssigned,
            iconColor: AppTheme.accentYellow,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _DetailRow(
            icon: Icons.power_settings_new_rounded,
            label: 'Status', // TODO: Add to l10n
            value: student.activo
                ? 'Activada'
                : 'Desactivada', // TODO: Add to l10n
            iconColor:
                student.activo ? AppTheme.successColor : AppTheme.errorColor,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Tiempo restante', // TODO: Add to l10n
            value: '30 días', // TODO: Calculate actual remaining time
            iconColor: AppTheme.accentBlue,
            screenSize: screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AppLocalizations l10n, Size screenSize) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _downloadCredential(context, l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: EdgeInsets.symmetric(
                  vertical: AppTheme.getSmallPadding(screenSize)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              ),
              elevation: 0,
            ),
            icon: Icon(
              Icons.download_rounded,
              color: AppTheme.onPrimaryColor,
              size: screenSize.width * 0.06,
            ),
            label: Text(
              l10n.downloadDigitalCredential,
              style: AppTheme.getBodyLarge(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onPrimaryColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editStudent(context, l10n),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentPurple,
                  side: BorderSide(color: AppTheme.accentPurple),
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
                icon: Icon(
                  Icons.edit_rounded,
                  size: screenSize.width * 0.05,
                  color: AppTheme.accentPurple,
                ),
                label: Text(
                  l10n.edit,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.getSmallPadding(screenSize)),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _deleteStudent(context, l10n),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: BorderSide(color: AppTheme.errorColor),
                  padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getSmallPadding(screenSize)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
                icon: Icon(
                  Icons.delete_rounded,
                  size: screenSize.width * 0.05,
                  color: AppTheme.errorColor,
                ),
                label: Text(
                  l10n.delete,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _viewSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleView(student: student),
      ),
    );
  }

  void _downloadCredential(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.generatingCredentialFor(student.nombre),
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editStudent(BuildContext context, AppLocalizations l10n) {
    // TODO: Navigate to edit student view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.editFunctionalityComingSoon,
          style: AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
      ),
    );
  }

  void _deleteStudent(BuildContext context, AppLocalizations l10n) {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.deleteStudent,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        content: Text(
          l10n.deleteStudentConfirmation(student.nombre),
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to students list
              Provider.of<StudentProvider>(context, listen: false)
                  .removeStudent(student.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.studentDeletedSuccessfully,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.delete,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Size screenSize;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getContainerBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.1,
            height: screenSize.width * 0.1,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.8),
            ),
            child: Icon(
              icon,
              size: screenSize.width * 0.05,
              color: iconColor,
            ),
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  value,
                  style: AppTheme.getSubtitle2(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
