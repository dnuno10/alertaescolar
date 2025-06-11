import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class StudentsSearchBar extends StatefulWidget {
  final Size screenSize;
  final ValueChanged<String> onSearchChanged;

  const StudentsSearchBar({
    super.key,
    required this.screenSize,
    required this.onSearchChanged,
  });

  @override
  State<StudentsSearchBar> createState() => _StudentsSearchBarState();
}

class _StudentsSearchBarState extends State<StudentsSearchBar> {
  final _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getLargeRadius(widget.screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: widget.screenSize.height * 0.015,
            offset: Offset(0, widget.screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    AppTheme.getSmallPadding(widget.screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppTheme.successColor,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Text(
                l10n.searchStudents,
                style: AppTheme.getH2(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Search input
          TextFormField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _isSearchActive = value.isNotEmpty;
              });
              widget.onSearchChanged(value);
            },
            decoration: InputDecoration(
              hintText: l10n.searchByNameOrId ?? 'Buscar por nombre o ID...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isSearchActive
                    ? AppTheme.successColor
                    : AppTheme.getTextSecondaryColor(context),
                size: widget.screenSize.height * 0.025,
              ),
              suffixIcon: _isSearchActive
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.getTextSecondaryColor(context),
                        size: widget.screenSize.height * 0.025,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.getInputFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    AppTheme.getMediumRadius(widget.screenSize)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    AppTheme.getMediumRadius(widget.screenSize)),
                borderSide: BorderSide(
                  color: AppTheme.successColor,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
            ),
            style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),

          // Search suggestions or tips
          if (_isSearchActive)
            _SearchSuggestions(screenSize: widget.screenSize, l10n: l10n)
          else
            _SearchTips(screenSize: widget.screenSize, l10n: l10n),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearchActive = false;
    });
    widget.onSearchChanged('');
  }
}

class _SearchSuggestions extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _SearchSuggestions({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.successColor,
            size: screenSize.height * 0.02,
          ),
          SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
          Expanded(
            child: Text(
              l10n.searchTip ??
                  'Puede buscar por nombre completo, apellido o ID de estudiante',
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTips extends StatelessWidget {
  final Size screenSize;
  final AppLocalizations l10n;

  const _SearchTips({
    required this.screenSize,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'icon': Icons.person_rounded,
        'text': l10n.searchByName ?? 'Buscar por nombre',
      },
      {
        'icon': Icons.tag_rounded,
        'text': l10n.searchById ?? 'Buscar por ID',
      },
      {
        'icon': Icons.school_rounded,
        'text': l10n.searchByGrade ?? 'Combinar con filtros',
      },
    ];

    return Wrap(
      spacing: AppTheme.getSmallPadding(screenSize),
      runSpacing: AppTheme.getSmallPadding(screenSize) * 0.5,
      children: tips
          .map((tip) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize) * 0.75),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tip['icon'] as IconData,
                      color: AppTheme.getTextSecondaryColor(context),
                      size: screenSize.height * 0.018,
                    ),
                    SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
                    Text(
                      tip['text'] as String,
                      style: AppTheme.getCaptionSmall(screenSize).copyWith(
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
