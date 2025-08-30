import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'components/login_body_component.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
                  // Quitar const en LoginBodyComponent para que reaccione al cambio de locale
                  // (dejar el Column externo como está no afecta lo visual)
                  // ignore: prefer_const_constructors
                  Column(
                    children: [
                      // ignore: prefer_const_constructors
                      LoginBodyComponent(),
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
