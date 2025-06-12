import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int step;
  final int currentStep;
  final String label;
  final IconData icon;
  final Size screenSize;

  const StepIndicator({
    super.key,
    required this.step,
    required this.currentStep,
    required this.label,
    required this.icon,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: screenSize.height * 0.045,
          height: screenSize.height * 0.045,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.successColor
                : isActive
                    ? AppTheme.accentBlue
                    : AppTheme.getBackgroundColor(context),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                      ? AppTheme.accentBlue
                      : AppTheme.getBorderColor(context),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(screenSize.height * 0.025),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isCompleted || isActive
                ? Colors.white
                : AppTheme.getTextSecondaryColor(context),
            size: screenSize.height * 0.02,
          ),
        ),
        SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          label,
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: isActive
                ? AppTheme.getTextPrimaryColor(context)
                : AppTheme.getTextSecondaryColor(context),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
