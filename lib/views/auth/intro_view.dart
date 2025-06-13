import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/language_provider.dart';
import 'components/intro_header_component.dart';
import 'components/intro_animation_component.dart';
import 'components/intro_options_component.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  @override
  Widget build(BuildContext context) {
    // Mantén el almacenamiento del idioma
    Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            IntroHeaderComponent(),
            IntroAnimationComponent(),
            IntroOptionsComponent(),
          ],
        ),
      ),
    );
  }
}
