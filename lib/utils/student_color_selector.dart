import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../managers/student_provider.dart';

class StudentColorSelector {
  static Color getStudentColor(StudentDetails student) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    return colors[student.hashCode % colors.length];
  }
}
