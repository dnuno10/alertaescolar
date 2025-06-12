import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ProgressLine extends StatelessWidget {
  final int step;
  final int currentStep;
  final Size screenSize;

  const ProgressLine({
    super.key,
    required this.step,
    required this.currentStep,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = step < currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 2,
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successColor
            : AppTheme.getBorderColor(context),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
