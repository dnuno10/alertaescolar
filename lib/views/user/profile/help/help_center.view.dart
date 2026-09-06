import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Asegura que el usuario esté cargado para detectar el rol
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = context.read<UserProvider>();
      if (!up.isLoadingUser && up.currentUser == null) {
        up.loadCurrentUser(context, showDialog: false);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.maybeOf(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          l10n?.helpCenter ?? 'Centro de ayuda',
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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final isLoading =
              userProvider.isLoadingUser && userProvider.currentUser == null;
          final isAdmin = userProvider.isAdmin();

          // Datos por rol
          final videos = isAdmin ? _adminVideos : _userVideos;
          final faqs = isAdmin ? _adminFaqs : _userFaqs;

          // Filtros por query
          final filteredVideos = _filterVideos(videos, _query);
          final filteredFaqs = _filterFaqs(faqs, _query);

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (!isAdmin)
                Padding(
                  padding:
                      EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppTheme.accentPurple,
                        size: screenSize.width * 0.07,
                      ),
                      SizedBox(width: AppTheme.getMediumPadding(screenSize)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Cómo podemos ayudarte?',
                              style: AppTheme.getSubtitle1(screenSize).copyWith(
                                color: AppTheme.getTextPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                                height:
                                    AppTheme.getSmallPadding(screenSize) * 0.3),
                            Text(
                              'Encuentra respuestas a tus preguntas',
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

              // Buscador (filtra VIDEOS y FAQ)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(screenSize),
                ),
                child: _SearchField(
                  controller: _searchCtrl,
                  hintText: 'Buscar en videos y preguntas frecuentes...',
                  onChanged: (text) => setState(() => _query = text.trim()),
                  screenSize: screenSize,
                ),
              ),
              SizedBox(height: AppTheme.getMediumPadding(screenSize)),

              // Contenido scrollable
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.getMediumPadding(screenSize),
                    vertical: AppTheme.getSmallPadding(screenSize),
                  ),
                  children: [
                    // ———— Sección de VIDEOS por rol ————
                    _SectionHeader(
                      label: isAdmin
                          ? 'Videos recomendados para Administrador'
                          : 'Videos recomendados para Padres',
                      count: filteredVideos.length,
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    if (filteredVideos.isEmpty)
                      _EmptyState(
                        message: 'Sin videos para “$_query”',
                        screenSize: screenSize,
                      )
                    else
                      ...filteredVideos.map(
                        (v) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppTheme.getSmallPadding(screenSize),
                          ),
                          child: _VideoTile(
                            title: v.title,
                            url: v.url,
                            screenSize: screenSize,
                          ),
                        ),
                      ),

                    SizedBox(height: AppTheme.getMediumPadding(screenSize)),

                    // ———— Sección de FAQ por rol ————
                    _SectionHeader(
                      label: isAdmin ? 'FAQ Administrador' : 'FAQ Usuario',
                      count: filteredFaqs.length,
                      screenSize: screenSize,
                    ),
                    SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                    if (filteredFaqs.isEmpty)
                      _EmptyState(
                        message: 'Sin resultados en FAQ',
                        screenSize: screenSize,
                      )
                    else
                      ...filteredFaqs.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppTheme.getSmallPadding(screenSize),
                          ),
                          child: _FaqTile(
                            q: item.q,
                            a: item.a,
                            screenSize: screenSize,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ———————————————————— Navegación a YouTube ————————————————————
  Future<void> openYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ———————————————————— Filtros ————————————————————
  List<_FaqItem> _filterFaqs(List<_FaqItem> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((e) {
      return e.q.toLowerCase().contains(q) || e.a.toLowerCase().contains(q);
    }).toList();
  }

  List<_VideoItem> _filterVideos(List<_VideoItem> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.url.toLowerCase().contains(q);
    }).toList();
  }
}

// ———————————————————— UI helpers ————————————————————

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final Size screenSize;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
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
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.getBodyMedium(screenSize).copyWith(
          color: AppTheme.getTextPrimaryColor(context),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.accentPurple,
          ),
          hintText: hintText,
          hintStyle: AppTheme.getBodyMedium(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            vertical: AppTheme.getSmallPadding(screenSize),
            horizontal: AppTheme.getMediumPadding(screenSize),
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            borderSide: BorderSide(color: AppTheme.accentPurple, width: 2),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Size screenSize;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label ($count)',
      style: AppTheme.getSubtitle1(screenSize).copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.getTextPrimaryColor(context),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final String title;
  final String url;
  final Size screenSize;

  const _VideoTile({
    required this.title,
    required this.url,
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
          child: Icon(Icons.play_circle_fill,
              color: AppTheme.accentPurple, size: screenSize.width * 0.07),
        ),
        title: Text(
          title,
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
        onTap: () async {
          final state = context.findAncestorStateOfType<_HelpCenterViewState>();
          await state?.openYouTube(url);
        },
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String q;
  final String a;
  final Size screenSize;

  const _FaqTile({
    required this.q,
    required this.a,
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: AppTheme.getMediumPadding(screenSize),
            vertical: AppTheme.getSmallPadding(screenSize),
          ),
          iconColor: AppTheme.accentPurple,
          collapsedIconColor: AppTheme.getTextSecondaryColor(context),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          ),
          title: Text(
            q,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(screenSize),
              ),
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                border: Border.all(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 2,
                      right: AppTheme.getSmallPadding(screenSize),
                    ),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      a,
                      style: AppTheme.getBodyMedium(screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final Size screenSize;

  const _EmptyState({
    required this.message,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
              child: Icon(
                Icons.search_off,
                size: screenSize.width * 0.12,
                color: AppTheme.accentPurple,
              ),
            ),
            SizedBox(height: AppTheme.getMediumPadding(screenSize)),
            Text(
              message,
              style: AppTheme.getSubtitle1(screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              'Intenta con otros términos de búsqueda',
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ———————————————————— Datos ————————————————————

class _VideoItem {
  final String title;
  final String url;
  const _VideoItem(this.title, this.url);
}

// VIDEOS PARA ADMINISTRADORES (exactamente como los solicitaste)
const List<_VideoItem> _adminVideos = [
  _VideoItem(
    'Envío de notificaciones por escaneo en Alerta Escolar | Tutorial Administradores',
    'https://www.youtube.com/watch?v=1z95_3_rSME',
  ),
  _VideoItem(
    'Envía comunicados y avisos en Alerta Escolar | Tutorial Administradores',
    'https://www.youtube.com/watch?v=jBrpiiz35Us&t=8s',
  ),
  _VideoItem(
    'Configura tipos de acceso y tolerancia en Alerta Escolar | Tutorial Administradores',
    'https://www.youtube.com/watch?v=BjSboyY5L50',
  ),
  _VideoItem(
    'Funcionalidades complementarias del administrador en Alerta Escolar | Tutorial Administradores',
    'https://www.youtube.com/watch?v=gL9iRvWLcyY',
  ),
];

// VIDEOS PARA PADRES (exactamente como los solicitaste)
const List<_VideoItem> _userVideos = [
  _VideoItem(
    'Activa la credencial de tu hijo en Alerta Escolar | Tutorial Padres de Familia',
    'https://www.youtube.com/watch?v=tdH5ABk7a3E',
  ),
  _VideoItem(
    'Recibe notificaciones de acceso en Alerta Escolar | Tutorial Padres de Familia',
    'https://www.youtube.com/watch?v=MIFwUx-Q09Y',
  ),
  _VideoItem(
    'Consulta toda la información de tu hijo en Alerta Escolar | Tutorial Padres de Familia',
    'https://www.youtube.com/watch?v=3PblldrZbYQ',
  ),
  _VideoItem(
    'Registro e inicio de sesión en Alerta Escolar | Tutorial Padres de Familia',
    'https://www.youtube.com/watch?v=ar3HfPAIHQQ',
  ),
];

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem(this.q, this.a);
}

// ——— FAQ ADMIN ———
const List<_FaqItem> _adminFaqs = [
  _FaqItem('¿Cómo actualizo mis datos personales (nombre, correo, teléfono)?',
      'En Perfil > Datos Personales. Entras, editas los campos y guardas; si algo falta, el formulario lo resaltará.'),
  _FaqItem('¿Qué pasa si no se cargan mis datos al abrir el perfil?',
      'La app intenta cargarlos silenciosamente; arrastra hacia abajo (pull-to-refresh) para forzar actualización.'),
  _FaqItem('¿Cómo cambio el tema (claro/oscuro/sistema)?',
      'Perfil > Preferencias > Tema. Selecciona la opción y se aplica de inmediato.'),
  _FaqItem('¿Puedo personalizar el idioma de la interfaz?',
      'Sí. Perfil > Preferencias > Idioma; eliges y la app recarga textos.'),
  _FaqItem('¿Por qué no veo el botón de cerrar sesión a veces?',
      'Debes estar autenticado; si aparece un error de sesión caducada, reinicia la app o vuelve a iniciar sesión.'),
  _FaqItem('¿Cómo confirmo que realmente se cerró mi sesión?',
      'Tras cerrar sesión vuelves a la pantalla de acceso; si vuelves atrás y no ves datos privados, se completó.'),
  _FaqItem('¿Qué hago si pulso cerrar sesión y no pasa nada?',
      'Puede que el diálogo ya esté abierto; cierra otros modales y repite. Si persiste, reinicia la app.'),
  _FaqItem('¿Dónde veo el número de versión de la aplicación?',
      'Perfil > Ayuda > Sobre la aplicación (About). Allí aparece versión y links legales.'),
  _FaqItem('¿Cómo accedo a los términos y política de privacidad?',
      'Dentro de Sobre la aplicación encontrarás enlaces o botones a Términos y Privacidad.'),
  _FaqItem('¿Por qué algunas opciones muestran “Próximamente”?',
      'Son módulos en desarrollo (ej. Centro de Ayuda, Feedback). Indican que llegarán en futuras actualizaciones.'),
  _FaqItem(
      '¿Cómo reporto un error si el sistema de feedback aún no está disponible?',
      'Usa el correo de soporte indicado en Sobre la aplicación o el canal institucional definido.'),
  _FaqItem(
      '¿Puedo gestionar usuarios (padres, docentes, alumnos) desde mi perfil?',
      'No desde la sección Perfil; la gestión usualmente está en módulos de Administración/Usuarios.'),
  _FaqItem('¿Qué hago si los datos de un padre no coinciden?',
      'Edita en el módulo de Usuarios o solicita verificación documental según el flujo interno.'),
  _FaqItem('¿Cómo asigno un alumno a un curso o grupo?',
      'En la sección de Alumnos/Grupos: selecciona el alumno, elige “Asignar a grupo” y confirma.'),
  _FaqItem('¿Puedo desasignar un alumno de un grupo sin borrarlo?',
      'Sí, abre el detalle del alumno y usa la acción “Remover del grupo”.'),
  _FaqItem('¿Cómo activo o desactivo a un usuario?',
      'En listado de usuarios: entra al perfil y usa la opción de estado (Activo/Inactivo).'),
  _FaqItem('¿Qué implica desactivar a un usuario?',
      'No puede iniciar sesión ni recibir notificaciones, pero su historial permanece.'),
  _FaqItem('¿Cómo envío una alerta escolar urgente?',
      'Ve a Alertas > Nueva alerta > Selecciona categoría (ej. Seguridad) > Redacta > Define destinatarios > Enviar.'),
  _FaqItem('¿Cómo limito una alerta solo a un grado o grupo?',
      'En el formulario de alerta elige filtro por grupo/curso en Destinatarios antes de enviar.'),
  _FaqItem('¿Cómo saber si una alerta fue entregada?',
      'Revisa el estado en el historial de alertas: “Enviada”, “En progreso” o métricas de lectura (si habilitado).'),
  _FaqItem('¿Qué hago si envié una alerta con error?',
      'Si existe función de anulación, úsala. Si no, emite una segunda alerta aclaratoria.'),
  _FaqItem('¿Cómo gestiono categorías de alertas?',
      'En Configuración de Alertas: crear, renombrar o desactivar categorías según permisos.'),
  _FaqItem('¿Por qué un padre dice no recibir notificaciones?',
      'Verifica: a) Está activo, b) Tiene dispositivo registrado, c) Notificaciones habilitadas en su móvil, d) No está desasignado del grupo.'),
  _FaqItem('¿Cómo reviso el historial de comunicación con un usuario?',
      'En su detalle de usuario, apartado Historial o Comunicaciones (si disponible).'),
  _FaqItem('¿Cómo filtro alumnos por estado de asistencia?',
      'En el módulo de Asistencias aplica filtros (Fecha, Grupo, Estado: Presente/Ausente/Tarde).'),
  _FaqItem('¿Qué pasa si registro asistencia duplicada?',
      'La app normalmente ofrece edición; abre el registro y ajusta. Se guarda el último estado.'),
  _FaqItem('¿Cómo exporto listados (alumnos, asistencia)?',
      'Usa la opción Exportar (CSV/PDF) en la barra de acciones del módulo correspondiente.'),
  _FaqItem('¿Por qué no aparece la opción Exportar?',
      'Puede requerir rol superior o estar deshabilitada en tu versión.'),
  _FaqItem('¿Cómo restablezco contraseña a un usuario?',
      'Desde Gestión de Usuarios > selecciona usuario > “Restablecer contraseña” (envía correo o token).'),
  _FaqItem('¿Qué decir a un padre que olvidó su correo registrado?',
      'Validar su identidad y revisar en el listado interno; luego confirmarle el correo correcto.'),
  _FaqItem('¿Puedo forzar cambio de contraseña al próximo inicio?',
      'Sí, activa “Requerir cambio al inicio” en la configuración del usuario.'),
  _FaqItem('¿Cómo veo métricas de uso de la app?',
      'En el panel de Analíticas: sesiones, alertas enviadas, lecturas, participación.'),
  _FaqItem('¿Por qué mis métricas están vacías hoy?',
      'A veces se actualizan por lote; espera intervalo (ej. cada hora) o verifica conexión.'),
  _FaqItem('¿Cómo actualizar el logo o datos institucionales?',
      'Ajustes Institucionales > Identidad Visual > Subir logo / Editar datos.'),
  _FaqItem('¿Puedo programar una alerta para el futuro?',
      'Si el módulo soporta programación, selecciona fecha y hora antes de confirmar envío.'),
  _FaqItem('¿Cómo cancelo una alerta programada?',
      'En Alertas Programadas > selecciona > Cancelar antes de la hora de ejecución.'),
  _FaqItem('¿Cómo diferencio alertas críticas de informativas?',
      'Por color/categoría visual y etiqueta (ej. “Crítica”, “Aviso”). Se define al crear la alerta.'),
  _FaqItem('¿Qué hacer si una categoría de alerta ya no aplica?',
      'Desactívala para preservarla en historial sin permitir nuevos usos.'),
  _FaqItem('¿Cómo validar que un padre vio una alerta importante?',
      'Revisa confirmaciones de lectura o solicita acuse manual si la función no existe.'),
  _FaqItem('¿Puedo reenviar una alerta?',
      'Sí, abre historial y usa “Reenviar” o “Duplicar” para replicar y ajustar.'),
  _FaqItem('¿Cómo gestionar múltiples escuelas si administro varias?',
      'Cambia de contexto (selector de institución) antes de operar; evita mezclar datos.'),
  _FaqItem('¿Por qué no puedo editar datos históricos?',
      'Para preservar integridad; se permite solo correcciones dentro de una ventana temporal.'),
  _FaqItem('¿Cómo registrar un nuevo ciclo escolar?',
      'Configuración Académica > Ciclos > Nuevo ciclo > Fechas > Guardar.'),
  _FaqItem('¿Qué ocurre al cerrar un ciclo escolar?',
      'Se archivan datos, se bloquean nuevas asistencias y se prepara el entorno para el nuevo ciclo.'),
  _FaqItem('¿Cómo promuevo alumnos al siguiente grado?',
      'Usa la función de promoción masiva: selecciona ciclo destino y confirma.'),
  _FaqItem('¿Qué hago con alumnos que repiten?',
      'En la promoción, exclúyelos o reasígnalos manualmente al mismo grado.'),
  _FaqItem('¿Cómo manejar alumnos dados de baja?',
      'Marca como Inactivos; mantiene historial sin aparecer en listados activos.'),
  _FaqItem('¿Cómo configuro horarios de notificaciones?',
      'Ajustes > Notificaciones > Ventanas horarias (evitar alertas nocturnas).'),
  _FaqItem('¿Qué hacer si la app va lenta?',
      'Verifica conexión, cierra otras apps, fuerza recarga. Si persiste, reporta con pasos.'),
  _FaqItem('¿Cómo priorizo qué mejoras solicitar al equipo?',
      'Documenta impacto (usuarios afectados, frecuencia) y canaliza por el mecanismo oficial de soporte.'),
];

// ——— FAQ USUARIO ———
const List<_FaqItem> _userFaqs = [
  _FaqItem('¿Cómo actualizo mis datos de contacto?',
      'En Perfil > Datos Personales. Edita y guarda; se requerirá conexión.'),
  _FaqItem('¿Puedo cambiar el idioma de la app?',
      'Sí. Perfil > Preferencias > Idioma.'),
  _FaqItem(
      '¿Cómo activo el modo oscuro?', 'Perfil > Preferencias > Tema > Oscuro.'),
  _FaqItem('¿Qué hago si olvidé mi contraseña?',
      'En pantalla de inicio de sesión usa “¿Olvidaste tu contraseña?” y sigue instrucciones.'),
  _FaqItem('¿Por qué no recibo notificaciones?',
      'Verifica permisos del sistema, conexión y que tu sesión esté activa.'),
  _FaqItem('¿Cómo veo las alertas más recientes?',
      'En la sección Alertas/Inicio; aparecen ordenadas por fecha.'),
  _FaqItem('¿Puedo marcar una alerta como leída?',
      'Al abrirla ya cuenta como leída; algunas muestran un indicador.'),
  _FaqItem('¿Cómo encuentro una alerta antigua?',
      'Usa el buscador o filtros por fecha/categoría en la lista de alertas.'),
  _FaqItem('¿Qué significa una alerta “crítica”?',
      'Requiere atención inmediata (seguridad, emergencias). Léela de inmediato.'),
  _FaqItem('¿Cómo confirmar que la escuela sabe que leí una alerta?',
      'La plataforma registra lectura automáticamente si abres la alerta.'),
  _FaqItem('¿Puedo responder a una alerta?',
      'Solo si la escuela habilitó respuestas; de lo contrario es unidireccional.'),
  _FaqItem('¿Cómo actualizo mis hijos asociados?',
      'Normalmente lo gestiona la escuela; solicita corrección si falta uno.'),
  _FaqItem('¿Por qué no veo a mi hijo en la lista?',
      'Puede faltar vinculación; contacta administración para verificación.'),
  _FaqItem('¿Cómo reviso asistencia de mi hijo?',
      'En el módulo Asistencia/Alumno: lista de días con estado.'),
  _FaqItem('¿Puedo justificar una inasistencia desde la app?',
      'Si existe función de justificación, adjunta motivo; si no, comunica a la escuela.'),
  _FaqItem('¿Qué hago si la asistencia mostrada es incorrecta?',
      'Reporta a la escuela indicando fecha y discrepancia.'),
  _FaqItem('¿Cómo cierro sesión de forma segura?',
      'Perfil > Cerrar sesión y confirma en el diálogo.'),
  _FaqItem('¿Puedo usar la app en más de un dispositivo?',
      'Sí, pero asegúrate de cerrar sesión si pierdes un dispositivo.'),
  _FaqItem('¿Por qué me pide volver a iniciar sesión?',
      'Sesión expirada o token inválido; solo inicia nuevamente.'),
  _FaqItem('¿Cómo cambio mi foto (si aplica)?',
      'En Datos Personales toca el avatar y selecciona una imagen.'),
  _FaqItem('¿Cómo recibo solo alertas relevantes?',
      'Normalmente se filtran por grupo; si recibes irrelevantes, informa a la escuela.'),
  _FaqItem('¿Qué hago si la app no carga?',
      'Verifica Internet, fuerza cierre y abre; si sigue, reinstala o contacta soporte.'),
  _FaqItem('¿La app funciona sin Internet?',
      'Verás datos almacenados, pero no nuevas alertas hasta reconectar.'),
  _FaqItem('¿Por qué aparece “Próximamente” en algunas secciones?',
      'Son funciones futuras (ayuda, feedback).'),
  _FaqItem('¿Cómo envío sugerencias si no hay módulo de feedback aún?',
      'Usa el correo o canal indicado en Sobre la aplicación.'),
  _FaqItem('¿Dónde encuentro la política de privacidad?',
      'Perfil > Sobre la aplicación > Política de Privacidad.'),
  _FaqItem('¿Puedo compartir una alerta con otro padre?',
      'Sí, pero respeta la confidencialidad; mejor pide que ingrese a su cuenta.'),
  _FaqItem('¿Qué significa si no llega ninguna alerta en días?',
      'Puede no haber novedades o problema de notificaciones; verifica ajustes.'),
  _FaqItem('¿Cómo manejo múltiples hijos?',
      'Cambia pestañas o selecciona cada alumno en la vista correspondiente.'),
  _FaqItem('¿Cómo veo eventos o recordatorios (si existen)?',
      'En Calendario/Eventos; listados por fecha.'),
  _FaqItem('¿Puedo descargar un comprobante de asistencia?',
      'Si la escuela habilitó exportación, aparecerá opción Descargar/Exportar.'),
  _FaqItem('¿Cómo sé que la información es oficial?',
      'Las alertas con el sello o logotipo institucional son oficiales.'),
  _FaqItem('¿Qué hago si recibo información contradictoria fuera de la app?',
      'Prioriza lo publicado en la aplicación y confirma con la escuela.'),
  _FaqItem('¿Cómo reduzco consumo de datos?',
      'Usa Wi-Fi, evita abrir repetidamente multimedia, y cierra la app al terminar.'),
  _FaqItem('¿Cómo sé la versión instalada?',
      'Perfil > Sobre la aplicación > Versión.'),
  _FaqItem('¿Necesito actualizar manualmente?',
      'Según tu tienda (App Store/Play Store) puede actualizarse automáticamente; revisa si hay nueva versión.'),
  _FaqItem('¿Por qué tarda en llegar una alerta?',
      'Posible retraso de red o notificaciones; verifica conexión y permisos.'),
  _FaqItem('¿Cómo configuro que no suene de noche?',
      'Ajusta “No molestar” del sistema; la app respeta configuración del dispositivo.'),
  _FaqItem('¿Puedo cambiar el correo registrado?',
      'Solicita a la escuela (verificación de identidad) si la app no permite edición directa.'),
  _FaqItem('¿Cómo protejo mi cuenta?',
      'Usa contraseña robusta, no compartas credenciales, cierra sesión en dispositivos ajenos.'),
  _FaqItem('¿Por qué me expulsó la app al cambiar de idioma?',
      'Puede reiniciar componentes al aplicar traducciones; vuelve a entrar si lo pide.'),
  _FaqItem('¿Puedo usar la app en una tablet?',
      'Sí, se adapta; interfaz puede mostrar más información.'),
  _FaqItem('¿Qué significa una alerta programada para mañana?',
      'Fue creada anticipadamente y se enviará automáticamente en la hora prevista.'),
  _FaqItem('¿Puedo cancelar una alerta programada como padre?',
      'No; solo el personal autorizado.'),
  _FaqItem('¿Cómo solicitar corrección de datos personales?',
      'Edita los propios permitidos; los restringidos solicita a la administración.'),
  _FaqItem('¿Cómo limito que mis hijos vean mis datos?',
      'La app suele separar roles; ellos no acceden a tu perfil parental.'),
  _FaqItem('¿Cómo sé si mi acción (ej. justificación) fue recibida?',
      'El estado cambia (Enviada/Aprobada) o recibes confirmación; si no, consulta.'),
  _FaqItem('¿Qué hago si veo datos de otro alumno?',
      'Cierra sesión y reporta inmediatamente para revisión de permisos.'),
  _FaqItem('¿La app comparte mis datos con terceros?',
      'Consulta Política de Privacidad; normalmente se limita al uso educativo interno.'),
  _FaqItem('¿A quién contacto si nada funciona?',
      'Usa el correo/soporte listado en Sobre la aplicación con descripción y capturas.'),
];
