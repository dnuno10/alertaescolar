import 'package:flutter/material.dart';
import '../../models/contacto_familiar.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';

class RelationDropdown extends StatefulWidget {
  final TipoParentesco selectedRelation;
  final ValueChanged<TipoParentesco?> onRelationChanged;
  final Size screenSize;

  const RelationDropdown({
    super.key,
    required this.selectedRelation,
    required this.onRelationChanged,
    required this.screenSize,
  });

  @override
  State<RelationDropdown> createState() => _RelationDropdownState();
}

class _RelationDropdownState extends State<RelationDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(
              Icons.family_restroom,
              size: widget.screenSize.width * 0.04,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            SizedBox(width: widget.screenSize.width * 0.02),
            Text(
              l10n.relationship,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.screenSize.height * 0.012),

        // Custom Dropdown
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
              if (_isDropdownOpen) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          child: Column(
            children: [
              // Selected Item Display
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.getMediumPadding(widget.screenSize),
                  vertical: AppTheme.getSmallPadding(widget.screenSize),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize),
                  ),
                  border: Border.all(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.screenSize.width * 0.02),
                      decoration: BoxDecoration(
                        color: _getRelationColor(widget.selectedRelation)
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRelationIcon(widget.selectedRelation),
                        size: widget.screenSize.width * 0.045,
                        color: _getRelationColor(widget.selectedRelation),
                      ),
                    ),
                    SizedBox(width: widget.screenSize.width * 0.03),
                    Expanded(
                      child: Text(
                        _getRelationshipName(widget.selectedRelation, l10n),
                        style:
                            AppTheme.getBodyMedium(widget.screenSize).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5)
                          .animate(_animationController),
                      child: Container(
                        padding: EdgeInsets.all(widget.screenSize.width * 0.01),
                        decoration: BoxDecoration(
                          color: AppTheme.getBackgroundColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: _isDropdownOpen
                              ? AppTheme.getTextSecondaryColor(context)
                              : AppTheme.getTextSecondaryColor(context),
                          size: widget.screenSize.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dropdown menu with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _isDropdownOpen
                    ? (TipoParentesco.values.length *
                        widget.screenSize.height *
                        0.065)
                    : 0,
                margin: EdgeInsets.only(top: _isDropdownOpen ? 8 : 0),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                  boxShadow: _isDropdownOpen
                      ? [
                          BoxShadow(
                            color: AppTheme.getShadowColor(context),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: TipoParentesco.values.map((relation) {
                      return InkWell(
                        onTap: () {
                          widget.onRelationChanged(relation);
                          setState(() {
                            _isDropdownOpen = false;
                            _animationController.reverse();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppTheme.getMediumPadding(widget.screenSize),
                            vertical: widget.screenSize.height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: widget.selectedRelation == relation
                                ? _getRelationColor(relation).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                AppTheme.getSmallRadius(widget.screenSize)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                    widget.screenSize.width * 0.015),
                                decoration: BoxDecoration(
                                  color: _getRelationColor(relation)
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getRelationIcon(relation),
                                  size: widget.screenSize.width * 0.04,
                                  color: _getRelationColor(relation),
                                ),
                              ),
                              SizedBox(width: widget.screenSize.width * 0.03),
                              Text(
                                _getRelationshipName(relation, l10n),
                                style: AppTheme.getBodyMedium(widget.screenSize)
                                    .copyWith(
                                  color: AppTheme.getTextPrimaryColor(context),
                                  fontWeight:
                                      widget.selectedRelation == relation
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                              const Spacer(),
                              if (widget.selectedRelation == relation)
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.getTextPrimaryColor(context),
                                  size: widget.screenSize.width * 0.045,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRelationIcon(TipoParentesco relation) {
    switch (relation) {
      case TipoParentesco.padre:
        return Icons.man;
      case TipoParentesco.madre:
        return Icons.woman;
      case TipoParentesco.abuelo:
        return Icons.elderly;
      case TipoParentesco.abuela:
        return Icons.elderly_woman;
      case TipoParentesco.tutor:
        return Icons.school;
      case TipoParentesco.tutora:
        return Icons.school;
      case TipoParentesco.tio:
        return Icons.person;
      case TipoParentesco.tia:
        return Icons.person_2;
      case TipoParentesco.hermano:
        return Icons.boy;
      case TipoParentesco.hermana:
        return Icons.girl;
      case TipoParentesco.otroFamiliar:
        return Icons.family_restroom;
    }
  }

  Color _getRelationColor(TipoParentesco relation) {
    switch (relation) {
      case TipoParentesco.padre:
      case TipoParentesco.madre:
        return Colors.blue;
      case TipoParentesco.abuelo:
      case TipoParentesco.abuela:
        return Colors.purple;
      case TipoParentesco.tutor:
      case TipoParentesco.tutora:
        return Colors.green;
      case TipoParentesco.tio:
      case TipoParentesco.tia:
        return Colors.orange;
      case TipoParentesco.hermano:
      case TipoParentesco.hermana:
        return Colors.teal;
      default:
        return AppTheme.accentPurple;
    }
  }

  String _getRelationshipName(TipoParentesco relation, AppLocalizations l10n) {
    switch (relation) {
      case TipoParentesco.padre:
        return l10n.father;
      case TipoParentesco.madre:
        return l10n.mother;
      case TipoParentesco.abuelo:
        return l10n.grandfather;
      case TipoParentesco.abuela:
        return l10n.grandmother;
      case TipoParentesco.tutor:
        return l10n.guardian;
      case TipoParentesco.tutora:
        return l10n.guardianFemale;
      case TipoParentesco.tio:
        return l10n.uncle;
      case TipoParentesco.tia:
        return l10n.aunt;
      case TipoParentesco.hermano:
        return l10n.brother;
      case TipoParentesco.hermana:
        return l10n.sister;
      case TipoParentesco.otroFamiliar:
        return l10n.otherFamily;
    }
  }
}
