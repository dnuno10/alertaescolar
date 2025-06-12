import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/models.dart';

class StudentColorSelector {
  static Color getStudentColor(Alumno student) {
    final colors = [
      AppTheme.accentBlue,
      AppTheme.successColor,
      AppTheme.accentPurple,
      AppTheme.warningColor,
    ];
    return colors[student.hashCode % colors.length];
  }
}
