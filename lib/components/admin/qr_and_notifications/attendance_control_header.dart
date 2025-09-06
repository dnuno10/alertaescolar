import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'action_button.dart';

// Define enum for access types
enum AccessType {
  default_config, // Automático inteligente (basado en horarios)
  auto_entry, // Automático forzado a entrada
  auto_exit, // Automático forzado a salida
  entry, // Fijo entrada
  exit, // Fijo salida
}

class AttendanceControlHeader extends StatelessWidget {
  final bool isScanning;
  final Size screenSize;
  final VoidCallback onConfigurationTap;
  final VoidCallback onNotificationTap;
  final AccessType selectedAccessType;
  final bool
      isDefaultEntryConfig; // true = entrada, false = salida como default
  final ValueChanged<AccessType> onAccessTypeChanged;

  const AttendanceControlHeader({
    super.key,
    required this.isScanning,
    required this.screenSize,
    required this.onConfigurationTap,
    required this.onNotificationTap,
    required this.selectedAccessType,
    required this.isDefaultEntryConfig,
    required this.onAccessTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            AppTheme.getSmallPadding(screenSize),
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getLargePadding(screenSize),
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Actions Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attendanceControl,
                      style: AppTheme.getH1(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      l10n.scanQRToRegisterAttendance,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Access Type Dropdown
              _buildAccessTypeDropdown(context, l10n),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Row(
            children: [
              ActionButton(
                color: AppTheme.accentBlue,
                icon: Icons.settings_rounded,
                onTap: onConfigurationTap,
                screenSize: screenSize,
                // (opcional) label: l10n.configure,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              // Notification button
              ActionButton(
                color: AppTheme.accentOrange,
                icon: Icons.notifications_rounded,
                onTap: onNotificationTap,
                screenSize: screenSize,
                label: l10n.sendNotification,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccessTypeDropdown(BuildContext context, AppLocalizations l10n) {
    final String defaultText =
        isDefaultEntryConfig ? 'Auto - Entrada' : 'Auto - Salida';

    final dropdown = DropdownButton<AccessType>(
      value: selectedAccessType,
      isDense: true,
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: AppTheme.getTextSecondaryColor(context),
      ),
      items: [
        DropdownMenuItem(
          value: AccessType.default_config,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDefaultEntryConfig
                      ? Icons.login_rounded
                      : Icons.logout_rounded,
                  color: isDefaultEntryConfig
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  size: 18,
                  key: ValueKey(isDefaultEntryConfig),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      defaultText,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontSize: screenSize.height * 0.016,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Basado en horario',
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontSize: screenSize.height * 0.012,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AccessType.auto_entry,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.login_rounded,
                color: Color(0xFF2E7D32), // AppTheme.successColor
                size: 18,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Auto - Entrada',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: screenSize.height * 0.016,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AccessType.auto_exit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFC62828), // AppTheme.errorColor
                size: 18,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Auto - Salida',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: screenSize.height * 0.016,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AccessType.entry,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.login_rounded,
                color: Color(0xFF2E7D32), // AppTheme.successColor
                size: 18,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Entrada Fija',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: screenSize.height * 0.016,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: AccessType.exit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFC62828), // AppTheme.errorColor
                size: 18,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                'Salida Fija',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: screenSize.height * 0.016,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: isScanning
          ? null
          : (AccessType? newValue) {
              if (newValue != null) {
                onAccessTypeChanged(newValue);
              }
            },
      borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      dropdownColor: AppTheme.getSurfaceColor(context),
      elevation: 3,
    );

    return Tooltip(
      message: isScanning
          ? 'No disponible mientras se está escaneando'
          : 'Cambiar modo de registro',
      child: Opacity(
        opacity: isScanning ? 0.6 : 1.0,
        child: Container(
          height: AppTheme.getMediumRadius(screenSize) * 3,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getSmallPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(child: dropdown),
        ),
      ),
    );
  }
}
