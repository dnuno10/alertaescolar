import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size * 0.1,
        color: color ?? AppTheme.accentBlue,
      ),
    );
  }
}
