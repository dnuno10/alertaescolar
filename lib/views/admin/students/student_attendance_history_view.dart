import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../components/admin/students/empty_records_state.dart';
import '../../../components/admin/students/attendance_record_item.dart';
import '../../../components/admin/students/student_info_card.dart';
import '../../../components/admin/students/records_header.dart';
import '../../../utils/time_format.dart';

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
  String _selectedStatus = 'all';
  DateTime? _selectedDate; // Se setea a HOY en initState
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String? _error;

  // Helper: solo la parte de fecha (sin hora)
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    // Mostrar TODOS los registros por defecto (sin filtro de fecha)
    _selectedDate = null;
    _loadAttendanceData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Traer TODOS los registros del alumno (sin rango de 30 días)
      final response = await supabase
          .from('notificaciones')
          .select('*')
          .eq('id_alumno', widget.student.id)
          .inFilter('tipo_notificacion', [
        'entrada',
        'salida',
        'retraso'
      ]).order('fecha_registro', ascending: false);

      setState(() {
        _allRecords = List<Map<String, dynamic>>.from(response);
        _filterRecords();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint('Error loading attendance data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadAttendanceData();
  }

  void _filterRecords() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final tipoNotificacion = record['tipo_notificacion'] as String;
        // 🔧 FIX: Usar TimeFormat.parseSupabaseDateTime para manejar timestamptz correctamente
        final fechaRegistro =
            TimeFormat.parseSupabaseDateTime(record['fecha_registro']);

        // Filtro por tipo
        final matchesStatus =
            _selectedStatus == 'all' || tipoNotificacion == _selectedStatus;

        // Filtro por fecha (por día)
        final matchesDate = _selectedDate == null ||
            (fechaRegistro.year == _selectedDate!.year &&
                fechaRegistro.month == _selectedDate!.month &&
                fechaRegistro.day == _selectedDate!.day);

        return matchesStatus && matchesDate;
      }).toList();
    });
  }

  Widget _buildFiltersSection(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.height * 0.025,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.filters,
                style: AppTheme.getBodyLarge(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Date picker + Status
          Column(
            children: [
              _buildDateSelector(context, screenSize),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),
              _buildStatusFilter(context, screenSize),
            ],
          ),

          // Botón limpiar filtros
          if (_selectedDate != null || _selectedStatus != 'all') ...[
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDate = null; // Todas las fechas
                  _selectedStatus = 'all';
                  _filterRecords();
                });
              },
              child: Text(l10n.clearFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, Size screenSize) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attendanceDate,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.accentPurple,
                      onPrimary: Colors.white,
                      surface: AppTheme.getCardColor(context),
                      onSurface: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDate = _dateOnly(picked);
                _filterRecords();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.getSmallPadding(screenSize),
              horizontal: AppTheme.getMediumPadding(screenSize),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // ignore: deprecated_member_use
                  AppTheme.accentPurple.withOpacity(0.1),
                  // ignore: deprecated_member_use
                  AppTheme.accentBlue.withOpacity(0.05),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              // ignore: deprecated_member_use
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppTheme.getSmallPadding(screenSize) * 0.6),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize)),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.accentPurple,
                          size: screenSize.height * 0.02,
                        ),
                      ),
                      SizedBox(
                          width: AppTheme.getSmallPadding(screenSize) * 0.8),
                      Flexible(
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Todas las fechas',
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: AppTheme.getTextPrimaryColor(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.accentPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Registro',
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.8),
        Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusOption(context, screenSize, 'all', 'Todos',
                      Icons.list_alt_rounded),
                  _buildStatusOption(context, screenSize, 'entrada', 'Entrada',
                      Icons.login_rounded),
                  _buildStatusOption(context, screenSize, 'retraso', 'Retraso',
                      Icons.schedule_rounded),
                  _buildStatusOption(context, screenSize, 'salida', 'Salida',
                      Icons.logout_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption(BuildContext context, Size screenSize, String value,
      String label, IconData icon) {
    final isSelected = _selectedStatus == value;

    Color getColor() {
      switch (value) {
        case 'entrada':
          return AppTheme.successColor;
        case 'retraso':
          return AppTheme.warningColor;
        case 'salida':
          return AppTheme.errorColor;
        default:
          return AppTheme.accentBlue;
      }
    }

    final color =
        isSelected ? getColor() : AppTheme.getTextSecondaryColor(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = value;
            _filterRecords();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: screenSize.height * 0.022,
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
              Text(
                label,
                style: AppTheme.getCaptionSmall(screenSize).copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: LiquidPullToRefresh(
          onRefresh: _onRefresh,
          color: AppTheme.accentPurple,
          backgroundColor: AppTheme.getBackgroundColor(context),
          height: 120,
          animSpeedFactor: 9.0,
          showChildOpacityTransition: false,
          child: CustomScrollView(
            slivers: [
              NavHeader(
                title: l10n.attendanceHistory,
                isSliverAppBar: false,
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
                      _buildFiltersSection(context, screenSize),

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
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (_error != null)
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Error al cargar datos: $_error',
                                      style: AppTheme.getBodyMedium(screenSize),
                                    ),
                                    ElevatedButton(
                                      onPressed: _loadAttendanceData,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              )
                            else if (_filteredRecords.isEmpty)
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
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
