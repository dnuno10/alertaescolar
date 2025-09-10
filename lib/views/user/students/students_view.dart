import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/components/students/students_header.dart';
import 'package:alertaescolar/components/students/students_section.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/models/models.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'add_student_view.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  bool _requestedUserLoad = false;
  String? _lastLoadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar usuario una sola vez al entrar (sin diálogos; la vista controla loaders)
    if (!_requestedUserLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context
            .read<UserProvider>()
            .loadCurrentUser(context, showDialog: false);
      });
      _requestedUserLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Observar al usuario actual
    final currentUser =
        context.select<UserProvider, Usuario?>((p) => p.currentUser);

    // Cuando hay usuario y aún no hemos cargado alumnos para ese id, disparamos carga
    if (currentUser != null && _lastLoadedUserId != currentUser.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context
            .read<StudentProvider>()
            .loadStudentsForUser(userId: currentUser.id);
        _lastLoadedUserId = currentUser.id;
      });
    }

    final isUserLoading =
        context.select<UserProvider, bool>((p) => p.isLoading);
    final isStudentsLoading =
        context.select<StudentProvider, bool>((p) => p.isLoading);

    // ¿ya tenemos alumnos en memoria?
    final hasAnyStudents = context.select<StudentProvider, bool>(
      (p) => p.students.isNotEmpty || p.filteredStudents.isNotEmpty,
    );

    // Overlay global sólo para carga inicial o cuando carga el usuario
    final showGlobalLoader =
        isUserLoading || (isStudentsLoading && !hasAnyStudents);

    return Consumer<ThemeProvider>(
      builder: (_, __, ___) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return Stack(
                children: [
                  // Estado sin sesión/usuario (no mostrar si hay overlay)
                  if (!showGlobalLoader && currentUser == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          l10n.sessionExpiredOrNoUser,
                          style: AppTheme.getBodyLarge(screenSize),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Contenido principal (cuando hay usuario)
                  if (currentUser != null)
                    LiquidPullToRefresh(
                      onRefresh: _onPullToRefresh,
                      color: AppTheme.accentPurple,
                      backgroundColor: AppTheme.getBackgroundColor(context),
                      height: 120,
                      animSpeedFactor: 9.0,
                      showChildOpacityTransition: false,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: StudentsHeader(screenSize: screenSize),
                          ),
                          if (!showGlobalLoader)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenSize.height * 0.12),
                                child: StudentsSection(
                                  isWide: isWide,
                                  screenSize: screenSize,
                                  onAddStudent: _goToAdd,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Overlay de loading (sólo carga inicial)
                  if (showGlobalLoader)
                    const Center(child: CircularProgressIndicator()),

                  // Errores de StudentProvider -> SnackBar una sola vez
                  Selector<StudentProvider, String?>(
                    selector: (_, p) => p.error,
                    builder: (context, error, _) {
                      if (error != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                          context.read<StudentProvider>().clearError();
                        });
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: (currentUser == null)
              ? null
              : SafeArea(
                  minimum: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppTheme.getLargeRadius(screenSize),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getShadowColor(context),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _goToAdd,
                      icon: Icon(
                        Icons.add_rounded,
                        size: screenSize.height * 0.025,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.addStudent,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.getMediumPadding(screenSize),
                          vertical: AppTheme.getSmallPadding(screenSize),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.getSmallRadius(screenSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _goToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddStudentView()),
    );
    if (!mounted) return;

    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      await context.read<StudentProvider>().loadStudentsForUser(
            userId: user.id,
            forceReload: true,
          );
    }
  }

  Future<void> _onPullToRefresh() async {
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      await context
          .read<StudentProvider>()
          .loadStudentsForUser(userId: user.id, forceReload: true);
    } else {
      // Si por algo perdió sesión, reintenta cargar usuario sin diálogos
      await context
          .read<UserProvider>()
          .loadCurrentUser(context, showDialog: false);
    }
  }
}
