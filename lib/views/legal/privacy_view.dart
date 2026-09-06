import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/app/app_theme.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget bullet(String text) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppTheme.getSmallPadding(size)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: size.height * 0.007,
                right: AppTheme.getSmallPadding(size),
              ),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: AppTheme.getBodyMedium(size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget section(String title, List<String> paragraphs,
        {List<String>? bullets}) {
      return Padding(
        padding:
            EdgeInsets.symmetric(vertical: AppTheme.getMediumPadding(size)),
        child: Column(
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
            ...paragraphs.map(
              (p) => Padding(
                padding:
                    EdgeInsets.only(bottom: AppTheme.getSmallPadding(size)),
                child: Text(
                  p,
                  style: AppTheme.getBodyMedium(size).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (bullets != null && bullets.isNotEmpty) ...[
              SizedBox(height: AppTheme.getSmallPadding(size) * 0.5),
              ...bullets.map(bullet),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Política de Privacidad',
          style: AppTheme.getAppBarTitle(size),
        ),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Container(
        color: AppTheme.getBackgroundColor(context),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(size),
            vertical: AppTheme.getLargePadding(size),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: size.height * 0.022,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  SizedBox(width: AppTheme.getSmallPadding(size)),
                  Text(
                    'Última actualización: 01/2025',
                    style: AppTheme.getCaptionSmall(size).copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.getLargePadding(size)),
              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              // Secciones
              section(
                'Información que recopilamos',
                [
                  'Recopilamos información para ofrecerte un servicio seguro y personalizado. Esto incluye datos que nos proporcionas directamente y datos que se generan al usar la aplicación.',
                ],
                bullets: [
                  'Datos de cuenta (correo electrónico, nombre y apellidos si decides proporcionarlos).',
                  'Datos de uso (pantallas visitadas, acciones básicas dentro de la app).',
                  'Identificadores del dispositivo para notificaciones (token de notificaciones).',
                ],
              ),

              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              section(
                'Cómo usamos tu información',
                [
                  'Utilizamos la información para autenticarte, enviarte notificaciones relevantes (por ejemplo, asistencia o comunicados), mejorar la experiencia de usuario y garantizar la seguridad de tu cuenta.',
                ],
              ),

              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              section(
                'Compartición y terceros',
                [
                  'No vendemos tu información. Podemos compartir datos estrictamente necesarios con proveedores que nos ayudan a operar la app (por ejemplo, servicios de autenticación, base de datos y notificaciones) bajo acuerdos de confidencialidad.',
                ],
              ),

              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              section(
                'Seguridad',
                [
                  'Aplicamos medidas técnicas y organizativas para proteger tus datos. Aun así, ningún sistema es 100% infalible. Te recomendamos mantener tus dispositivos actualizados y proteger el acceso a tu cuenta.',
                ],
              ),

              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              section(
                'Tus derechos',
                [
                  'Puedes solicitar acceso, rectificación o eliminación de tus datos, así como limitar u oponerte a ciertos tratamientos, dentro de lo permitido por la ley aplicable.',
                ],
              ),

              Divider(
                height: 32,
                thickness: 1,
                // ignore: deprecated_member_use
                color: AppTheme.getBorderColor(context).withOpacity(0.6),
              ),

              section(
                'Cambios a esta política',
                [
                  'Podemos actualizar esta política para reflejar cambios legales o mejoras del servicio. Publicaremos la versión vigente y la fecha de actualización en esta misma pantalla.',
                ],
              ),

              SizedBox(height: AppTheme.getLargePadding(size)),

              // Caja de contacto
              Container(
                padding: EdgeInsets.all(AppTheme.getMediumPadding(size)),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                    AppTheme.getMediumRadius(size),
                  ),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contáctanos',
                      style: AppTheme.getSubtitle1(size).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(size) * 0.8),
                    Text(
                      'Si tienes dudas sobre esta política o deseas ejercer tus derechos, escríbenos a alertaescolar.team@gmail.com.',
                      style: AppTheme.getBodyMedium(size).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.getLargePadding(size)),
            ],
          ),
        ),
      ),
    );
  }
}
