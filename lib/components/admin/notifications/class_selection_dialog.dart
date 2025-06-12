import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ClassSelectionDialog extends StatelessWidget {
  final Function(String) onClassSelected;

  const ClassSelectionDialog({
    super.key,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    final classes = [
      {'id': '1A', 'name': '1ro A', 'students': 25, 'teacher': 'Prof. García'},
      {'id': '1B', 'name': '1ro B', 'students': 23, 'teacher': 'Prof. López'},
      {
        'id': '2A',
        'name': '2do A',
        'students': 27,
        'teacher': 'Prof. Martínez'
      },
      {
        'id': '2B',
        'name': '2do B',
        'students': 24,
        'teacher': 'Prof. Rodríguez'
      },
      {
        'id': '3A',
        'name': '3ro A',
        'students': 26,
        'teacher': 'Prof. Fernández'
      },
      {'id': '3B', 'name': '3ro B', 'students': 22, 'teacher': 'Prof. Morales'},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
      ),
      elevation: 8,
      child: Container(
        width: screenSize.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.7,
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
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.class_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectClass,
                        style: AppTheme.getH2(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.chooseClassForNotification,
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
            // Classes grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenSize.width > 600 ? 2 : 1,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
                  mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classData = classes[index];
                  return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onClassSelected(classData['name'] as String);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(
                            AppTheme.getMediumRadius(screenSize)),
                        child: Container(
                          padding: EdgeInsets.all(
                              AppTheme.getMediumPadding(screenSize)),
                          decoration: BoxDecoration(
                            color: AppTheme.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getMediumRadius(screenSize)),
                            border: Border.all(
                              color: AppTheme.getBorderColor(context),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: screenSize.width * 0.12,
                                height: screenSize.width * 0.12,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.getSmallRadius(screenSize)),
                                ),
                                child: Center(
                                  child: Text(
                                    classData['id'] as String,
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      color: AppTheme.accentBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: AppTheme.getMediumPadding(screenSize)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      classData['name'] as String,
                                      style: AppTheme.getBodyMedium(screenSize)
                                          .copyWith(
                                        color: AppTheme.getTextPrimaryColor(
                                            context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppTheme.getSmallPadding(
                                                screenSize) *
                                            0.3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline_rounded,
                                          size: screenSize.height * 0.016,
                                          color: AppTheme.getTextSecondaryColor(
                                              context),
                                        ),
                                        SizedBox(
                                            width: AppTheme.getSmallPadding(
                                                    screenSize) *
                                                0.5),
                                        Text(
                                          '${classData['students']} ${l10n.students}',
                                          style: AppTheme.getCaptionSmall(
                                                  screenSize)
                                              .copyWith(
                                            color:
                                                AppTheme.getTextSecondaryColor(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: screenSize.height * 0.018,
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Function(String) onClassSelected) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          ClassSelectionDialog(onClassSelected: onClassSelected),
    );
  }
}
