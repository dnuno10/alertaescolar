import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../models/comunicado.dart';
import '../../../models/grupo.dart';
import '../../../models/turno.dart';
import '../../../managers/user_provider.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../components/headers/nav_header.dart';
import '../../../components/buttons/solid_button.dart';
import '../../../components/buttons/custom_outline_button.dart';
import '../../../components/loading_dialog.dart';

class NotificationReviewView extends StatefulWidget {
  final String tipoMensaje;
  final String tipoDestinatario;
  final String titulo;
  final String mensaje;
  final TipoComunicado? tipoComunicado;
  final PrioridadComunicado? prioridadComunicado;
  final Map<String, dynamic>? selectedStudent;
  final List<Grupo> selectedGroups;
  final Turno? selectedShift;

  const NotificationReviewView({
    super.key,
    required this.tipoMensaje,
    required this.tipoDestinatario,
    required this.titulo,
    required this.mensaje,
    this.tipoComunicado,
    this.prioridadComunicado,
    this.selectedStudent,
    required this.selectedGroups,
    this.selectedShift,
  });

  @override
  State<NotificationReviewView> createState() => _NotificationReviewViewState();
}

class _NotificationReviewViewState extends State<NotificationReviewView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            NavHeader(
              title: 'Revisar Mensaje',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header de confirmación
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentPurple.withOpacity(0.1),
                            AppTheme.accentBlue.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            AppTheme.getLargeRadius(screenSize)),
                        border: Border.all(
                          color: AppTheme.accentPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            widget.tipoMensaje == 'permiso'
                                ? Icons.assignment_turned_in_rounded
                                : Icons.campaign_rounded,
                            color: widget.tipoMensaje == 'permiso'
                                ? AppTheme.accentBlue
                                : AppTheme.warningColor,
                            size: screenSize.height * 0.06,
                          ),
                          SizedBox(
                              height: AppTheme.getMediumPadding(screenSize)),
                          Text(
                            widget.tipoMensaje == 'permiso'
                                ? 'Permiso Especial'
                                : 'Comunicado Oficial',
                            style: AppTheme.getH2(screenSize).copyWith(
                              color: AppTheme.getTextPrimaryColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            'Revisa cuidadosamente toda la información antes de continuar',
                            style: AppTheme.getBodyMedium(screenSize).copyWith(
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize)),

                    // Contenido del mensaje
                    _buildMessageContentSection(
                      context: context,
                      screenSize: screenSize,
                    ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // Información específica de comunicado
                    if (widget.tipoMensaje == 'comunicado') ...[
                      _buildSection(
                        context: context,
                        screenSize: screenSize,
                        title: 'Detalles del Comunicado',
                        icon: Icons.info_rounded,
                        iconColor: AppTheme.warningColor,
                        children: [
                          _buildInfoRow(
                            context: context,
                            screenSize: screenSize,
                            label: 'Tipo:',
                            value:
                                _getComunicadoTypeText(widget.tipoComunicado!),
                          ),
                          SizedBox(
                              height: AppTheme.getSmallPadding(screenSize)),
                          _buildInfoRow(
                            context: context,
                            screenSize: screenSize,
                            label: 'Prioridad:',
                            value:
                                _getPriorityText(widget.prioridadComunicado!),
                            valueColor:
                                _getPriorityColor(widget.prioridadComunicado!),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.getMediumPadding(screenSize)),
                    ],

                    // Destinatarios
                    _buildSection(
                      context: context,
                      screenSize: screenSize,
                      title: 'Destinatarios',
                      icon: Icons.people_rounded,
                      iconColor: AppTheme.accentPurple,
                      children: [
                        _buildRecipientInfo(context, screenSize),
                      ],
                    ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // Información de envío
                    _buildSection(
                      context: context,
                      screenSize: screenSize,
                      title: 'Información de Envío',
                      icon: Icons.send_rounded,
                      iconColor: AppTheme.accentOrange,
                      children: [
                        _buildInfoRow(
                          context: context,
                          screenSize: screenSize,
                          label: 'Fecha y hora:',
                          value: _formatDateTime(DateTime.now()),
                        ),
                        SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                        _buildInfoRow(
                          context: context,
                          screenSize: screenSize,
                          label: 'Método:',
                          value: 'Notificación push inmediata',
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.getLargePadding(screenSize) * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Advertencia
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppTheme.warningColor,
                      size: screenSize.height * 0.02,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Expanded(
                      child: Text(
                        'Una vez enviado, el mensaje no podrá ser modificado ni cancelado.',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: CustomOutlineButton(
                      color: AppTheme.getTextSecondaryColor(context),
                      label: 'Modificar',
                      icon: Icons.edit_rounded,
                      onPressed: () => Navigator.pop(context),
                      screenSize: screenSize,
                    ),
                  ),
                  SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                  Expanded(
                    flex: 2,
                    child: SolidButton(
                      label: 'Confirmar y Enviar',
                      icon: Icons.send_rounded,
                      onPressed: _sendNotification,
                      screenSize: screenSize,
                      backgroundColor: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required Size screenSize,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required Size screenSize,
    required String label,
    required String value,
    Color? valueColor,
    bool isTitle = false,
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: (isTitle
                    ? AppTheme.getBodyLarge(screenSize)
                    : AppTheme.getBodyMedium(screenSize))
                .copyWith(
              color: valueColor ?? AppTheme.getTextPrimaryColor(context),
              fontWeight: isTitle ? FontWeight.w700 : FontWeight.w500,
              height: isMultiline ? 1.4 : null,
            ),
            maxLines: isMultiline ? null : 3,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientInfo(BuildContext context, Size screenSize) {
    List<Widget> recipientCards = [];

    switch (widget.tipoDestinatario) {
      case 'individual':
        if (widget.selectedStudent != null) {
          recipientCards.add(
              _buildStudentCard(context, screenSize, widget.selectedStudent!));
        } else {
          recipientCards.add(_buildEmptyRecipientCard(
              context, screenSize, 'No se ha seleccionado ningún estudiante'));
        }
        break;

      case 'grupo':
        if (widget.selectedGroups.isNotEmpty) {
          recipientCards.addAll(widget.selectedGroups
              .map((grupo) => _buildGroupCard(context, screenSize, grupo))
              .toList());
        } else {
          recipientCards.add(_buildEmptyRecipientCard(
              context, screenSize, 'No se han seleccionado grupos'));
        }
        break;

      case 'turno':
        if (widget.selectedShift != null) {
          recipientCards
              .add(_buildShiftCard(context, screenSize, widget.selectedShift!));
        } else {
          recipientCards.add(_buildEmptyRecipientCard(
              context, screenSize, 'No se ha seleccionado ningún turno'));
        }
        break;

      case 'todos':
        recipientCards.add(_buildAllStudentsCard(context, screenSize));
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjetas de destinatarios (sin subtítulo redundante)
        ...recipientCards
            .map((card) => Padding(
                  padding: EdgeInsets.only(
                      bottom: AppTheme.getSmallPadding(screenSize)),
                  child: card,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildStudentCard(
      BuildContext context, Size screenSize, Map<String, dynamic> student) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del estudiante
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.accentBlue,
              size: screenSize.height * 0.03,
            ),
          ),

          SizedBox(width: AppTheme.getMediumPadding(screenSize)),

          // Información del estudiante
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student['name'] ?? 'Nombre no disponible',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),

                // Matrícula
                Row(
                  children: [
                    Text(
                      'Matrícula: ',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        student['matricula'] ?? 'N/A',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.2),

                // Grupo
                Row(
                  children: [
                    Text(
                      'Grupo: ',
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${student['nivelEducativo'] ?? ''} - ${student['group'] ?? 'N/A'}',
                        style: AppTheme.getCaptionSmall(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: AppTheme.getSmallPadding(screenSize)),

          // Estado
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize),
              vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
            ),
            decoration: BoxDecoration(
              color: (student['active'] == true
                      ? AppTheme.successColor
                      : AppTheme.errorColor)
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Text(
              student['status'] ?? 'Desconocido',
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: student['active'] == true
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Size screenSize, Grupo grupo) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentOrange.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.class_rounded,
              color: AppTheme.accentOrange,
              size: screenSize.height * 0.025,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${grupo.nivelEducativo} - ${grupo.grupo}',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  'Nivel: ${grupo.nivelEducativo}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, Size screenSize, Turno turno) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: AppTheme.warningColor,
              size: screenSize.height * 0.025,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  turno.turno,
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  'Horario: ${turno.horaInicio} - ${turno.horaFin}',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStudentsCard(BuildContext context, Size screenSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.accentPurple.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppTheme.accentPurple,
              size: screenSize.height * 0.025,
            ),
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Toda la Institución Educativa',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.3),
                Text(
                  'El mensaje se enviará a todos los estudiantes registrados',
                  style: AppTheme.getCaptionSmall(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecipientCard(
      BuildContext context, Size screenSize, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            color: AppTheme.errorColor,
            size: screenSize.height * 0.025,
          ),
          SizedBox(width: AppTheme.getMediumPadding(screenSize)),
          Expanded(
            child: Text(
              message,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _sendNotification() async {
    // Mostrar loading dialog
    LoadingDialog.show(context,
        message:
            'Enviando ${widget.tipoMensaje == 'permiso' ? 'permiso especial' : 'comunicado'}...');

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        LoadingDialog.hide(context);
        throw Exception('Usuario no autenticado');
      }

      final adminId = currentUser.id;
      final escuelaId = currentUser.escuelaId!;

      // Preparar datos para el envío
      String? studentId;
      List<String>? groupIds;
      String? turnoId;

      switch (widget.tipoDestinatario) {
        case 'individual':
          studentId = widget.selectedStudent?['id'];
          break;
        case 'grupo':
          groupIds = widget.selectedGroups.map((grupo) => grupo.id).toList();
          break;
        case 'turno':
          turnoId = widget.selectedShift?.id;
          break;
        case 'todos':
          // No se necesitan parámetros adicionales
          break;
      }

      // Enviar notificaciones
      final result = await NotificationService.sendNotifications(
        adminId: adminId,
        escuelaId: escuelaId,
        titulo: widget.titulo,
        mensaje: widget.mensaje,
        tipoMensaje: widget.tipoMensaje,
        tipoDestinatario: widget.tipoDestinatario,
        studentId: studentId,
        groupIds: groupIds,
        turnoId: turnoId,
        tipoComunicado: widget.tipoComunicado,
        prioridadComunicado: widget.prioridadComunicado,
      );

      // Ocultar loading dialog
      LoadingDialog.hide(context);

      if (result['success']) {
        // Mostrar diálogo de éxito y regresar a la vista principal
        _showSuccessDialog(context, result);
      } else {
        CustomSnackBar.show(
          context: context,
          message: result['message'],
          isError: true,
        );
      }
    } catch (e) {
      // Ocultar loading dialog en caso de error
      LoadingDialog.hide(context);

      CustomSnackBar.show(
        context: context,
        message: 'Error al enviar notificación: $e',
        isError: true,
      );
    }
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    final screenSize = MediaQuery.of(context).size;
    final notificationsSent = result['notificationsSent'] as int? ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        ),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius:
                BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de éxito
              Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getLargeRadius(screenSize)),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successColor,
                  size: screenSize.height * 0.08,
                ),
              ),

              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              Text(
                '¡Mensaje Enviado!',
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.getSmallPadding(screenSize)),

              Text(
                'Tu ${widget.tipoMensaje == 'permiso' ? 'permiso especial' : 'comunicado'} ha sido enviado exitosamente a $notificationsSent ${notificationsSent == 1 ? 'estudiante' : 'estudiantes'}.',
                style: AppTheme.getBodyMedium(screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.getLargePadding(screenSize)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Regresar a NotificationSendView
                    Navigator.pop(context); // Regresar a la vista principal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.getMediumPadding(screenSize),
                    ),
                  ),
                  child: Text(
                    'Finalizar',
                    style: AppTheme.getBodyMedium(screenSize).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  String _getComunicadoTypeText(TipoComunicado tipo) {
    switch (tipo) {
      case TipoComunicado.emergencia:
        return 'Emergencia';
      case TipoComunicado.paseo:
        return 'Paseo';
      case TipoComunicado.evento:
        return 'Evento';
      case TipoComunicado.recordatorioPago:
        return 'Recordatorio de Pago';
      case TipoComunicado.citatorio:
        return 'Citatorio';
      case TipoComunicado.informativo:
        return 'Informativo';
      case TipoComunicado.celebracion:
        return 'Celebración';
      case TipoComunicado.suspencionClases:
        return 'Suspensión de Clases';
      case TipoComunicado.cambioHorario:
        return 'Cambio de Horario';
    }
  }

  String _getPriorityText(PrioridadComunicado prioridad) {
    switch (prioridad) {
      case PrioridadComunicado.baja:
        return 'Baja';
      case PrioridadComunicado.media:
        return 'Media';
      case PrioridadComunicado.alta:
        return 'Alta';
      case PrioridadComunicado.critica:
        return 'Crítica';
    }
  }

  Color _getPriorityColor(PrioridadComunicado prioridad) {
    switch (prioridad) {
      case PrioridadComunicado.baja:
        return AppTheme.successColor;
      case PrioridadComunicado.media:
        return AppTheme.accentOrange;
      case PrioridadComunicado.alta:
        return AppTheme.warningColor;
      case PrioridadComunicado.critica:
        return AppTheme.errorColor;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
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

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day de $month de $year a las $hour:$minute';
  }

  Widget _buildMessageContentSection({
    required BuildContext context,
    required Size screenSize,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context).withOpacity(0.3),
        ),
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
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.getLargeRadius(screenSize)),
                topRight: Radius.circular(AppTheme.getLargeRadius(screenSize)),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getSmallPadding(screenSize) * 0.8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(screenSize)),
                  ),
                  child: Icon(
                    Icons.message_rounded,
                    color: AppTheme.accentBlue,
                    size: screenSize.height * 0.025,
                  ),
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Text(
                  'Contenido del Mensaje',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.title_rounded,
                            color: AppTheme.accentBlue,
                            size: screenSize.height * 0.02,
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            'Título',
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        widget.titulo,
                        style: AppTheme.getBodyLarge(screenSize).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                // Mensaje
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(
                        AppTheme.getMediumRadius(screenSize)),
                    border: Border.all(
                      color: AppTheme.getBorderColor(context).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_rounded,
                            color: AppTheme.getTextSecondaryColor(context),
                            size: screenSize.height * 0.02,
                          ),
                          SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                          Text(
                            'Mensaje',
                            style:
                                AppTheme.getCaptionSmall(screenSize).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                      Text(
                        widget.mensaje,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
