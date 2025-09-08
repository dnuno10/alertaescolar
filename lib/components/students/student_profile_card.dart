import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';

class StudentProfileCard extends StatelessWidget {
  final StudentDetails student;
  final Color color;
  final Size screenSize;

  const StudentProfileCard({
    super.key,
    required this.student,
    required this.color,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Regla única de negocio: ACTIVO = tiene vínculo + llave vigente
    // (El provider fija `llaveActiva` solo si hay llave y está en ventana)
    final consideredActive = student.hasTutores && student.llaveActiva;

    final bgColor = consideredActive
        ? AppTheme.successColor.withOpacity(0.1)
        : AppTheme.errorColor.withOpacity(0.1);
    final fgColor =
        consideredActive ? AppTheme.successColor : AppTheme.errorColor;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            // CHIP de estado (VERDE/ROJO)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: screenSize.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
              ),
              child: Text(
                consideredActive ? l10n.active : l10n.inactive,
                style: AppTheme.getCaption(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: fgColor, // activo=verde, inactivo=rojo
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
