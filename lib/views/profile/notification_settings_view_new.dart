import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/profile/notification_section_title.dart';
import 'package:alertaescolar/components/profile/sound_vibration_card.dart';
import 'package:alertaescolar/components/profile/notification_info_notice.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _notificationSound = 'sound_default';

  final List<String> _soundOptions = [
    'sound_default',
    'sound_bell',
    'sound_chime',
    'sound_soft',
    'sound_classic',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.notifications),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sound & Vibration Section
                      NotificationSectionTitle(
                        title: l10n.soundVibration,
                        screenSize: screenSize,
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      SoundVibrationCard(
                        soundEnabled: _soundEnabled,
                        vibrationEnabled: _vibrationEnabled,
                        notificationSound: _notificationSound,
                        soundOptions: _soundOptions,
                        onSoundChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                        onVibrationChanged: (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        },
                        onSoundSelected: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _notificationSound = newValue;
                            });
                          }
                        },
                        onTestNotification: () => _testNotification(l10n),
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Info Notice
                      NotificationInfoNotice(screenSize: screenSize),
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

  void _testNotification(AppLocalizations l10n) {
    // Show a test notification
    final screenSize = MediaQuery.of(context).size;
    final soundText = _soundEnabled
        ? l10n.testNotificationWithSound
        : l10n.testNotificationWithoutSound;
    final vibrationText = _vibrationEnabled ? l10n.withVibration : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: AppTheme.onPrimaryColor,
              size: screenSize.width * 0.05,
            ),
            SizedBox(width: screenSize.width * 0.02),
            Expanded(
              child: Text(
                '$soundText$vibrationText',
                style:
                    AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              AppTheme.getSmallRadius(MediaQuery.of(context).size)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
