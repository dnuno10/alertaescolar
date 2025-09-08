// lib/components/admin/notifications/notification_review_view.dart
import 'package:alertaescolar/models/notification_draft.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';
import '../../../services/notification_send_service.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/loading_dialog.dart';
import '../../../l10n/app_localizations.dart';

class NotificationReviewView extends StatefulWidget {
  final NotificationDraft draft;

  const NotificationReviewView({super.key, required this.draft});

  @override
  State<NotificationReviewView> createState() => _NotificationReviewViewState();
}

class _NotificationReviewViewState extends State<NotificationReviewView>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  // ====== Estado para nombres legibles ======
  String? _alumnoNombre;
  String? _turnoNombre;
  // Para grupos, mapeamos por ID para evitar desalineos (orden de inFilter no es garantizado)
  Map<String, String> _grupoEtiquetasById = {};
  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    _fetchRecipientNames();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // =========================
  // Fetch recipient names from database (IDs -> nombres)
  // =========================
  Future<void> _fetchRecipientNames() async {
    try {
      final supabase = Supabase.instance.client;
      final kind = widget.draft.tipoDestinatario;

      switch (kind) {
        case 'individual':
          if (widget.draft.alumnoId != null &&
              widget.draft.alumnoId!.isNotEmpty) {
            final response = await supabase
                .from('alumnos')
                .select('nombre')
                .eq('id', widget.draft.alumnoId!)
                .maybeSingle();
            _alumnoNombre =
                (response?['nombre'] as String?) ?? 'Nombre no disponible';
          }
          break;

        case 'grupo':
          final ids = widget.draft.grupoIds ?? const [];
          if (ids.isNotEmpty) {
            final response = await supabase
                .from('grupos')
                .select('id, grupo, nivel_educativo')
                .inFilter('id', ids);

            final map = <String, String>{};
            for (final item in (response as List)) {
              final id = (item['id'] ?? '').toString();
              final g = (item['grupo'] ?? 'Sin grupo').toString();
              final n = (item['nivel_educativo'] ?? 'Sin nivel').toString();
              if (id.isNotEmpty) map[id] = '$n - $g';
            }
            _grupoEtiquetasById = map;
          }
          break;

        case 'turno':
          if (widget.draft.turnoId != null &&
              widget.draft.turnoId!.isNotEmpty) {
            final response = await supabase
                .from('turnos')
                .select('turno')
                .eq('id', widget.draft.turnoId!)
                .maybeSingle();
            _turnoNombre =
                (response?['turno'] as String?) ?? 'Nombre no disponible';
          }
          break;

        case 'todos':
          // No hace falta traer nombres
          break;

        default:
          // Nada
          break;
      }
    } catch (e) {
      debugPrint('Error fetching recipient names: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNames = false;
        });
      }
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final pad = size.width * 0.045; // padding base relativo
    final gapS = size.height * 0.008;
    final gapM = size.height * 0.016;
    final gapL = size.height * 0.024;

    final isPermiso = widget.draft.tipoMensaje == 'permiso';
    final isComunicado = widget.draft.tipoMensaje == 'comunicado';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            NavHeader(title: l10n.reviewMessage),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contenido del mensaje
                    _buildMessageContentSection(
                      context: context,
                      pad: pad,
                      gapS: gapS,
                      gapM: gapM,
                    ),

                    SizedBox(height: gapM),

                    // Detalles de comunicado (si aplica)
                    if (isComunicado &&
                        widget.draft.tipoComunicado != null &&
                        widget.draft.prioridad != null) ...[
                      _Section(
                        title: l10n.communicationDetails,
                        pad: pad,
                        gapM: gapM,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: l10n.type,
                              value: _displayTipoComunicado(
                                  widget.draft.tipoComunicado!),
                              pad: pad,
                            ),
                            SizedBox(height: gapS),
                            _InfoRow(
                              label: l10n.priority,
                              value: _displayPrioridad(widget.draft.prioridad!),
                              pad: pad,
                              valueColor:
                                  _priorityColorFromDb(widget.draft.prioridad!),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gapM),
                    ],

                    // Destinatarios (nombres legibles)
                    _Section(
                      title: l10n.recipients,
                      pad: pad,
                      gapM: gapM,
                      child: _buildRecipientSummary(context, pad, gapS),
                    ),

                    SizedBox(height: gapM),

                    _Section(
                      title: 'Información de envío',
                      pad: pad,
                      gapM: gapM,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Fecha y hora',
                            value: _formatDateTime(DateTime.now()),
                            pad: pad,
                          ),
                          SizedBox(height: gapS),
                          _InfoRow(
                            label: 'Método',
                            value: 'Notificación push inmediata',
                            pad: pad,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: gapL * 1.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Barra inferior (solo confirmar)
      bottomNavigationBar: _BottomBar(
        pad: pad,
        gapM: gapM,
        onConfirm: _sendNotification,
      ),
    );
  }

  // =========================
  // Secciones y helpers UI
  // =========================

  Widget _buildRecipientSummary(BuildContext context, double pad, double gapS) {
    final kind = widget.draft.tipoDestinatario;

    if (_isLoadingNames) {
      return const _LoaderLine();
    }

    switch (kind) {
      case 'individual':
        return _RecipientBlock(
          pad: pad,
          label: 'Alumno',
          children: [
            _Pill(text: _alumnoNombre ?? 'Nombre no disponible'),
          ],
        );

      case 'grupo':
        {
          final ids = widget.draft.grupoIds ?? const [];
          final pills = <Widget>[];

          for (final id in ids) {
            final etiqueta = _grupoEtiquetasById[id] ?? 'Nombre no disponible';
            pills.add(_Pill(text: etiqueta));
          }

          return _RecipientBlock(
            pad: pad,
            label: 'Grupos',
            children: pills,
          );
        }

      case 'turno':
        return _RecipientBlock(
          pad: pad,
          label: 'Turno',
          children: [
            _Pill(text: _turnoNombre ?? 'Nombre no disponible'),
          ],
        );

      case 'todos':
        return _RecipientBlock(
          pad: pad,
          label: 'Cobertura',
          children: const [
            _Pill(text: 'Todos los estudiantes'),
          ],
        );

      default:
        return _RecipientBlock(
          pad: pad,
          label: 'Destinatario',
          children: const [
            _Pill(text: 'Tipo no reconocido'),
          ],
        );
    }
  }

  // =========================
  // Envío
  // =========================

  Future<void> _sendNotification() async {
    final isPermiso = widget.draft.tipoMensaje == 'permiso';

    LoadingDialog.show(
      context,
      message: 'Enviando ${isPermiso ? 'permiso especial' : 'comunicado'}…',
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null ||
          !(currentUser.escuelaId?.isNotEmpty ?? false)) {
        LoadingDialog.hide(context);
        throw Exception('Usuario no autenticado o sin escuela');
      }

      final service = NotificationSendService();
      final res = await service.sendDraft(
        draft: widget.draft,
        adminId: currentUser.id,
        escuelaId: currentUser.escuelaId!,
      );

      LoadingDialog.hide(context);

      if (res['success'] == true) {
        _showSuccessDialog(context, res);
      } else {
        CustomSnackBar.show(
          context: context,
          message: (res['error'] ?? 'Error desconocido').toString(),
          isError: true,
        );
      }
    } catch (e) {
      LoadingDialog.hide(context);
      CustomSnackBar.show(
        context: context,
        message: 'Error al enviar notificación: $e',
        isError: true,
      );
    }
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    final size = MediaQuery.of(context).size;
    final pad = size.width * 0.045;
    final gapM = size.height * 0.016;
    final notificationsSent =
        result['data']?['notifications_created'] as int? ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: pad),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(size)),
        ),
        child: Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(size)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withOpacity(0.4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minimal: sin ícono, mensaje claro
              Text(
                '¡Mensaje enviado!',
                style: AppTheme.getH2(size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: gapM * 0.75),
              Text(
                'Se envió a $notificationsSent ${notificationsSent == 1 ? 'estudiante' : 'estudiantes'}.',
                style: AppTheme.getBodyMedium(size).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: gapM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // cerrar diálogo
                    Navigator.pop(context); // volver a Review
                    Navigator.pop(context); // volver al flujo anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: gapM * 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.getMediumRadius(size)),
                    ),
                  ),
                  child: Text(
                    'Finalizar',
                    style: AppTheme.getBodyMedium(size).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Mapeos y helpers display
  // =========================
  String _displayTipoComunicado(String db) {
    switch (db) {
      case 'emergencia':
        return 'Emergencia';
      case 'paseo':
        return 'Paseo';
      case 'evento':
        return 'Evento';
      case 'recordatorio_pago':
        return 'Recordatorio de pago';
      case 'citatorio':
        return 'Citatorio';
      case 'informativo':
        return 'Informativo';
      case 'celebracion':
        return 'Celebración';
      case 'suspension_clases':
        return 'Suspensión de clases';
      case 'cambio_horario':
        return 'Cambio de horario';
      default:
        return db;
    }
  }

  String _displayPrioridad(String db) {
    switch (db) {
      case 'baja':
        return 'Baja';
      case 'media':
        return 'Media';
      case 'alta':
        return 'Alta';
      case 'critica':
        return 'Crítica';
      default:
        return db;
    }
  }

  Color _priorityColorFromDb(String db) {
    switch (db) {
      case 'baja':
        return AppTheme.successColor;
      case 'media':
        return AppTheme.accentOrange;
      case 'alta':
        return AppTheme.warningColor;
      case 'critica':
        return AppTheme.errorColor;
      default:
        return AppTheme.getTextPrimaryColor(context);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final d = dateTime.day;
    final m = months[dateTime.month - 1];
    final y = dateTime.year;
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$d de $m de $y a las $h:$min';
  }

  Widget _buildMessageContentSection({
    required BuildContext context,
    required double pad,
    required double gapS,
    required double gapM,
  }) {
    final size = MediaQuery.of(context).size;

    return _Section(
      title: 'Contenido del mensaje',
      pad: pad,
      gapM: gapM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledBlock(
            label: 'Título',
            pad: pad,
            child: Text(
              widget.draft.titulo,
              style: AppTheme.getBodyLarge(size).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: gapM),
          _LabeledBlock(
            label: 'Mensaje',
            pad: pad,
            child: Text(
              widget.draft.mensaje,
              style: AppTheme.getBodyMedium(size).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Widgets minimalistas (sin íconos)
// =========================

class _HeaderSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final double pad;
  final double gapS;
  final double gapM;
  final Color accentColor;

  const _HeaderSummary({
    required this.title,
    required this.subtitle,
    required this.pad,
    required this.gapS,
    required this.gapM,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final border = AppTheme.getBorderColor(context).withOpacity(0.35);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(size)),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra sutil superior como acento
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: gapM),
          Text(
            title,
            style: AppTheme.getH2(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: gapS),
          Text(
            subtitle,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final double pad;
  final double gapM;

  const _Section({
    required this.title,
    required this.child,
    required this.pad,
    required this.gapM,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final border = AppTheme.getBorderColor(context).withOpacity(0.35);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad * 0.8),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título simple (sin icono)
          Text(
            title,
            style: AppTheme.getBodyLarge(size).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: gapM),
          child,
        ],
      ),
    );
  }
}

class _LabeledBlock extends StatelessWidget {
  final String label;
  final Widget child;
  final double pad;

  const _LabeledBlock({
    required this.label,
    required this.child,
    required this.pad,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final border = AppTheme.getBorderColor(context).withOpacity(0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: pad * 0.2),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(pad * 0.6),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double pad;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.pad,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final border = AppTheme.getBorderColor(context).withOpacity(0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: pad * 0.2),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(pad * 0.6),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
            border: Border.all(color: border),
          ),
          child: Text(
            value,
            style: AppTheme.getBodyMedium(size).copyWith(
              color: valueColor ?? AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipientBlock extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final double pad;

  const _RecipientBlock({
    required this.label,
    required this.children,
    required this.pad,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(size).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: pad * 0.35),
        Wrap(
          spacing: pad * 0.35,
          runSpacing: pad * 0.35,
          children: children,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pad = size.width * 0.045;
    final base = AppTheme.getTextPrimaryColor(context);
    final bg = base.withOpacity(0.06);
    final border = base.withOpacity(0.18);

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: pad * 0.6, vertical: pad * 0.33),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(size)),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.getCaptionSmall(size).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoaderLine extends StatelessWidget {
  const _LoaderLine();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final base = AppTheme.getBorderColor(context).withOpacity(0.35);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(size)),
      child: LinearProgressIndicator(
        minHeight: 4,
        color: AppTheme.accentPurple,
        backgroundColor: base,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double pad;
  final double gapM;
  final VoidCallback onConfirm;

  const _BottomBar({
    required this.pad,
    required this.gapM,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        border: Border(
          top: BorderSide(
            color: AppTheme.getBorderColor(context).withOpacity(0.4),
          ),
        ),
      ),
      padding: EdgeInsets.all(pad),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Aviso discreto (texto únicamente)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(pad * 0.55),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(size),
                ),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.25),
                ),
              ),
              child: Text(
                'Una vez enviado, el mensaje no podrá modificarse ni cancelarse.',
                style: AppTheme.getCaptionSmall(size).copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: gapM),
            // Confirmar y enviar
            SizedBox(
              width: double.infinity,
              child: SolidButton(
                label: 'Confirmar y enviar',
                onPressed: onConfirm,
                screenSize: size,
                backgroundColor: AppTheme.accentPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
