import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'action_button.dart';

// Define enum for access types
enum AccessType {
  default_config, // Automático inteligente (basado en horarios)
  fixed_entry, // Entrada fija
  fixed_exit, // Salida fija
  extracurricular_entry, // Entrada extracurricular
  extracurricular_exit, // Salida extracurricular
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
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            AppTheme.getMediumPadding(screenSize),
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
          // Title Section
          Text(
            l10n.attendanceControl,
            style: AppTheme.getH1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Simple Description
          Text(
            l10n.scanQRToRegisterAttendance,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.3,
            ),
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Mode Selection Label
          Text(
            'Selecciona el modo de registro',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Dropdown
          _buildAccessTypeDropdown(context, l10n),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Action Buttons
          Row(
            children: [
              ActionButton(
                color: AppTheme.accentBlue,
                icon: Icons.settings_rounded,
                onTap: onConfigurationTap,
                screenSize: screenSize,
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: ActionButton(
                  color: AppTheme.accentOrange,
                  icon: Icons.notifications_rounded,
                  onTap: onNotificationTap,
                  screenSize: screenSize,
                  label: l10n.sendNotification,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccessTypeDropdown(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<AccessType>(
      onSelected: isScanning ? null : onAccessTypeChanged,
      offset: const Offset(0, 60), // Fuerza que aparezca debajo
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      color: AppTheme.getSurfaceColor(context),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width -
            (AppTheme.getMediumPadding(screenSize) * 2),
        maxWidth: MediaQuery.of(context).size.width -
            (AppTheme.getMediumPadding(screenSize) * 2),
        maxHeight: 320,
      ),
      itemBuilder: (BuildContext context) {
        return AccessType.values.map((AccessType value) {
          final bool isSelected = value == selectedAccessType;
          return PopupMenuItem<AccessType>(
            value: value,
            height: 60,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _getDropdownDisplayWidget(value, context),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_rounded,
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize),
          vertical: AppTheme.getMediumPadding(screenSize) * 0.8,
        ),
        child: Row(
          children: [
            Expanded(
              child: _getDropdownDisplayWidget(selectedAccessType, context),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDropdownDisplayWidget(AccessType value, BuildContext context) {
    switch (value) {
      case AccessType.default_config:
        final String defaultText =
            isDefaultEntryConfig ? 'Auto - Entrada' : 'Auto - Salida';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy,
              color: isDefaultEntryConfig ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                defaultText,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case AccessType.fixed_entry:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Entrada fija',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case AccessType.fixed_exit:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Salida fija',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case AccessType.extracurricular_entry:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Entrada extracurricular',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case AccessType.extracurricular_exit:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Salida extracurricular',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }
}
