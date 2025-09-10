import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class PersonalDataDivider extends StatelessWidget {
  const PersonalDataDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.getBorderColor(context),
      // ignore: deprecated_member_use_from_same_package
      indent: AppTheme.paddingMedium,
      // ignore: deprecated_member_use_from_same_package
      endIndent: AppTheme.paddingMedium,
    );
  }
}
