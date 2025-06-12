import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/textfield/custom_input_field.dart';
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

class StudentAttendanceHistoryView extends StatefulWidget {
  final Alumno student;

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
            title: 'Historial',
          ),
          SliverToBoxAdapter(
              child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    children: [
                      // Student Info Card
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
                        child: Row(
                          children: [
                            Container(
                              width: screenSize.width * 0.15,
                              height: screenSize.width * 0.15,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getMediumRadius(screenSize)),
                              ),
                              child: Center(
                                child: Text(
                                  widget.student.nombre[0].toUpperCase(),
                                  style: AppTheme.getH1(screenSize).copyWith(
                                    color: Colors.white,
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
                                children: [
                                  Text(
                                    widget.student.nombre,
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${widget.student.grado}${widget.student.grupo}',
                                    style: AppTheme.getBodyMedium(screenSize)
                                        .copyWith(
                                      color: AppTheme.getTextSecondaryColor(
                                          context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.getLargePadding(screenSize)),

                      // Filters Section
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
                            Text(
                              'Filtros de Búsqueda',
                              style: AppTheme.getH2(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Search Field
                            CustomInputField(
                              controller: _searchController,
                              label:
                                  'Buscar por fecha, responsable o ubicación',
                              screenSize: screenSize,
                              icon: Icons.search_rounded,
                              keyboardType: TextInputType.text,
                            ),

                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),

                            // Status Filter
                            Text(
                              'Estado',
                              style: AppTheme.getCaption(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                                height:
                                    AppTheme.getSmallPadding(screenSize) * 0.5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppTheme.getSmallPadding(screenSize)),
                              decoration: BoxDecoration(
                                color: AppTheme.getBackgroundColor(context),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.getSmallRadius(screenSize)),
                                border: Border.all(
                                    color: AppTheme.getBorderColor(context)),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                isExpanded: true,
                                underline: const SizedBox(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedStatus = newValue!;
                                    _filterRecords();
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                      value: 'all', child: Text('Todos')),
                                  DropdownMenuItem(
                                      value: 'present',
                                      child: Text('Presente')),
                                  DropdownMenuItem(
                                      value: 'late', child: Text('Tarde')),
                                  DropdownMenuItem(
                                      value: 'absent', child: Text('Ausente')),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Registros Detallados',
                                    style: AppTheme.getH2(screenSize).copyWith(
                                      color:
                                          AppTheme.getTextPrimaryColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.getSmallPadding(screenSize)),
                                Text(
                                  '${_filteredRecords.length} registros',
                                  style:
                                      AppTheme.getCaption(screenSize).copyWith(
                                    color:
                                        AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: AppTheme.getMediumPadding(screenSize)),
                            if (_filteredRecords.isEmpty)
                              _buildEmptyState(screenSize)
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredRecords.length,
                                itemBuilder: (context, index) {
                                  return _buildRecordItem(
                                    _filteredRecords[index],
                                    screenSize,
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

  Widget _buildRecordItem(
      Map<String, dynamic> record, Size screenSize, bool isLast) {
    final date = record['date'] as DateTime;
    final status = record['status'] as String;
    final time = record['time'] as TimeOfDay?;
    final scannedBy = record['scannedBy'] as String;
    final location = record['location'] as String;
    final notes = record['notes'] as String?;

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);

    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getSmallPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenSize.height * 0.04,
                height: screenSize.height * 0.04,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: screenSize.height * 0.02,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (time != null)
                          Text(
                            time.format(context),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.25),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getSmallPadding(screenSize) * 0.5,
                            vertical:
                                AppTheme.getSmallPadding(screenSize) * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(screenSize) * 0.5),
                          ),
                          child: Text(
                            statusText,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Expanded(
                          flex: 2,
                          child: Text(
                            location,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                            width: AppTheme.getSmallPadding(screenSize) * 0.5),
                        Expanded(
                          flex: 2,
                          child: Text(
                            scannedBy,
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notes != null) ...[
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.75),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_rounded,
                    color: AppTheme.warningColor,
                    size: screenSize.height * 0.018,
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                  Expanded(
                    child: Text(
                      notes,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenSize.width * 0.15,
            color:
                AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'No se encontraron registros',
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Intenta ajustar los filtros de búsqueda',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppTheme.successColor;
      case 'late':
        return AppTheme.warningColor;
      case 'absent':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_rounded;
      case 'late':
        return Icons.schedule_rounded;
      case 'absent':
        return Icons.close_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Presente';
      case 'late':
        return 'Tarde';
      case 'absent':
        return 'Ausente';
      default:
        return 'Desconocido';
    }
  }
}
