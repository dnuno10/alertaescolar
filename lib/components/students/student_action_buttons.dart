// lib/components/students/student_action_buttons.dart
import 'dart:async';
import 'dart:io';
import 'package:alertaescolar/components/students/digital_credential_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import '../buttons/solid_button.dart';
import '../buttons/custom_outline_button.dart';

class StudentActionButtons extends StatefulWidget {
  final StudentDetails student;
  final Size screenSize;
  final String schoolName;

  const StudentActionButtons({
    super.key,
    required this.student,
    required this.screenSize,
    this.schoolName = '-',
  });

  @override
  State<StudentActionButtons> createState() => _StudentActionButtonsState();
}

class _StudentActionButtonsState extends State<StudentActionButtons> {
  final ScreenshotController _shot = ScreenshotController();
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Botón: Abrir hoja de compartir (incluye opciones de guardar)
        SolidButton(
          icon: Icons.ios_share_rounded,
          width: double.infinity,
          onPressed: _isWorking
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  await _shareCredential(context, l10n);
                },
          isLoading: _isWorking,
          label: l10n
              .downloadDigitalCredential, // si quieres cambia el texto a "Compartir credencial"
          screenSize: widget.screenSize,
          backgroundColor: AppTheme.accentOrange,
        ),

        // // Botón eliminar (igual que antes)
        // SizedBox(
        //   width: double.infinity,
        //   child: CustomOutlineButton(
        //     onPressed: () {
        //       HapticFeedback.mediumImpact();
        //       _deleteStudent(context, l10n);
        //     },
        //     label: l10n.delete,
        //     icon: Icons.delete,
        //     color: AppTheme.errorColor,
        //     screenSize: widget.screenSize,
        //   ),
        // ),
      ],
    );
  }

  Future<void> _shareCredential(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    setState(() => _isWorking = true);
    try {
      // Copiamos contexto visual para que el render off-screen tenga MediaQuery/Theme/Locale
      final mq = MediaQuery.of(context);
      final theme = Theme.of(context);
      final locale = Localizations.localeOf(context);

      // 1) Render a PNG (sin dart:ui/rendering en tu código)
      final bytes = await _shot
          .captureFromWidget(
            MediaQuery(
              data: mq,
              child: Theme(
                data: theme,
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Localizations.override(
                        context: context,
                        locale: locale,
                        child: DigitalCredentialCard(
                            student: widget.student,
                            screenSize: widget.screenSize,
                            schoolName: widget.schoolName),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            context: context,
            pixelRatio: 3.0,
            delay: const Duration(milliseconds: 30),
          )
          .timeout(const Duration(seconds: 5));

      if (bytes.isEmpty) {
        throw Exception('No se pudo generar la imagen de la credencial');
      }

      // 2) Guardamos en un archivo TEMPORAL (para mejor compatibilidad de share en Android/iOS)
      final fileName = 'cred_${widget.student.matricula}'.replaceAll(' ', '_');
      final tempDir = Platform.isIOS
          ? await getTemporaryDirectory()
          : (await getExternalStorageDirectory() ??
              await getTemporaryDirectory());
      final filePath = '${tempDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 3) Hoja de compartir nativa (el usuario decide guardar, enviar, etc.)
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/png', name: '$fileName.png')],
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null, // útil en iPad
        subject: 'Credencial digital - ${widget.student.nombre}',
        text: 'Credencial digital de ${widget.student.nombre}',
      );

      // Nota: No mostramos SnackBar de éxito porque la elección es del usuario (guardar/compartir)
    } on TimeoutException {
      _showSnack(context, '${l10n.errorSavingCredential} (timeout)',
          AppTheme.errorColor);
    } catch (e, st) {
      debugPrint('Error compartiendo credencial: $e');
      debugPrint('Stack: $st');
      _showSnack(context, l10n.errorSavingCredential, AppTheme.errorColor);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showSnack(BuildContext context, String msg, Color bg) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTheme.getCaption(size).copyWith(
            color: AppTheme.onPrimaryColor,
          ),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        ),
        duration: const Duration(seconds: 3),
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
          l10n.deleteStudentConfirmation(widget.student.nombre),
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: Text(
              l10n.cancel,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.studentDeletedSuccessfully,
                    style: AppTheme.getCaption(screenSize).copyWith(
                      color: AppTheme.onPrimaryColor,
                    ),
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallPadding(screenSize)),
                  ),
                ),
              );
              Navigator.pop(context);
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
