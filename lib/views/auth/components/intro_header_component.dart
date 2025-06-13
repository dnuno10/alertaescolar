import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/app_theme.dart';
import '../../../providers/theme_provider.dart';

class IntroHeaderComponent extends StatelessWidget {
  const IntroHeaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SizedBox(
      height: size.height * 0.2,
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary,
          highlightColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.5),
          period: const Duration(seconds: 4),
          child: Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.07, right: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Alerta Escolar",
                  style: AppTheme.getH1(size).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // IconButton(
                //   icon: Icon(
                //     themeProvider.isDarkMode
                //         ? Icons.light_mode
                //         : Icons.dark_mode,
                //     size: size.height * 0.03,
                //   ),
                //   onPressed: () {
                //     themeProvider.toggleTheme();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
