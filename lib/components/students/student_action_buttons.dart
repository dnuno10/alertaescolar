// lib/components/students/student_action_buttons.dart
import 'dart:async';
import 'dart:io';
import 'package:alertaescolar/components/students/digital_credential_card.dart';
import 'package:alertaescolar/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import '../buttons/solid_button.dart';

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
  static const Size _credentialExportSize = Size(430, 820);

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
      ],
    );
  }

  Future<void> _shareCredential(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    setState(() => _isWorking = true);
    try {
      final mq = MediaQuery.of(context);
      final theme = Theme.of(context);
      final locale = Localizations.localeOf(context);

      StudentDetails safeStudent(StudentDetails s) {
        String clean(String? v) => (v ?? '').trim();
        return s.copyWith.call(
          nombre: clean(s.nombre).isEmpty ? '-' : clean(s.nombre),
          matricula: clean(s.matricula).isEmpty ? '-' : clean(s.matricula),
          grupo: clean(s.grupo).isEmpty ? 'Sin asignar' : clean(s.grupo),
          turno: clean(s.turno).isEmpty ? 'Sin asignar' : clean(s.turno),
        );
      }

      final safe = safeStudent(widget.student);
      final safeSchool =
          (widget.schoolName).trim().isEmpty ? '-' : widget.schoolName.trim();

      final bytes = await _shot
          .captureFromWidget(
            MediaQuery(
              data: mq.copyWith(size: _credentialExportSize),
              child: Theme(
                data: theme,
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: SizedBox(
                    width: _credentialExportSize.width,
                    height: _credentialExportSize.height,
                    child: RepaintBoundary(
                      child: Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Localizations.override(
                            context: context,
                            locale: locale,
                            child: DigitalCredentialCard(
                              student: safe,
                              screenSize: _credentialExportSize,
                              schoolName: safeSchool,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            context: context,
            pixelRatio: 3.0,
            delay: const Duration(milliseconds: 120),
          )
          .timeout(const Duration(seconds: 6));

      if (bytes.isEmpty) {
        throw Exception('No se pudo generar la imagen de la credencial');
      }

      // 2) Guardamos en un archivo TEMPORAL
      final fileName = 'cred_${widget.student.matricula}'.replaceAll(' ', '_');
      final tempDir = Platform.isIOS
          ? await getTemporaryDirectory()
          : (await getExternalStorageDirectory() ??
              await getTemporaryDirectory());
      final filePath = '${tempDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 3) Hoja de compartir nativa
      // ignore: use_build_context_synchronously
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/png', name: '$fileName.png')],
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        subject: 'Credencial digital - ${widget.student.nombre}',
        text: 'Credencial digital de ${widget.student.nombre}',
      );

      // NUEVO: Solo mostrar CustomSnackBar si realmente se compartió
      if (mounted && context.mounted) {
        switch (result.status) {
          case ShareResultStatus.success:
            CustomSnackBar.show(
              context: context,
              message: "Credencial digital compartida exitosamente",
              isError: false,
              duration: const Duration(seconds: 3),
            );
            break;
          case ShareResultStatus.dismissed:
            // Usuario canceló - no mostrar nada
            break;
          case ShareResultStatus.unavailable:
            CustomSnackBar.show(
              context: context,
              message: "No hay aplicaciones disponibles para compartir",
              isError: true,
              duration: const Duration(seconds: 3),
            );
            break;
        }
      }
    } on TimeoutException {
      if (mounted && context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: '${l10n.errorSavingCredential} (timeout)',
          isError: true,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, st) {
      debugPrint('Error compartiendo credencial: $e');
      debugPrint('Stack: $st');
      if (mounted && context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: l10n.errorSavingCredential,
          isError: true,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }
}
