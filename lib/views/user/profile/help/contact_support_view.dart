import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';

class ContactSupportView extends StatelessWidget {
  const ContactSupportView({super.key});

  static const _instagramUser = 'alertaescolar.app';
  static const _whatsNumberIntl = '526645290620';
  static const _whatsDisplay = '+52 664 529 0620';
  static const _email = 'alertaescolar.team@gmail.com';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.maybeOf(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Contacto y soporte',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
            fontSize: screenSize.width * 0.045,
          ),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextPrimaryColor(context),
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        children: [
          // Header con descripción
          Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppTheme.accentPurple,
                  size: screenSize.width * 0.07,
                ),
                SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Necesitas ayuda?',
                        style: AppTheme.getSubtitle1(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                          height: AppTheme.getSmallPadding(screenSize) * 0.3),
                      Text(
                        'Contacta con nuestro equipo de soporte',
                        style: AppTheme.getCaption(screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Canales de contacto
          Text(
            'Canales de contacto',
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          _ChannelCard(
            screenSize: screenSize,
            icon: Icons.photo_camera_outlined,
            title: 'Instagram',
            subtitle: '@$_instagramUser',
            primaryActionLabel: 'Abrir',
            onPrimaryAction: _openInstagram,
            secondaryActionLabel: 'Copiar',
            onSecondaryAction: () => _copyToClipboard(
              context,
              '@$_instagramUser',
              'Copiado al portapapeles',
            ),
            context: context,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _ChannelCard(
            screenSize: screenSize,
            icon: FontAwesomeIcons.whatsapp,
            title: 'WhatsApp',
            subtitle: _whatsDisplay,
            primaryActionLabel: l10n?.send ?? 'Enviar',
            onPrimaryAction: () => _openWhatsApp(
              message: 'Hola, me gustaría obtener soporte de Alerta Escolar.',
            ),
            secondaryActionLabel: 'Copiar',
            onSecondaryAction: () => _copyToClipboard(
              context,
              _whatsDisplay,
              'Copiado al portapapeles',
            ),
            context: context,
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          _ChannelCard(
            screenSize: screenSize,
            icon: Icons.alternate_email_outlined,
            title: l10n?.email ?? 'Correo electrónico',
            subtitle: _email,
            primaryActionLabel: l10n?.sendEmail ?? 'Enviar correo',
            onPrimaryAction: () => _sendEmail(
              subject: 'Soporte - Alerta Escolar',
              body: 'Hola,\n\nMe gustaría recibir ayuda con...\n\nGracias.',
            ),
            secondaryActionLabel: 'Copiar',
            onSecondaryAction: () => _copyToClipboard(
              context,
              _email,
              'Copiado al portapapeles',
            ),
            context: context,
          ),
          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Footer con horarios
          Container(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppTheme.accentPurple,
                      size: screenSize.width * 0.05,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize)),
                    Text(
                      'Horarios de atención',
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Text(
                  'Lunes a Viernes: 8:00 AM - 6:00 PM\nSábados: 9:00 AM - 2:00 PM',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ——————————— Helpers de acciones ———————————

  static Future<void> _openInstagram() async {
    final appUri = Uri.parse('instagram://user?username=$_instagramUser');
    final webUri = Uri.parse('https://instagram.com/$_instagramUser');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _openWhatsApp({required String message}) async {
    final encoded = Uri.encodeComponent(message);
    final appUri =
        Uri.parse('whatsapp://send?phone=$_whatsNumberIntl&text=$encoded');
    final webUri = Uri.parse('https://wa.me/$_whatsNumberIntl?text=$encoded');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _sendEmail({
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    await launchUrl(uri);
  }

  static Future<void> _copyToClipboard(
      BuildContext context, String text, String snackMsg) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackMsg)),
      );
    }
  }
}

// ——————————— UI card ———————————

class _ChannelCard extends StatelessWidget {
  final Size screenSize;
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  final BuildContext context;

  const _ChannelCard({
    required this.screenSize,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.accentPurple,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                        height: AppTheme.getSmallPadding(screenSize) * 0.3),
                    Text(
                      subtitle,
                      style: AppTheme.getCaption(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel),
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
