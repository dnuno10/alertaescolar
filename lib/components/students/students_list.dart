import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../app/app_theme.dart';
import 'student_card.dart';

class StudentsList extends StatelessWidget {
  final List<Alumno> students;
  final bool isWide;
  final Size screenSize;

  const StudentsList({
    super.key,
    required this.students,
    required this.isWide,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppTheme.getSmallPadding(screenSize),
          mainAxisSpacing: AppTheme.getSmallPadding(screenSize),
        ),
        itemCount: students.length,
        itemBuilder: (context, index) => StudentCard(
          student: students[index],
          screenSize: screenSize,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
      itemBuilder: (context, index) => StudentCard(
        student: students[index],
        screenSize: screenSize,
      ),
    );
  }
}
