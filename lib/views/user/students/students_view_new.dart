import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/managers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../../../app/app_theme.dart';
import '../../../components/students/students_header.dart';
import '../../../components/students/students_section.dart';
import 'add_student_view.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              Size size = MediaQuery.of(context).size;
              return Stack(
                children: [
                  // Main content
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: StudentsHeader(screenSize: screenSize),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                size.height * 0.12, // Space for floating button
                          ),
                          child: StudentsSection(
                            isWide: isWide,
                            screenSize: screenSize,
                            onAddStudent: () => _navigateToAddStudent(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Fixed floating action button
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    left: screenSize.width * 0.2,
                    right: screenSize.width * 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.getLargeRadius(screenSize),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getShadowColor(context),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToAddStudent(context),
                        icon: Icon(
                          Icons.add_rounded,
                          size: screenSize.height * 0.025,
                          color: Colors.white,
                        ),
                        label: Text(
                          l10n.addStudent,
                          style: AppTheme.getBodyMedium(screenSize).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getMediumPadding(screenSize),
                            vertical: AppTheme.getSmallPadding(screenSize),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(screenSize),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStudentView(),
      ),
    ).then((_) {
      // Refresh students list when returning from add student
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        studentProvider.loadStudentsForUser(
          userId: userProvider.currentUser!.id,
          forceReload: true,
        );
      }
    });
  }
}
