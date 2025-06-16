import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../components/admin/students/empty_records_state.dart';
import '../../../components/admin/students/attendance_record_item.dart';
import '../../../components/admin/students/student_info_card.dart';
import '../../../components/admin/students/filters_section.dart';
import '../../../components/admin/students/records_header.dart';

class StudentAttendanceHistoryView extends StatefulWidget {
  final StudentDetails student;

  const StudentAttendanceHistoryView({
    super.key,
    required this.student,
  });

  @override
  State<StudentAttendanceHistoryView> createState() =>
      _StudentAttendanceHistoryViewState();
}

class _StudentAttendanceHistoryViewState
    extends State<StudentAttendanceHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAttendanceData() {
    _allRecords = _generateMockAttendanceHistory();
    _filterRecords();
  }

  List<Map<String, dynamic>> _generateMockAttendanceHistory() {
    final records = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday <= 5) {
        // Only weekdays
        final status =
            i % 10 == 0 ? 'absent' : (i % 8 == 0 ? 'late' : 'present');
        final time = status == 'late'
            ? TimeOfDay(hour: 7, minute: 45 + (i % 20))
            : TimeOfDay(hour: 7, minute: 20 + (i % 15));

        records.add({
          'date': date,
          'status': status,
          'time': time,
          'scannedBy': ['María López', 'Juan Hernández', 'Ana García'][i % 3],
          'location': ['Entrada Principal', 'Entrada Secundaria'][i % 2],
          'notes': i % 15 == 0 ? 'Llegada justificada por cita médica' : null,
        });
      }
    }

    return records.reversed.toList();
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final date = record['date'] as DateTime;
        final status = record['status'] as String;
        final scannedBy = record['scannedBy'] as String;
        final location = record['location'] as String;

        final matchesSearch = query.isEmpty ||
            '${date.day}/${date.month}/${date.year}'.contains(query) ||
            scannedBy.toLowerCase().contains(query) ||
            location.toLowerCase().contains(query);

        final matchesStatus =
            _selectedStatus == 'all' || status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Map<String, int> _calculateStats() {
    final present =
        _filteredRecords.where((r) => r['status'] == 'present').length;
    final late = _filteredRecords.where((r) => r['status'] == 'late').length;
    final absent =
        _filteredRecords.where((r) => r['status'] == 'absent').length;
    final total = _filteredRecords.length;
    final rate = total > 0 ? ((present + late) * 100 / total).round() : 0;

    return {
      'present': present,
      'late': late,
      'absent': absent,
      'rate': rate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          NavHeader(
            title: l10n.attendanceHistory,
          ),
          SliverToBoxAdapter(
              child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      // Student Info Card
                      StudentInfoCard(
                        student: widget.student,
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Filters Section
                      FiltersSection(
                        searchController: _searchController,
                        selectedStatus: _selectedStatus,
                        onStatusChanged: (newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                            _filterRecords();
                          });
                        },
                        screenSize: screenSize,
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Records List
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getMediumPadding(screenSize)),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getLargeRadius(screenSize)),
                          border: Border.all(
                              color: AppTheme.getBorderColor(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecordsHeader(
                              recordCount: _filteredRecords.length,
                              screenSize: screenSize,
                            ),
                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),
                            if (_filteredRecords.isEmpty)
                              EmptyRecordsState(screenSize: screenSize)
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredRecords.length,
                                itemBuilder: (context, index) {
                                  return AttendanceRecordItem(
                                    record: _filteredRecords[index],
                                    screenSize: screenSize,
                                    isLast:
                                        index == _filteredRecords.length - 1,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),
                    ],
                  ))),
        ],
      ),
    );
  }
}
