// lib/components/schedule/day_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class DaySelector extends StatelessWidget {
  final int selectedDayIndex; // 0 = Todos, 1..7 = L..D
  final Function(int) onDaySelected;
  final Size screenSize;

  const DaySelector({
    super.key,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Índice 0 = "Todos"
    final items = <String>[
      // Si no tienes una clave en l10n para "all", usa 'Todos'
      (l10n.tryLookup('all') ?? 'Todos'),
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.getMediumPadding(screenSize),
        right: AppTheme.getMediumPadding(screenSize),
        bottom: AppTheme.getMediumPadding(screenSize),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.daysOfWeek,
            style: AppTheme.getSubtitle1(screenSize).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: AppTheme.getSmallPadding(screenSize)),
          SizedBox(
            height: screenSize.height * 0.06,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length, // ahora son 8 (Todos + 7 días)
              itemBuilder: (context, index) {
                final isSelected = index == selectedDayIndex;
                return Padding(
                  padding: EdgeInsets.only(
                    right: AppTheme.getSmallPadding(screenSize),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onDaySelected(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.getMediumPadding(screenSize),
                        vertical: AppTheme.getSmallPadding(screenSize),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(
                          AppTheme.getMediumRadius(screenSize),
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentPurple
                              : AppTheme.getBorderColor(context),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: AppTheme.accentPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          items[index],
                          style: AppTheme.getCaption(screenSize).copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.onPrimaryColor
                                : AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Añade este helper si no lo tienes en tu l10n:
extension _TryLookup on AppLocalizations {
  String? tryLookup(String key) {
    // Evita crashear si no existe la clave; puedes mapear si tienes gen_l10n
    switch (key) {
      case 'all':
        // Crea la clave real en tus ARB si prefieres (ej. "all": "Todos")
        return 'Todos';
    }
    return null;
  }
}
