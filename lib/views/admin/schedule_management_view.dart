import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/headers/nav_header.dart';
import '../../components/admin/time_settings_card.dart';
import '../../components/admin/schedule_grade_selector.dart';
import '../../components/admin/schedule_editor.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String selectedGrade = '1°';
  String selectedGroup = 'A';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              NavHeader(title: l10n.scheduleManagement),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Settings
                      TimeSettingsCard(screenSize: screenSize),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Grade and Group Selector
                      ScheduleGradeSelector(
                        screenSize: screenSize,
                        selectedGrade: selectedGrade,
                        selectedGroup: selectedGroup,
                        onGradeChanged: (grade) {
                          setState(() {
                            selectedGrade = grade;
                          });
                        },
                        onGroupChanged: (group) {
                          setState(() {
                            selectedGroup = group;
                          });
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Schedule Editor
                      ScheduleEditor(
                        screenSize: screenSize,
                        selectedGrade: selectedGrade,
                        selectedGroup: selectedGroup,
                      ),
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
}
