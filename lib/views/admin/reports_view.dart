import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../components/headers/nav_header.dart';
import '../../components/admin/report_type_selector.dart';
import '../../components/admin/report_filters.dart';
import '../../components/admin/report_chart.dart';
import '../../components/admin/report_export_options.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String selectedReportType = 'attendance';
  String selectedPeriod = 'monthly';
  String selectedGrade = '';
  String selectedGroup = '';
  DateTime? startDate;
  DateTime? endDate;

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
              NavHeader(title: l10n.reports),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Type Selector
                      ReportTypeSelector(
                        screenSize: screenSize,
                        selectedType: selectedReportType,
                        onTypeChanged: (type) {
                          setState(() {
                            selectedReportType = type;
                          });
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Report Filters
                      ReportFilters(
                        screenSize: screenSize,
                        selectedPeriod: selectedPeriod,
                        selectedGrade: selectedGrade,
                        selectedGroup: selectedGroup,
                        startDate: startDate,
                        endDate: endDate,
                        onPeriodChanged: (period) {
                          setState(() {
                            selectedPeriod = period;
                          });
                        },
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
                        onDateRangeChanged: (start, end) {
                          setState(() {
                            startDate = start;
                            endDate = end;
                          });
                        },
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Report Chart
                      ReportChart(
                        screenSize: screenSize,
                        reportType: selectedReportType,
                        period: selectedPeriod,
                        grade: selectedGrade,
                        group: selectedGroup,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Export Options
                      ReportExportOptions(screenSize: screenSize),
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
