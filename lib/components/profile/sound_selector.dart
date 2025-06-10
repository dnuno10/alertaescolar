import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class SoundSelector extends StatelessWidget {
  final String selectedSound;
  final List<String> soundOptions;
  final ValueChanged<String?> onSoundSelected;
  final Size screenSize;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.soundOptions,
    required this.onSoundSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              value: selectedSound,
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
              items: soundOptions.map((String soundKey) {
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
              onChanged: onSoundSelected,
            ),
          ),
        ),
      ],
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
}
