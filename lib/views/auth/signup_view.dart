import 'package:alertaescolar/views/auth/components/signup_body_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  @override
  Widget build(BuildContext context) {
    // Escucha cambios de idioma y evita parpadeo si aún no carga
    final lp = context.watch<LocaleProvider>();
    if (!lp.isInitialized) {
      return const Scaffold(body: SizedBox.expand());
    }

    return Scaffold(
      // Centramos el contenido y lo llevamos al final
      body: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  // Quitar const en SignUpBodyComponent para que reaccione al cambio de locale
                  // (mantener la estructura visual idéntica)
                  // ignore: prefer_const_constructors
                  Column(
                    children: [
                      // ignore: prefer_const_constructors
                      SignUpBodyComponent(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
