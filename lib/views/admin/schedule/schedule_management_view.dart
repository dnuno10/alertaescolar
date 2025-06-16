import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/schedule_provider.dart';
import '../../../components/headers/nav_header.dart';
import '../../../models/models.dart';
import '../../../components/admin/schedule/education_level_group_selector.dart';
import '../../../components/admin/schedule/day_filter.dart';
import '../../../components/admin/schedule/schedule_display.dart';
import '../../../components/admin/schedule/contact_info_card.dart';
import '../../../components/loading/loading_indicator.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String? _selectedNivelEducativo;
  String? _selectedGrupo;
  DiaSemana? _selectedDay;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeScheduleData();
  }

  Future<void> _initializeScheduleData() async {
    if (_isInitialized) return;

    // Use Future.microtask to defer the initialization until after the current build phase
    Future.microtask(() async {
      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      if (userProvider.currentUser?.escuelaId != null) {
        LoadingDialog.show(context, message: 'Inicializando datos...');

        try {
          await scheduleProvider.initialize(
              userProvider.currentUser!.escuelaId!,
              context: context);

          if (!mounted) return;

          final nivelesEducativos =
              scheduleProvider.getNivelesEducativosNames();
          if (nivelesEducativos.isNotEmpty && _selectedNivelEducativo == null) {
            setState(() {
              _selectedNivelEducativo = nivelesEducativos.first;
              _isInitialized = true;
            });

            // Load groups for the first nivel educativo
            await _loadGruposForNivel(_selectedNivelEducativo!);
          }
        } finally {
          if (mounted) {
            LoadingDialog.hide(context);
          }
        }
      }
    });
  }

  Future<void> _loadGruposForNivel(String nivelEducativo) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    if (userProvider.currentUser?.escuelaId != null) {
      try {
        // Make sure niveles educativos are loaded first
        if (scheduleProvider.nivelesEducativos.isEmpty) {
          await scheduleProvider.loadNivelesEducativos(
            escuelaId: userProvider.currentUser!.escuelaId!,
            context: context,
          );
        }

        // Don't reload groups, just filter the existing ones
        final grupos =
            scheduleProvider.getGruposByNivelEducativoName(nivelEducativo);
        debugPrint('Grupos encontrados para $nivelEducativo: ${grupos.length}');

        if (grupos.isNotEmpty) {
          setState(() {
            _selectedGrupo = grupos.first['grupo'];
          });

          // Load schedules for the selected group
          await scheduleProvider.loadHorarios(
            escuelaId: userProvider.currentUser!.escuelaId!,
            grupoId: grupos.first['id'],
            context: context,
          );
        } else {
          // If no groups found, clear the selection
          setState(() {
            _selectedGrupo = null;
          });
          debugPrint('No se encontraron grupos para el nivel: $nivelEducativo');

          // Debug: Print all available groups and their levels
          scheduleProvider.debugPrintAllData();
        }
      } catch (e) {
        debugPrint('Error loading grupos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer2<ThemeProvider, ScheduleProvider>(
      builder: (context, themeProvider, scheduleProvider, child) {
        final isLoading = scheduleProvider.isLoading;
        final error = scheduleProvider.error;
        final hasSchedules = scheduleProvider.horarios.isNotEmpty;
        final nivelesEducativos = scheduleProvider.getNivelesEducativosNames();

        // Get available groups for the selected nivel educativo
        final availableGrupos = _selectedNivelEducativo != null
            ? scheduleProvider
                .getGruposByNivelEducativoName(_selectedNivelEducativo!)
                .map((grupo) => grupo['grupo'].toString())
                .toList()
            : <String>[];

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              NavHeader(title: l10n.scheduleManagement),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null && !hasSchedules)
                        _buildErrorState(error, screenSize)
                      else ...[
                        // Education Level and Group Selector
                        EducationLevelGroupSelector(
                          selectedNivelEducativo: _selectedNivelEducativo,
                          selectedGrupo: _selectedGrupo,
                          nivelesEducativos: nivelesEducativos,
                          grupos: availableGrupos,
                          onNivelEducativoChanged: (nivel) async {
                            setState(() {
                              _selectedNivelEducativo = nivel;
                              _selectedGrupo = null;
                            });
                            if (nivel != null) {
                              await _loadGruposForNivel(nivel);
                            }
                          },
                          onGrupoChanged: (grupo) async {
                            setState(() {
                              _selectedGrupo = grupo;
                            });
                            if (grupo != null &&
                                _selectedNivelEducativo != null) {
                              final grupos = scheduleProvider
                                  .getGruposByNivelEducativoName(
                                      _selectedNivelEducativo!);
                              final selectedGrupoData = grupos.firstWhere(
                                (g) => g['grupo'] == grupo,
                                orElse: () => <String, dynamic>{},
                              );
                              if (selectedGrupoData.isNotEmpty) {
                                final userProvider = Provider.of<UserProvider>(
                                    context,
                                    listen: false);

                                await scheduleProvider.loadHorarios(
                                  escuelaId:
                                      userProvider.currentUser!.escuelaId!,
                                  grupoId: selectedGrupoData['id'],
                                  context: context,
                                );
                              }
                            }
                          },
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                        // Day Filter
                        DayFilter(
                          selectedDay: _selectedDay,
                          onDaySelected: (day) =>
                              setState(() => _selectedDay = day),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Schedule Display
                        if (_selectedGrupo != null)
                          ScheduleDisplay(
                            selectedGradeGroup: _selectedGrupo!,
                            selectedDay: _selectedDay,
                            schedules: scheduleProvider
                                .getHorariosForGroup(_selectedGrupo!),
                            subjects: scheduleProvider.materias,
                            screenSize: screenSize,
                          )
                        else
                          _buildNoGroupSelectedState(screenSize),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Contact Information Card
                        ContactInfoCard(screenSize: screenSize),
                      ],
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

  Widget _buildErrorState(String error, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: screenSize.width * 0.15,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            AppLocalizations.of(context).errorLoadingSchedule,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            error,
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ElevatedButton.icon(
            onPressed: () async {
              LoadingDialog.show(context, message: 'Reintentando...');
              try {
                await _initializeScheduleData();
              } finally {
                if (mounted) {
                  LoadingDialog.hide(context);
                }
              }
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
                vertical: AppTheme.getSmallPadding(screenSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGroupSelectedState(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: screenSize.width * 0.12,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Text(
            'Selecciona un grupo',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          Text(
            'Primero selecciona un nivel educativo y luego un grupo para ver los horarios',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
