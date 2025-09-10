import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/app_theme.dart';

class ModernDropdown<T> extends StatefulWidget {
  final String? label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) getLabel;
  static _ModernDropdownState? _openedInstance;

  final Size screenSize;
  final Color? backgroundColor;

  const ModernDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getLabel,
    required this.screenSize,
    this.backgroundColor,
  });

  @override
  State<ModernDropdown<T>> createState() => _ModernDropdownState<T>();
}

class _ModernDropdownState<T> extends State<ModernDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  bool _isDisposed = false;

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
    _isDisposed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    // 👇 antes de abrir, cierra el que esté abierto
    if (ModernDropdown._openedInstance != null &&
        ModernDropdown._openedInstance != this) {
      ModernDropdown._openedInstance!._removeDropdown();
    }
    ModernDropdown._openedInstance = this;

    _animationController.forward();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) setState(() => _isDropdownOpen = true);
  }

  void _removeDropdown() {
    if (!_isDisposed) {
      _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (ModernDropdown._openedInstance == this) {
        ModernDropdown._openedInstance = null;
      }
      if (mounted) setState(() => _isDropdownOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final dropdownHeight =
        (widget.items.length * widget.screenSize.height * 0.06)
            .clamp(48.0, 320.0);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: _animationController,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: dropdownHeight,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                  border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppTheme.accentPurple.withOpacity(0.25),
                      width: 1),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: widget.items.map((item) {
                    final isSelected = item == widget.value;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        widget.onChanged(item);
                        _removeDropdown();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              AppTheme.getMediumPadding(widget.screenSize),
                          vertical: widget.screenSize.height * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              // ignore: deprecated_member_use
                              ? AppTheme.accentPurple.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                              AppTheme.getSmallRadius(widget.screenSize)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.getLabel(item),
                                style: AppTheme.getBodyMedium(widget.screenSize)
                                    .copyWith(
                                  color: isSelected
                                      ? AppTheme.accentPurple
                                      : AppTheme.getTextPrimaryColor(context),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.accentPurple,
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding:
                  EdgeInsets.only(bottom: widget.screenSize.height * 0.008),
              child: Text(
                widget.label!,
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _toggleDropdown();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getMediumPadding(widget.screenSize),
                vertical: widget.screenSize.height * 0.018,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(
                    AppTheme.getSmallRadius(widget.screenSize)),
                border: Border.all(
                  color: _isDropdownOpen
                      ? AppTheme.accentPurple
                      // ignore: deprecated_member_use
                      : AppTheme.accentPurple.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.getLabel(widget.value),
                      style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                        color: AppTheme.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isDropdownOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.accentPurple,
                      size: widget.screenSize.width * 0.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
