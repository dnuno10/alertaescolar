import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/profile/notification_section_title.dart';
import 'package:alertaescolar/components/profile/sound_vibration_card.dart';
import 'package:alertaescolar/components/profile/notification_info_notice.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../widgets/custom_snack_bar.dart';

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
    final soundText = _soundEnabled
        ? l10n.testNotificationWithSound
        : l10n.testNotificationWithoutSound;
    final vibrationText = _vibrationEnabled ? l10n.withVibration : '';

    CustomSnackBar.show(
      context: context,
      message: '$soundText$vibrationText',
      isError: false,
      duration: const Duration(seconds: 3),
    );
  }
}
