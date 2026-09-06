import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alertaescolar/app/app_theme.dart';

class LegalCenterView extends StatelessWidget {
  const LegalCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Información legal',
            style: TextStyle(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              fontSize: size.width * 0.045,
            ),
          ),
          backgroundColor: AppTheme.getSurfaceColor(context),
          foregroundColor: AppTheme.getTextPrimaryColor(context),
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          bottom: TabBar(
            labelColor: AppTheme.getTextPrimaryColor(context),
            unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
            indicatorColor: AppTheme.accentPurple,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: size.width * 0.038,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: size.width * 0.038,
            ),
            tabs: const [
              Tab(text: 'Privacidad'),
              Tab(text: 'Términos'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            _PrivacyContent(),
            _TermsContent(),
          ],
        ),
      ),
    );
  }
}

// ———————————————————————————— PRIVACIDAD ————————————————————————————

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(size),
        vertical: AppTheme.getLargePadding(size),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meta
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(size)),
            child: Row(
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
    );
  }
}

// ————————————————————————————— TÉRMINOS —————————————————————————————

class _TermsContent extends StatelessWidget {
  const _TermsContent();

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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getMediumPadding(size),
        vertical: AppTheme.getLargePadding(size),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meta
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getSmallPadding(size)),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
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
            'Aceptación de términos',
            [
              'Al acceder o utilizar la aplicación, aceptas cumplir estos Términos y Condiciones. Si no estás de acuerdo, por favor no uses la aplicación.',
            ],
          ),

          Divider(
            height: 32,
            thickness: 1,
            // ignore: deprecated_member_use
            color: AppTheme.getBorderColor(context).withOpacity(0.6),
          ),

          section(
            'Uso de la aplicación',
            [
              'Debes utilizar la aplicación de forma responsable y conforme a la ley. Nos reservamos el derecho de suspender o restringir cuentas que infrinjan estos términos.',
            ],
            bullets: [
              'No intentes vulnerar la seguridad del sistema.',
              'No uses la app con fines fraudulentos.',
              'Respeta la privacidad y los datos de otras personas.',
            ],
          ),

          Divider(
            height: 32,
            thickness: 1,
            // ignore: deprecated_member_use
            color: AppTheme.getBorderColor(context).withOpacity(0.6),
          ),

          section(
            'Cuentas y seguridad',
            [
              'Eres responsable de mantener la seguridad de tu cuenta y del uso de tus credenciales. Notifícanos inmediatamente si detectas usos no autorizados.',
            ],
          ),

          Divider(
            height: 32,
            thickness: 1,
            // ignore: deprecated_member_use
            color: AppTheme.getBorderColor(context).withOpacity(0.6),
          ),

          section(
            'Contenido y propiedad',
            [
              'Los contenidos, marcas y logotipos relacionados con la aplicación pueden estar protegidos por derechos de autor y otras leyes. No puedes utilizarlos sin autorización.',
            ],
          ),

          Divider(
            height: 32,
            thickness: 1,
            // ignore: deprecated_member_use
            color: AppTheme.getBorderColor(context).withOpacity(0.6),
          ),

          section(
            'Limitación de responsabilidad',
            [
              'La aplicación se proporciona “tal cual”. No garantizamos disponibilidad ininterrumpida ni ausencia total de errores. En la medida que lo permita la ley, no seremos responsables por daños indirectos o consecuenciales.',
            ],
          ),

          Divider(
            height: 32,
            thickness: 1,
            // ignore: deprecated_member_use
            color: AppTheme.getBorderColor(context).withOpacity(0.6),
          ),

          section(
            'Cambios a estos términos',
            [
              'Podemos modificar estos términos para reflejar cambios legales o mejoras del servicio. Publicaremos la versión vigente y su fecha de actualización.',
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
                  'Para dudas legales o soporte, escríbenos a alertaescolar.team@gmail.com.',
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
    );
  }
}
