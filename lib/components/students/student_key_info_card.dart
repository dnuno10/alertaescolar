// lib/components/students/student_key_info_card.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../managers/student_provider.dart';
import '../../app/app_theme.dart';
import 'student_detail_row.dart';

class StudentKeyInfoCard extends StatelessWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentKeyInfoCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Normalización de campos mostrables
    final String keyCode = (student.llaveCodigo?.trim().isNotEmpty == true)
        ? student.llaveCodigo!.trim()
        : l10n.notAssigned;

    final String statusText = _buildStatusText(l10n);
    final String remainingTimeText = _calculateRemainingTime(context);

    // Color del ícono de “tiempo restante”:
    // - Si ya expiró → error
    // - Si faltan <= 7 días → warning
    // - En otro caso → azul/acento
    final _RemainingState remainingState = _remainingState();
    final Color remainingIconColor = switch (remainingState) {
      _RemainingState.expired => AppTheme.errorColor,
      _RemainingState.urgent => AppTheme.warningColor,
      _ => AppTheme.accentBlue,
    };

    // Fila opcional para cupo de vinculaciones (limite_vinculacion como contador)
    final bool showLinkQuota = student.limiteVinculacion != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: const [],
      ),
      child: Semantics(
        container: true,
        label: l10n.keyInformation,
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

            // Código de llave (seleccionable)
            StudentDetailRow(
              icon: Icons.key_rounded,
              label: l10n.keyCode,
              value: keyCode,
              iconColor: AppTheme.accentYellow,
              screenSize: screenSize,
              selectableValue: true,
              semanticsValue: '${l10n.keyCode}: $keyCode',
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Estado (activada/desactivada + # de tutores)
            StudentDetailRow(
              icon: Icons.power_settings_new_rounded,
              label: l10n.status,
              value: statusText,
              iconColor: student.llaveActiva
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
              screenSize: screenSize,
              semanticsValue: '${l10n.status}: $statusText',
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),

            // Tiempo restante (según fecha_desactivacion)
            StudentDetailRow(
              icon: Icons.schedule_rounded,
              label: l10n.remainingTime,
              value: remainingTimeText,
              iconColor: remainingIconColor,
              screenSize: screenSize,
              semanticsValue: '${l10n.remainingTime}: $remainingTimeText',
            ),

            // Vinculaciones restantes (cupo) — solo si hay dato
            if (showLinkQuota) ...[
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              StudentDetailRow(
                icon: Icons.link_rounded,
                // Etiqueta neutral para no tocar l10n:
                label: 'Vinculaciones restantes',
                value: '${student.limiteVinculacion}',
                iconColor: AppTheme.accentPurple,
                screenSize: screenSize,
                semanticsValue:
                    'Vinculaciones restantes: ${student.limiteVinculacion}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildStatusText(AppLocalizations l10n) {
    if (!student.llaveActiva) return l10n.deactivated;

    final int linkedTutors = student.tutores.length;
    if (linkedTutors <= 0) return l10n.activated;

    // “Activada (1 tutor vinculado)” / “Activada (N tutores vinculados)”
    return '${l10n.activated} ($linkedTutors ${linkedTutors == 1 ? l10n.linkedTutor : l10n.linkedTutors})';
  }

  /// Devuelve el texto humanizado del tiempo restante con soporte para:
  /// - Información no disponible
  /// - Sin caducidad
  /// - Expirada
  /// - Días / Horas / Minutos
  String _calculateRemainingTime(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now();

    // Si no sabemos cuándo se registró la llave, no podemos calcular de forma confiable
    if (student.fechaRegistroLlave == null) {
      return l10n.informationNotAvailable;
    }

    // Si no hay fecha de desactivación → sin límite
    final DateTime? expirationDate = student.fechaDesactivacionLlave;
    if (expirationDate == null) {
      return l10n.noTimeLimit;
    }

    // ¿Ya expiró? (trata <= now como expirado para coincidir con el provider)
    if (!expirationDate.isAfter(now)) {
      return l10n.expired;
    }

    final Duration diff = expirationDate.difference(now);

    // Redondeo simple: si faltan 36 horas, muestra 1 día, etc.
    if (diff.inDays >= 1) {
      final int days = diff.inDays;
      return days == 1 ? l10n.oneDayRemaining : l10n.daysRemaining(days);
    }

    if (diff.inHours >= 1) {
      final int hours = diff.inHours;
      return hours == 1 ? l10n.oneHourRemaining : l10n.hoursRemaining(hours);
    }

    if (diff.inMinutes >= 1) {
      final int minutes = diff.inMinutes;
      return minutes == 1
          ? l10n.oneMinuteRemaining
          : l10n.minutesRemaining(minutes);
    }

    return l10n.lessThanOneMinuteRemaining;
  }

  /// Clasifica el estado del tiempo restante para darle un color de señal
  _RemainingState _remainingState() {
    final DateTime now = DateTime.now();

    // Sin datos confiables
    if (student.fechaRegistroLlave == null) return _RemainingState.normal;

    final DateTime? expirationDate = student.fechaDesactivacionLlave;
    if (expirationDate == null) return _RemainingState.normal;

    // Expirada si expirationDate <= now
    if (!expirationDate.isAfter(now)) return _RemainingState.expired;

    final Duration diff = expirationDate.difference(now);
    // Umbral "urgente": 7 días o menos
    if (diff.inDays <= 7) return _RemainingState.urgent;

    return _RemainingState.normal;
  }
}

enum _RemainingState { normal, urgent, expired }
