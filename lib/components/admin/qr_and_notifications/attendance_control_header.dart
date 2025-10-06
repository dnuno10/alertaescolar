// attendance_control_header.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/turno_provider.dart';
import '../../../services/scanner_service.dart';
import 'action_button.dart';

// Define enum for access types
enum AccessType {
  // ignore: constant_identifier_names
  default_config, // Automático inteligente (basado en horarios)
  // ignore: constant_identifier_names
  fixed_entry, // Entrada fija
  // ignore: constant_identifier_names
  fixed_exit, // Salida fija
  // ignore: constant_identifier_names
  extracurricular_entry, // Entrada extracurricular
  // ignore: constant_identifier_names
  extracurricular_exit, // Salida extracurricular
}

class AttendanceControlHeader extends StatefulWidget {
  final bool isScanning;
  final Size screenSize;
  final VoidCallback onConfigurationTap;
  final VoidCallback onNotificationTap;
  final AccessType selectedAccessType;
  final bool
      isDefaultEntryConfig; // true = entrada, false = salida como default
  final ValueChanged<AccessType> onAccessTypeChanged;

  const AttendanceControlHeader({
    super.key,
    required this.isScanning,
    required this.screenSize,
    required this.onConfigurationTap,
    required this.onNotificationTap,
    required this.selectedAccessType,
    required this.isDefaultEntryConfig,
    required this.onAccessTypeChanged,
  });

  @override
  State<AttendanceControlHeader> createState() =>
      _AttendanceControlHeaderState();
}

class _AttendanceControlHeaderState extends State<AttendanceControlHeader> {
  // 🔄 AUTO-UPDATE: Timer para actualizar el desplegable automáticamente
  Timer? _accessTypeUpdateTimer;
  bool _currentIsDefaultEntryConfig = true;

  @override
  void initState() {
    super.initState();
    _currentIsDefaultEntryConfig = widget.isDefaultEntryConfig;
    _startAccessTypeUpdateTimer();
  }

  @override
  void dispose() {
    _accessTypeUpdateTimer?.cancel();
    super.dispose();
  }

  // ========================
  // AUTO-UPDATE: Timer para actualizar el desplegable
  // ========================
  void _startAccessTypeUpdateTimer() {
    _accessTypeUpdateTimer?.cancel();
    _accessTypeUpdateTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 🔄 AUTO-UPDATE: Verificar cambio de fase cada 5 segundos
      try {
        final turnoProvider =
            Provider.of<TurnoProvider>(context, listen: false);
        final currentPhase = turnoProvider.resolveAccessPhase();
        final newIsDefaultEntryConfig =
            (currentPhase.type == ScannerAccessType.entry);

        // Solo actualizar si hay un cambio real
        if (_currentIsDefaultEntryConfig != newIsDefaultEntryConfig) {
          setState(() {
            _currentIsDefaultEntryConfig = newIsDefaultEntryConfig;
            debugPrint(
                '🔄 HEADER: Cambio de fase detectado inmediatamente - isDefaultEntryConfig: $_currentIsDefaultEntryConfig');
          });
        }
      } catch (e) {
        debugPrint('🔄 HEADER: Error verificando cambio de fase: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padS = AppTheme.getSmallPadding(widget.screenSize);
    final padM = AppTheme.getMediumPadding(widget.screenSize);
    final padL = AppTheme.getLargePadding(widget.screenSize);
    final radiusM = AppTheme.getMediumRadius(widget.screenSize);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + padM,
        left: padM,
        right: padM,
        bottom: padL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        // ❌ Sin sombras
        // ❌ Sin degradados intensos
        border: Border(
          bottom: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Text(
            l10n.attendanceControl,
            style: AppTheme.getH1(widget.screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(height: padS),

          // Descripción
          Text(
            l10n.scanQRToRegisterAttendance,
            style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.35,
            ),
          ),

          SizedBox(height: padL),

          // Dropdown (sin elevación y con items estilizados)
          _buildAccessTypeDropdown(context, l10n, radiusM, padM, padS),

          SizedBox(height: padM),

          // Acciones
          Row(
            children: [
              ActionButton(
                color: AppTheme.accentBlue,
                icon: Icons.settings_rounded,
                onTap: widget.onConfigurationTap,
                screenSize: widget.screenSize,
              ),
              SizedBox(width: padM),
              Expanded(
                child: ActionButton(
                  color: AppTheme.accentOrange,
                  icon: Icons.notifications_rounded,
                  onTap: widget.onNotificationTap,
                  screenSize: widget.screenSize,
                  label: l10n.sendNotification,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccessTypeDropdown(
    BuildContext context,
    AppLocalizations l10n,
    double radiusM,
    double padM,
    double padS,
  ) {
    final width = MediaQuery.of(context).size.width;
    final surface = AppTheme.getSurfaceColor(context);

    return PopupMenuButton<AccessType>(
      enabled: !widget.isScanning,
      onSelected: (v) {
        if (!widget.isScanning) widget.onAccessTypeChanged(v);
      },
      // ❌ Sin sombras
      elevation: 0,
      // Menú con bordes suaves, sin sombras, full width “cardless”
      position: PopupMenuPosition.under,
      offset: Offset(0, AppTheme.getMediumPadding(widget.screenSize)),
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
        side: BorderSide(color: AppTheme.getBorderColor(context), width: 1),
      ),
      constraints: BoxConstraints(
        minWidth: width - (padM * 2),
        maxWidth: width - (padM * 2),
        maxHeight: widget.screenSize.height * 0.42,
      ),
      itemBuilder: (BuildContext context) {
        return AccessType.values.map((value) {
          final bool isSelected = value == widget.selectedAccessType;
          return PopupMenuItem<AccessType>(
            value: value,
            padding: EdgeInsets.symmetric(horizontal: padM, vertical: padS),
            height: 56,
            child: _AccessOptionTile(
              screenSize: widget.screenSize,
              title: _titleFor(value),
              subtitle: _subtitleFor(value),
              leading: _iconFor(value, context),
              selected: isSelected,
              context: context,
            ),
          );
        }).toList();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(radiusM),
          border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: padM,
          vertical: padM * 0.8,
        ),
        child: Row(
          children: [
            Expanded(
              child: _AccessCurrentChip(
                screenSize: widget.screenSize,
                title: _currentTitle(),
                leading: _currentIcon(context),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.getTextSecondaryColor(context),
              size: widget.screenSize.shortestSide * 0.035,
            ),
          ],
        ),
      ),
    );
  }

  // ——— Helpers para presentar texto/iconos coherentes y minimalistas ———

  String _currentTitle() {
    switch (widget.selectedAccessType) {
      case AccessType.default_config:
        return _currentIsDefaultEntryConfig
            ? 'Auto • Entrada'
            : 'Auto • Salida';
      case AccessType.fixed_entry:
        return 'Entrada fija';
      case AccessType.fixed_exit:
        return 'Salida fija';
      case AccessType.extracurricular_entry:
        return 'Entrada extracurricular';
      case AccessType.extracurricular_exit:
        return 'Salida extracurricular';
    }
  }

  Widget _currentIcon(BuildContext context) {
    switch (widget.selectedAccessType) {
      case AccessType.default_config:
        return Icon(
          Icons.smart_toy_outlined,
          size: widget.screenSize.shortestSide * 0.045,
          color: AppTheme.accentBlue,
        );
      case AccessType.fixed_entry:
        return Icon(
          Icons.login_rounded,
          size: widget.screenSize.shortestSide * 0.045,
          color: AppTheme.accentBlue,
        );
      case AccessType.fixed_exit:
        return Icon(
          Icons.logout_rounded,
          size: widget.screenSize.shortestSide * 0.045,
          color: AppTheme.accentYellow,
        );
      case AccessType.extracurricular_entry:
        return Icon(
          Icons.login_rounded,
          size: widget.screenSize.shortestSide * 0.045,
          color: AppTheme.accentOrange,
        );
      case AccessType.extracurricular_exit:
        return Icon(
          Icons.logout_rounded,
          size: widget.screenSize.shortestSide * 0.045,
          color: AppTheme.accentPurple,
        );
    }
  }

  String _titleFor(AccessType v) {
    switch (v) {
      case AccessType.default_config:
        return _currentIsDefaultEntryConfig
            ? 'Automático • Entrada'
            : 'Automático • Salida';
      case AccessType.fixed_entry:
        return 'Entrada fija';
      case AccessType.fixed_exit:
        return 'Salida fija';
      case AccessType.extracurricular_entry:
        return 'Entrada extracurricular';
      case AccessType.extracurricular_exit:
        return 'Salida extracurricular';
    }
  }

  String _subtitleFor(AccessType v) {
    switch (v) {
      case AccessType.default_config:
        return 'Se ajusta al horario activo del plantel';
      case AccessType.fixed_entry:
        return 'Forzar registro de ENTRADA';
      case AccessType.fixed_exit:
        return 'Forzar registro de SALIDA';
      case AccessType.extracurricular_entry:
        return 'Registro de entrada en actividades';
      case AccessType.extracurricular_exit:
        return 'Registro de salida en actividades';
    }
  }

  Widget _iconFor(AccessType v, BuildContext context) {
    final size = widget.screenSize.shortestSide * 0.04;
    switch (v) {
      case AccessType.default_config:
        return Icon(Icons.smart_toy_outlined,
            size: size, color: AppTheme.accentBlue);
      case AccessType.fixed_entry:
        return Icon(Icons.login_rounded,
            size: size, color: AppTheme.accentBlue);
      case AccessType.fixed_exit:
        return Icon(Icons.logout_rounded,
            size: size, color: AppTheme.accentYellow);
      case AccessType.extracurricular_entry:
        return Icon(Icons.login_rounded,
            size: size, color: AppTheme.accentOrange);
      case AccessType.extracurricular_exit:
        return Icon(Icons.logout_rounded,
            size: size, color: AppTheme.accentPurple);
    }
  }
}

class _AccessCurrentChip extends StatelessWidget {
  final Size screenSize;
  final String title;
  final Widget leading;

  const _AccessCurrentChip({
    required this.screenSize,
    required this.title,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    return Row(
      children: [
        leading,
        SizedBox(width: padS),
        Flexible(
          child: Text(
            title,
            style: AppTheme.getBodyMedium(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AccessOptionTile extends StatelessWidget {
  final Size screenSize;
  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final BuildContext context;

  const _AccessOptionTile({
    required this.screenSize,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final padS = AppTheme.getSmallPadding(screenSize);
    final padM = AppTheme.getMediumPadding(screenSize);
    final radiusM = AppTheme.getMediumRadius(screenSize);

    return Container(
      decoration: BoxDecoration(
        color: selected
            // ignore: deprecated_member_use
            ? AppTheme.getCardColor(context).withOpacity(0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(
          color: selected
              // ignore: deprecated_member_use
              ? AppTheme.accentBlue.withOpacity(0.45)
              : AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: padM, vertical: padS),
      child: Row(
        children: [
          leading,
          SizedBox(width: padS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + badge “Activo”
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.getBodyMedium(screenSize).copyWith(
                          color: AppTheme.getTextPrimaryColor(context),
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: padS * 0.8,
                          vertical: padS * 0.4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.accentBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(padS),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: AppTheme.accentBlue.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Activo',
                          style: AppTheme.getCaption(screenSize).copyWith(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: padS * 0.5),
                Text(
                  subtitle,
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
