import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../app/app_theme.dart';
import '../../../components/students/students_header.dart';
import '../../../components/students/students_section.dart';
import 'add_student_view.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: StudentsHeader(screenSize: screenSize),
                  ),
                  SliverToBoxAdapter(
                    child: StudentsSection(
                      isWide: isWide,
                      screenSize: screenSize,
                      onAddStudent: () => _navigateToAddStudent(context),
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
    );
  }
}
