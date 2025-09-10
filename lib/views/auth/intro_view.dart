import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'components/intro_animation_component.dart';
import 'components/intro_options_component.dart';
import '../../app/app_theme.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();

    // Mostrar “splash”/pantalla vacía mientras carga el idioma guardado
    if (!lp.isInitialized) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const SizedBox.expand(),
      );
    }

    final locale = lp.locale;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        // Al cambiar el locale, reconstituye el árbol con una key distinta
        child: _IntroContent(key: ValueKey(locale.languageCode)),
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  const _IntroContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Layout minimalmente responsivo para evitar overflows en pantallas chicas
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Si la pantalla es muy baja, deja espacio flexible arriba

        // Animación / marca
        const IntroAnimationComponent(),
        // Botones / opciones (texto localizado)
        const IntroOptionsComponent(),
      ],
    );
  }
}
