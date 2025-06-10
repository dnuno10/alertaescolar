import 'package:alertaescolar/components/custom_outline_button.dart';
import 'package:alertaescolar/components/nav_header.dart';
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
                      _buildSectionTitle(l10n.soundVibration, screenSize),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),

                      _buildSoundVibrationCard(l10n, screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Info Notice
                      _buildInfoNotice(l10n, screenSize),
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

  Widget _buildSectionTitle(String title, Size screenSize) {
    return Text(
      title,
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(context),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildSoundVibrationCard(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sound Toggle
          _buildSettingToggle(
            icon: Icons.volume_up_outlined,
            title: l10n.sound,
            subtitle: l10n.soundSubtitle,
            value: _soundEnabled,
            screenSize: screenSize,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),

          if (_soundEnabled) ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            // Sound Selection
            _buildSoundSelector(l10n, screenSize),
          ],

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Vibration Toggle
          _buildSettingToggle(
            icon: Icons.vibration_outlined,
            title: l10n.vibration,
            subtitle: l10n.vibrationSubtitle,
            value: _vibrationEnabled,
            screenSize: screenSize,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Test Button
          SizedBox(
            width: double.infinity,
            child: CustomOutlineButton(
                onPressed: () => _testNotification(l10n),
                label: l10n.testNotification,
                color: AppTheme.accentPurple,
                icon: Icons.play_arrow,
                screenSize: screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Size screenSize,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: screenSize.width * 0.12,
          height: screenSize.width * 0.12,
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentPurple,
            size: screenSize.width * 0.06,
          ),
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(context),
                  height: 1.4,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentPurple,
          activeTrackColor: AppTheme.accentPurple.withOpacity(0.3),
          inactiveThumbColor: AppTheme.getTextSecondaryColor(context),
          inactiveTrackColor:
              AppTheme.getTextSecondaryColor(context).withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSoundSelector(AppLocalizations l10n, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notificationTone,
          style: AppTheme.getCaption(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getInputFillColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            border: Border.all(
              color: AppTheme.accentPurple.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _notificationSound,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              dropdownColor: AppTheme.getSurfaceColor(context),
              items: _soundOptions.map((String soundKey) {
                return DropdownMenuItem<String>(
                  value: soundKey,
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        size: screenSize.width * 0.04,
                        color: AppTheme.accentPurple,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        _getSoundDisplayName(soundKey, l10n),
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _notificationSound = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNotice(AppLocalizations l10n, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.accentPurple,
            size: screenSize.width * 0.06,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notificationInfoTitle,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPurple,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  l10n.notificationInfoText,
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSoundDisplayName(String soundKey, AppLocalizations l10n) {
    switch (soundKey) {
      case 'sound_default':
        return l10n.soundDefault;
      case 'sound_bell':
        return l10n.soundBell;
      case 'sound_chime':
        return l10n.soundChime;
      case 'sound_soft':
        return l10n.soundSoft;
      case 'sound_classic':
        return l10n.soundClassic;
      default:
        return l10n.soundDefault;
    }
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
