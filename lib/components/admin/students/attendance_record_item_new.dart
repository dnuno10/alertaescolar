import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'status_chip.dart';

class AttendanceRecordItem extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isLast;
  final Size screenSize;

  const AttendanceRecordItem({
    super.key,
    required this.record,
    required this.isLast,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Handle new notification format
    final fechaRegistro = DateTime.parse(record['fecha_registro']);
    final tipoNotificacion = record['tipo_notificacion'] as String;
    final titulo = record['titulo'] as String? ?? '';
    final mensaje = record['mensaje'] as String? ?? '';

    final statusColor = _getStatusColor(tipoNotificacion);
    final statusIcon = _getStatusIcon(tipoNotificacion);
    final statusText = _getStatusText(context, tipoNotificacion);

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenSize.height * 0.04,
                height: screenSize.height * 0.04,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: screenSize.height * 0.02,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${fechaRegistro.day}/${fechaRegistro.month}/${fechaRegistro.year}',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${fechaRegistro.hour.toString().padLeft(2, '0')}:${fechaRegistro.minute.toString().padLeft(2, '0')}',
                          style: AppTheme.getCaptionSmall(screenSize).copyWith(
                            color: AppTheme.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.25),
                    Row(
                      children: [
                        StatusChip(
                          text: statusText,
                          color: statusColor,
                          screenSize: screenSize,
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Expanded(
                          child: Text(
                            titulo.isNotEmpty
                                ? titulo
                                : 'Registro de $tipoNotificacion',
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mensaje.isNotEmpty) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.75),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_rounded,
                    color: statusColor,
                    size: screenSize.height * 0.018,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Expanded(
                    child: Text(
                      mensaje,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'entrada':
        return AppTheme.successColor;
      case 'retraso':
        return AppTheme.warningColor;
      case 'salida':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'entrada':
        return Icons.login_rounded;
      case 'retraso':
        return Icons.schedule_rounded;
      case 'salida':
        return Icons.logout_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    switch (status) {
      case 'entrada':
        return 'Entrada';
      case 'retraso':
        return 'Retraso';
      case 'salida':
        return 'Salida';
      default:
        return status;
    }
  }
}
