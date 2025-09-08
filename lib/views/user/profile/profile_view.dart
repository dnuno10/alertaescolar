import 'package:alertaescolar/providers/language_provider.dart';
import 'package:alertaescolar/components/profile/profile_header.dart';
import 'package:alertaescolar/components/profile/settings_sections_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../managers/user_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Asegura tener el usuario cargado al entrar al perfil (sin modal)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser(context, showDialog: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final screenSize = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: CustomScrollView(
            slivers: [
              ProfileHeader(screenSize: screenSize),

              // Settings Sections
              SliverToBoxAdapter(
                child: SettingsSectionsContent(screenSize: screenSize),
              ),
            ],
          ),
        );
      },
    );
  }
}
