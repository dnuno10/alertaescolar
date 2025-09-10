import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ContactInfoCard extends StatelessWidget {
  final Size screenSize;

  const ContactInfoCard({
    super.key,
    required this.screenSize,
  });

  static const String _email = 'contacto@alertaescolar.com';
  static const String _phoneDisplay = '+52-664-529-0620';
  static const String _phoneTel = '+526645290620'; // para tel: URI

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header simplificado sin icono decorativo
          Text(
            l10n.needScheduleChanges,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          Text(
            l10n.scheduleChangesDescription,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.5,
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Contactos minimalistas en columna
          Column(
            children: [
              _MinimalContactItem(
                icon: Icons.email_outlined,
                label: _email,
                color: AppTheme.accentBlue,
                screenSize: screenSize,
                onTap: () => _launchEmail(context),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              _MinimalContactItem(
                icon: Icons.phone_outlined,
                label: _phoneDisplay,
                color: AppTheme.successColor,
                screenSize: screenSize,
                onTap: () => _launchPhone(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================
  // Acciones: abrir mail y teléfono
  // ======================================
  Future<void> _launchEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      // Puedes añadir asunto/cuerpo si lo deseas:
      // queryParameters: {'subject': 'Soporte – Alerta Escolar'},
    );

    final ok = await _tryLaunch(uri);
    if (!ok && context.mounted) {
      _showContactDialog(
        context,
        title: l10n.contactVia(l10n.email),
        value: _email,
        actionLabel: l10n.email,
        onAction: () => _tryLaunch(uri),
      );
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri(scheme: 'tel', path: _phoneTel);

    final ok = await _tryLaunch(uri);
    if (!ok && context.mounted) {
      _showContactDialog(
        context,
        title: l10n.contactVia(l10n.phone),
        value: _phoneDisplay,
        actionLabel: l10n.phone,
        onAction: () => _tryLaunch(uri),
      );
    }
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // ======================================
  // Diálogo minimalista (fallback / copiar)
  // ======================================
  void _showContactDialog(
    BuildContext context, {
    required String title,
    required String value,
    required String actionLabel,
    required Future<bool> Function() onAction,
  }) {
    final size = MediaQuery.of(context).size;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Cerrar',
      barrierDismissible: true,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Dialog(
            elevation: 0,
            backgroundColor: AppTheme.getCardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.getMediumRadius(size)),
              side:
                  BorderSide(color: AppTheme.getBorderColor(context), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getSubtitle1(size).copyWith(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppTheme.getSmallPadding(size)),
                  SelectableText(
                    value,
                    style: AppTheme.getBodyMedium(size).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.getMediumPadding(size)),
                  Row(
                    children: [
                      // Acción principal (abrir email / teléfono)
                      TextButton(
                        onPressed: () async {
                          final ok = await onAction();
                          if (context.mounted) Navigator.pop(context);
                          if (!ok && context.mounted) {
                            _showSnack(
                                context, 'No se pudo abrir la aplicación.');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getMediumPadding(size),
                            vertical: AppTheme.getSmallPadding(size) * 0.8,
                          ),
                          foregroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.getLargeRadius(size)),
                            side: BorderSide(
                                color: AppTheme.getBorderColor(context),
                                width: 1),
                          ),
                        ),
                        child: Text('Abrir $actionLabel'),
                      ),
                      SizedBox(width: AppTheme.getSmallPadding(size)),
                      // Copiar al portapapeles
                      TextButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: value));
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSnack(context, 'Copiado al portapapeles');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getMediumPadding(size),
                            vertical: AppTheme.getSmallPadding(size) * 0.8,
                          ),
                          foregroundColor:
                              AppTheme.getTextPrimaryColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.getLargeRadius(size)),
                            side: BorderSide(
                                color: AppTheme.getBorderColor(context),
                                width: 1),
                          ),
                        ),
                        child: const Text('Copiar'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.getTextPrimaryColor(context),
        content: Text(
          msg,
          style: AppTheme.getCaptionSmall(MediaQuery.of(context).size).copyWith(
            color: AppTheme.getBackgroundColor(context),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Widget minimalista para contacto - solo icono y texto
class _MinimalContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Size screenSize;
  final VoidCallback onTap;

  const _MinimalContactItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final rad = AppTheme.getSmallRadius(screenSize);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rad),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: padS,
          vertical: padS * 0.8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.20),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(rad),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: screenSize.width * 0.045,
            ),
            SizedBox(width: padS),
            Flexible(
              child: Text(
                label,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
