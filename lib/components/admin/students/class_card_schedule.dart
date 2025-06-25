import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/models/horario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/time_format.dart';
import '../../../l10n/app_localizations.dart';

class ClassCardSchedule extends StatefulWidget {
  final ClaseHorario clase;
  final Materia? materia;
  final int index;
  final Size screenSize;

  const ClassCardSchedule({
    super.key,
    required this.clase,
    this.materia,
    required this.index,
    required this.screenSize,
  });

  @override
  State<ClassCardSchedule> createState() => _ClassCardScheduleState();
}

class _ClassCardScheduleState extends State<ClassCardSchedule>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  String _formatTime(String time) {
    try {
      // Handle timetz format from PostgreSQL: "08:00:00+00" or "08:00:00-05:00"
      if (time.contains('+') ||
          (time.contains('-') && time.lastIndexOf('-') > 2)) {
        // Remove timezone part for display (e.g., "08:00:00+00" -> "08:00:00")
        String timePart;
        if (time.contains('+')) {
          timePart = time.split('+')[0];
        } else {
          // Handle negative timezone offset
          final lastDashIndex = time.lastIndexOf('-');
          timePart = time.substring(0, lastDashIndex);
        }

        // Parse the time part
        final timeComponents = timePart.split(':');
        if (timeComponents.length >= 2) {
          final hour = int.parse(timeComponents[0]);
          final minute = int.parse(timeComponents[1]);
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }

      // Handle simple time format: "08:00:00" or "08:00"
      else if (time.contains(':') &&
          !time.contains('T') &&
          !time.contains(' ')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }

      // Handle full timestamp format (fallback for compatibility)
      else if (time.contains('T') && time.contains(':')) {
        DateTime dateTime = DateTime.parse(time);
        return TimeFormat.format24to12(
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}');
      }

      // Handle date with time format: "1970-01-01 08:00:00+00"
      else if (time.contains('-') && time.contains(' ') && time.contains(':')) {
        final parts = time.split(' ');
        if (parts.length >= 2) {
          return _formatTime(parts[1]); // Recursively parse the time part
        }
      }

      // If all else fails, try to extract time pattern HH:MM
      final timePattern = RegExp(r'(\d{1,2}):(\d{2})');
      final match = timePattern.firstMatch(time);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        return TimeFormat.format24to12(
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      }

      return time; // Return original if can't parse
    } catch (e) {
      debugPrint('Error formatting timetz: $time, error: $e');
      return time; // Return original string if parsing fails
    }
  }

  Duration _getClassDuration() {
    try {
      final startTime = _formatTime(widget.clase.horaInicio);
      final endTime = _formatTime(widget.clase.horaFin);

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      if (startParts.length >= 2 && endParts.length >= 2) {
        final startHour = int.parse(startParts[0]);
        final startMinute = int.parse(startParts[1]);
        final endHour = int.parse(endParts[0]);
        final endMinute = int.parse(endParts[1]);

        final startMinutes = startHour * 60 + startMinute;
        final endMinutes = endHour * 60 + endMinute;

        // Handle day overflow (e.g., class from 23:00 to 01:00)
        if (endMinutes < startMinutes) {
          return Duration(minutes: (endMinutes + 1440) - startMinutes);
        }

        return Duration(minutes: endMinutes - startMinutes);
      }

      return const Duration(hours: 1); // Default duration
    } catch (e) {
      debugPrint('Error calculating duration: $e');
      return const Duration(hours: 1);
    }
  }

  Color _getSubjectColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String subjectName = widget.materia?.nombre ?? l10n.subject;
    final String professor = widget.materia?.profesor ?? '';
    final Color cardColor =
        _getSubjectColor(widget.materia?.color ?? '#9B5DE5');
    final Duration duration = _getClassDuration();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: () {
              HapticFeedback.mediumImpact();
              // You can add navigation or show details here
              _showClassDetails(context);
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                horizontal: AppTheme.getSmallPadding(widget.screenSize) * 0.25,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getCardColor(context),
                    AppTheme.getCardColor(context).withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  AppTheme.getLargeRadius(widget.screenSize),
                ),
                border: Border.all(
                  color: cardColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppTheme.getLargeRadius(widget.screenSize),
                ),
                child: Stack(
                  children: [
                    // Background gradient accent
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(
                          AppTheme.getMediumPadding(widget.screenSize)),
                      child: Row(
                        children: [
                          // Enhanced time indicator
                          _buildTimeIndicator(cardColor),

                          SizedBox(
                              width:
                                  AppTheme.getMediumPadding(widget.screenSize)),

                          // Enhanced class details
                          Expanded(
                            child: _buildClassDetails(
                                context, subjectName, professor, duration),
                          ),

                          // Enhanced subject color indicator with icon
                          _buildSubjectIndicator(cardColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(Color cardColor) {
    return Container(
      width: widget.screenSize.width * 0.18,
      height: widget.screenSize.width * 0.18,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.15),
            cardColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppTheme.getMediumRadius(widget.screenSize),
        ),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: cardColor,
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(widget.clase.horaInicio),
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Container(
            width: 20,
            height: 1,
            color: cardColor.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(vertical: 1),
          ),
          Text(
            _formatTime(widget.clase.horaFin),
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: cardColor.withValues(alpha: 0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassDetails(BuildContext context, String subjectName,
      String professor, Duration duration) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject name with enhanced styling
        Row(
          children: [
            Expanded(
              child: Text(
                subjectName,
                style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextPrimaryColor(context),
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Duration chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    AppTheme.getOnPrimaryColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.durationInMinutes(duration.inMinutes),
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getOnPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.5),

        // Professor info with enhanced styling
        if (professor.isNotEmpty && professor != l10n.teacher) ...[
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  professor,
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize) * 0.25),
        ],

        // Classroom info with enhanced styling
        if (widget.clase.aula.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.room_outlined,
                size: 14,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.classroom + ' ' + widget.clase.aula,
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubjectIndicator(Color cardColor) {
    return Column(
      children: [
        Icon(
          Icons.chevron_right_rounded,
          size: MediaQuery.of(context).size.height * 0.04,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ],
    );
  }

  void _showClassDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildClassDetailModal(),
    );
  }

  Widget _buildClassDetailModal() {
    final l10n = AppLocalizations.of(context);
    final Color cardColor =
        _getSubjectColor(widget.materia?.color ?? '#9B5DE5');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Class title
          Text(
            widget.materia?.nombre ?? l10n.classDetails,
            style: AppTheme.getH2(widget.screenSize).copyWith(
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
          const SizedBox(height: 20),

          // Class details
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: l10n.schedule,
            value:
                '${_formatTime(widget.clase.horaInicio)} - ${_formatTime(widget.clase.horaFin)}',
            color: cardColor,
          ),

          if (widget.materia?.profesor?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: l10n.teacher,
              value: widget.materia!.profesor!,
              color: cardColor,
            ),
          ],

          if (widget.clase.aula.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.room_outlined,
              label: l10n.classroom,
              value: widget.clase.aula,
              color: cardColor,
            ),
          ],

          const SizedBox(height: 20),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.close),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTheme.getCaption(MediaQuery.of(context).size).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style:
                    AppTheme.getSubtitle2(MediaQuery.of(context).size).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
