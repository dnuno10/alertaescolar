import 'package:alertaescolar/views/auth/components/signup_body_component.dart';
import 'package:flutter/material.dart';
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
    // Mantén el almacenamiento del idioma
    Provider.of<LocaleProvider>(context);
    return Scaffold(
      // Centramos el contenido y lo llevamos al final
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context)
                  .size
                  .height, // Aseguramos que la Column ocupe toda la altura de la pantalla
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
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
