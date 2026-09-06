import 'package:flutter/material.dart';
import '../buttons/custom_outline_button.dart';
import 'notification_setting_toggle.dart';
import 'sound_selector.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class SoundVibrationCard extends StatelessWidget {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String notificationSound;
  final List<String> soundOptions;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;
  final ValueChanged<String?> onSoundSelected;
  final VoidCallback onTestNotification;
  final Size screenSize;

  const SoundVibrationCard({
    super.key,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.notificationSound,
    required this.soundOptions,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.onSoundSelected,
    required this.onTestNotification,
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
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sound Toggle
          NotificationSettingToggle(
            icon: Icons.volume_up_outlined,
            title: l10n.sound,
            subtitle: l10n.soundSubtitle,
            value: soundEnabled,
            onChanged: onSoundChanged,
            screenSize: screenSize,
          ),

          if (soundEnabled) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            // Sound Selection
            SoundSelector(
              selectedSound: notificationSound,
              soundOptions: soundOptions,
              onSoundSelected: onSoundSelected,
              screenSize: screenSize,
            ),
          ],

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Vibration Toggle
          NotificationSettingToggle(
            icon: Icons.vibration_outlined,
            title: l10n.vibration,
            subtitle: l10n.vibrationSubtitle,
            value: vibrationEnabled,
            onChanged: onVibrationChanged,
            screenSize: screenSize,
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Test Button
          SizedBox(
            width: double.infinity,
            child: CustomOutlineButton(
                onPressed: onTestNotification,
                label: l10n.testNotification,
                color: AppTheme.accentPurple,
                icon: Icons.play_arrow,
                screenSize: screenSize),
          ),
        ],
      ),
    );
  }
}
