import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../managers/user_provider.dart';
import '../../../managers/group_provider.dart';
import '../../../managers/schedule_provider.dart';

import '../../../components/headers/nav_header.dart';
import '../../../components/loading_dialog.dart';
import '../../../components/admin/schedule/education_level_group_selector.dart';
import '../../../components/admin/schedule/day_filter.dart';
import '../../../components/admin/schedule/schedule_display.dart';
import '../../../components/admin/schedule/contact_info_card.dart';

class ScheduleManagementView extends StatefulWidget {
  const ScheduleManagementView({super.key});

  @override
  State<ScheduleManagementView> createState() => _ScheduleManagementViewState();
}

class _ScheduleManagementViewState extends State<ScheduleManagementView> {
  String? _selectedNivelEducativo;
  String? _selectedGrupo;
  String? _selectedDayKey; // "lunes" | "martes" | ... | null
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Día actual como default
    _selectedDayKey = _getCurrentDayKey();
  }

  /// Obtiene el día actual como key: "lunes"..."domingo"
  String _getCurrentDayKey() {
    // DateTime.weekday: Mon=1 ... Sun=7
    const keys = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];
    final idx = DateTime.now().weekday - 1;
    return keys[idx.clamp(0, 6)];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeScheduleData();
  }

  Future<void> _initializeScheduleData() async {
    if (_isInitialized) return;

    Future.microtask(() async {
      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      final escuelaId = userProvider.currentUser?.escuelaId;
      if (escuelaId == null) return;

      LoadingDialog.show(context, message: 'Inicializando datos...');

      try {
        await Future.wait([
          scheduleProvider.initialize(escuelaId, context: context),
          groupProvider.loadGroups(escuelaId: escuelaId, context: context),
        ]);

        if (!mounted) return;

        final nivelesEducativos = groupProvider.getAvailableNivelesEducativos();
        if (nivelesEducativos.isNotEmpty && _selectedNivelEducativo == null) {
          setState(() {
            _selectedNivelEducativo = nivelesEducativos.first;
            _isInitialized = true;
          });
          await _loadGruposForNivel(_selectedNivelEducativo!);
        } else {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing schedule data: $e');
        if (mounted) {
          setState(() {
            _isInitialized = true; // Evita bucles
          });
        }
      } finally {
        if (mounted) LoadingDialog.hide(context);
      }
    });
  }

  Future<void> _loadGruposForNivel(String nivelEducativo) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final escuelaId = userProvider.currentUser?.escuelaId;
    if (escuelaId == null) return;

    try {
      final grupos = groupProvider.getGroupsByNivelEducativo(nivelEducativo);
      debugPrint('Grupos encontrados para $nivelEducativo: ${grupos.length}');

      if (grupos.isNotEmpty) {
        setState(() {
          _selectedGrupo = grupos.first.grupo;
        });

        await scheduleProvider.loadHorarios(
          escuelaId: escuelaId,
          grupoId: grupos.first.id,
          context: context,
        );
      } else {
        setState(() {
          _selectedGrupo = null;
        });
        debugPrint('No se encontraron grupos para el nivel: $nivelEducativo');
      }
    } catch (e) {
      debugPrint('Error loading grupos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer3<ThemeProvider, ScheduleProvider, GroupProvider>(
      builder:
          (context, themeProvider, scheduleProvider, groupProvider, child) {
        final error = scheduleProvider.error ?? groupProvider.error;
        final nivelesEducativos = groupProvider.getAvailableNivelesEducativos();

        final availableGrupos = _selectedNivelEducativo != null
            ? groupProvider
                .getGroupsByNivelEducativo(_selectedNivelEducativo!)
                .map((g) => g.grupo)
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
                      if (error != null)
                        _buildErrorState(error, screenSize)
                      else ...[
                        // Selector de nivel educativo y grupo
                        EducationLevelGroupSelector(
                          selectedNivelEducativo: _selectedNivelEducativo,
                          selectedGrupo: _selectedGrupo,
                          nivelesEducativos: nivelesEducativos,
                          grupos: availableGrupos,
                          onNivelEducativoChanged: (nivel) async {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _selectedNivelEducativo = nivel;
                              _selectedGrupo = null;
                            });
                            if (nivel != null) {
                              await _loadGruposForNivel(nivel);
                            }
                          },
                          onGrupoChanged: (grupo) async {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _selectedGrupo = grupo;
                            });
                            if (grupo != null &&
                                _selectedNivelEducativo != null) {
                              final grupos =
                                  groupProvider.getGroupsByNivelEducativo(
                                      _selectedNivelEducativo!);
                              final selectedGrupoData = grupos
                                  .where((g) => g.grupo == grupo)
                                  .firstOrNull;

                              if (selectedGrupoData != null) {
                                final userProvider = Provider.of<UserProvider>(
                                    context,
                                    listen: false);

                                await scheduleProvider.loadHorarios(
                                  escuelaId:
                                      userProvider.currentUser!.escuelaId!,
                                  grupoId: selectedGrupoData.id,
                                  context: context,
                                );
                              }
                            }
                          },
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                        // Filtro de día
                        DayFilter(
                          selectedDayKey: _selectedDayKey,
                          onDaySelected: (key) =>
                              setState(() => _selectedDayKey = key),
                          screenSize: screenSize,
                        ),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Vista de horario
                        if (_selectedGrupo != null)
                          ScheduleDisplay(
                            selectedGradeGroup: _selectedGrupo!,
                            selectedDayKey: _selectedDayKey,
                            schedules: scheduleProvider
                                .getHorariosForGroupName(_selectedGrupo!),
                            subjects: scheduleProvider.materias,
                            screenSize: screenSize,
                          )
                        else
                          _buildNoGroupSelectedState(screenSize),

                        SizedBox(height: AppTheme.getLargePadding(screenSize)),

                        // Información de contacto
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
              HapticFeedback.mediumImpact();
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
          color: AppTheme.accentPurple.withOpacity(0.2),
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
