import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/students/qr_scan_option_card.dart';
import 'package:alertaescolar/components/students/option_divider.dart';
import 'package:alertaescolar/components/students/manual_input_card.dart';
import 'package:alertaescolar/views/user/students/qr_scanner_view.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- (NUEVO)
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';
import '../../../components/loading_dialog.dart';

class AddStudentView extends StatefulWidget {
  const AddStudentView({super.key});

  @override
  State<AddStudentView> createState() => _AddStudentViewState();
}

class _AddStudentViewState extends State<AddStudentView> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _handledScan = false;

  // Enlace del tutorial solicitado
  static const String _helpVideoTitle =
      'Activa la credencial de tu hijo en Alerta Escolar | Tutorial Padres de Familia';
  static const String _helpVideoUrl =
      'https://www.youtube.com/watch?v=tdH5ABk7a3E';

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    final isLoggedIn = context.select<UserProvider, bool>((p) => p.isLoggedIn);
    final spLoading = context.select<StudentProvider, bool>((p) => p.isLoading);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              slivers: [
                NavHeader(title: l10n.addStudent),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppTheme.getMediumPadding(screenSize),
                      right: AppTheme.getMediumPadding(screenSize),
                      bottom: AppTheme.getMediumPadding(screenSize),
                    ),
                    child: Column(
                      children: [
                        // ———— ENLACE AL VIDEO (NUEVO) ————
                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        _HelpVideoCard(
                          title: _helpVideoTitle,
                          url: _helpVideoUrl,
                          onTap: () => _openExternalUrl(_helpVideoUrl),
                          screenSize: screenSize,
                        ),
                        // ————————————————————————————————

                        SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                        if (!isLoggedIn)
                          _NoSessionCard(
                            onReload: () {
                              context
                                  .read<UserProvider>()
                                  .loadCurrentUser(context, showDialog: true);
                            },
                          )
                        else ...[
                          QRScanOptionCard(
                            onTap:
                                spLoading ? null : () => _openQRScanner(l10n),
                          ),
                          OptionDivider(label: l10n.or),
                          ManualInputCard(
                            formKey: _formKey,
                            keyController: _keyController,
                            enabled: !spLoading,
                            onSubmitted: () {
                              if (!spLoading) _validateKeyCode(l10n);
                            },
                          ),
                          SizedBox(
                              height: AppTheme.getLargePadding(screenSize)),
                          SolidButton(
                            width: double.infinity,
                            icon: Icons.search_rounded,
                            onPressed: spLoading
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
                                    _validateKeyCode(l10n);
                                  },
                            label: l10n.validateCode,
                            semanticsLabel: l10n.validateCode,
                            screenSize: screenSize,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openQRScanner(AppLocalizations l10n) {
    final isLoggedIn = context.read<UserProvider>().isLoggedIn;
    final spLoading = context.read<StudentProvider>().isLoading;
    if (spLoading) return;
    if (!isLoggedIn) {
      _showErrorSnackBar(l10n.errorValidatingCode);
      return;
    }

    FocusScope.of(context).unfocus();
    _handledScan = false;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerView(
          onCodeScanned: (code) async {
            if (!mounted ||
                context.read<StudentProvider>().isLoading ||
                _handledScan) {
              return;
            }
            _handledScan = true;
            Navigator.of(context).pop();
            _keyController.text = code;
            FocusScope.of(context).unfocus();
            _validateKeyCode(l10n);
          },
          onClose: () {
            if (!_handledScan && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _validateKeyCode(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final keyCode = _keyController.text.replaceAll(' ', '').toUpperCase();
    if (keyCode.isEmpty) return;

    FocusScope.of(context).unfocus();
    LoadingDialog.show(context, message: l10n.validatingCode);

    try {
      final studentProvider = context.read<StudentProvider>();
      final currentUser = context.read<UserProvider>().requireCurrentUser();

      final validationResult =
          await studentProvider.validateStudentKeyCode(keyCode);
      if (!mounted) return;

      if (validationResult != null && validationResult['isValid'] == true) {
        bool alreadyHasStudent;
        try {
          alreadyHasStudent =
              await studentProvider.checkIfUserAlreadyHasStudent(
            studentId: validationResult['student']['id'],
            tutorId: currentUser.id,
          );
        } catch (e) {
          // ignore: use_build_context_synchronously
          LoadingDialog.hide(context);
          _showErrorSnackBar('${l10n.errorValidatingCode}: $e');
          return;
        }

        // ignore: use_build_context_synchronously
        LoadingDialog.hide(context);

        if (alreadyHasStudent) {
          _showErrorSnackBar(
              'Ya tienes este estudiante registrado en tu cuenta');
          return;
        }

        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;

        Navigator.pushNamed(
          context,
          AppRoutes.studentConfirmation,
          arguments: validationResult,
        );
      } else {
        // Mostrar ÚNICAMENTE el error que dejó el provider y limpiarlo para evitar duplicados
        final error =
            (context.read<StudentProvider>().error) ?? l10n.invalidStudentCode;
        context.read<StudentProvider>().clearError();

        LoadingDialog.hide(context);
        _showErrorSnackBar(error);
      }
    } catch (e) {
      if (!mounted) return;
      LoadingDialog.hide(context);
      _showErrorSnackBar('${l10n.errorValidatingCode}: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: AppTheme.getCaption(size).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
        ),
      ),
    );
  }

  // Abre URLs afuera (YouTube)
  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('No se pudo abrir el enlace.');
    }
  }
}

class _NoSessionCard extends StatelessWidget {
  final VoidCallback onReload;
  const _NoSessionCard({required this.onReload});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inicia sesión para agregar estudiantes',
              style: AppTheme.getSubtitle1(size)
                  .copyWith(color: AppTheme.getTextPrimaryColor(context))),
          SizedBox(height: AppTheme.getSmallPadding(size)),
          Text(
            'No encontramos una sesión activa. Vuelve a cargar tus datos o inicia sesión.',
            style: AppTheme.getBodyMedium(size)
                .copyWith(color: AppTheme.getTextSecondaryColor(context)),
          ),
          SizedBox(height: AppTheme.getMediumPadding(size)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Cargar usuario'),
            ),
          ),
        ],
      ),
    );
  }
}

// ———————————————————— Card del enlace al tutorial (NUEVO) ————————————————————
class _HelpVideoCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;
  final Size screenSize;

  const _HelpVideoCard({
    required this.title,
    required this.url,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: const [],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.getMediumPadding(screenSize),
          vertical: AppTheme.getSmallPadding(screenSize),
        ),
        leading: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          child: const Icon(Icons.ondemand_video_rounded),
        ),
        title: Text(
          title,
          maxLines: 1,
          style: AppTheme.getBodyMedium(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Text(
          url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        trailing: Icon(Icons.open_in_new, color: AppTheme.accentPurple),
        onTap: onTap,
      ),
    );
  }
}
