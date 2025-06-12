import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ShiftSelectionDialog extends StatelessWidget {
  final Function(String) onShiftSelected;

  const ShiftSelectionDialog({
    super.key,
    required this.onShiftSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    final shifts = [
      {
        'id': 'morning',
        'name': l10n.morning,
        'time': '7:00 AM - 12:00 PM',
        'students': 156,
        'classes': 6,
        'icon': Icons.wb_sunny_rounded,
        'color': AppTheme.accentOrange,
      },
      {
        'id': 'afternoon',
        'name': l10n.afternoon,
        'time': '1:00 PM - 6:00 PM',
        'students': 134,
        'classes': 5,
        'icon': Icons.brightness_6_rounded,
        'color': AppTheme.accentPurple,
      },
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
      ),
      elevation: 8,
      child: Container(
        width: screenSize.width * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.accentPurple,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectShift,
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.chooseShiftToReceiveNotification,
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            // Shifts list
            Column(
              mainAxisSize: MainAxisSize.min,
              children: shifts.map((shift) {
                final color = shift['color'] as Color;
                final isLast = shifts.indexOf(shift) == shifts.length - 1;

                return Container(
                    margin: EdgeInsets.only(
                      bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onShiftSelected(shift['name'] as String);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize)),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon container with fixed size
                              Container(
                                width: screenSize.width * 0.12,
                                height: screenSize.width * 0.12,
                                constraints: const BoxConstraints(
                                  maxWidth: 60,
                                  maxHeight: 60,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getMediumRadius(screenSize)),
                                ),
                                child: Icon(
                                  shift['icon'] as IconData,
                                  color: color,
                                  size: screenSize.height * 0.028,
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getMediumPadding(screenSize)),
                              // Content with flexible layout
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      shift['name'] as String,
                                      style: AppTheme.getBodyLarge(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                                screenSize) *
                                            0.3),
                                    Text(
                                      shift['time'] as String,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                                screenSize) *
                                            0.3),
                                    // Stats row with flexible layout
                                    Wrap(
                                      spacing:
                                          AppTheme.getMediumPadding(screenSize),
                                      runSpacing:
                                          AppTheme.getSmallPadding(screenSize) *
                                              0.5,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.people_outline_rounded,
                                              size: screenSize.height * 0.016,
                                              color: AppTheme
                                                  .getTextSecondaryColor(
                                                      context),
                                            ),
                                            SizedBox(
                                                width: AppTheme.getSmallPadding(
                                                        screenSize) *
                                                    0.5),
                                            Text(
                                              '${shift['students']} ${l10n.students}',
                                              style: AppTheme.getCaptionSmall(
                                                      screenSize)
                                                  .copyWith(
                                                color: AppTheme
                                                    .getTextSecondaryColor(
                                                        context),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.class_rounded,
                                              size: screenSize.height * 0.016,
                                              color: AppTheme
                                                  .getTextSecondaryColor(
                                                      context),
                                            ),
                                            SizedBox(
                                                width: AppTheme.getSmallPadding(
                                                        screenSize) *
                                                    0.5),
                                            Text(
                                              '${shift['classes']} ${l10n.classes}',
                                              style: AppTheme.getCaptionSmall(
                                                      screenSize)
                                                  .copyWith(
                                                color: AppTheme
                                                    .getTextSecondaryColor(
                                                        context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: screenSize.height * 0.020,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Function(String) onShiftSelected) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          ShiftSelectionDialog(onShiftSelected: onShiftSelected),
    );
  }
}
