import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DangerZoneCard extends StatefulWidget {
  final AppLocalizations l10n;
  final Size screenSize;
  final Future<void> Function()? onDelete;

  const DangerZoneCard({
    super.key,
    required this.l10n,
    required this.screenSize,
    this.onDelete,
  });

  @override
  State<DangerZoneCard> createState() => _DangerZoneCardState();
}

class _DangerZoneCardState extends State<DangerZoneCard> {
  bool _isLoading = false;

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.getMediumRadius(widget.screenSize),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppTheme.errorColor,
              size: widget.screenSize.width * 0.06,
            ),
            SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
            Text(
              widget.l10n.deleteAccount,
              style: AppTheme.getSubtitle1(widget.screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.l10n.deleteAccountWarning,
              style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
            Container(
              padding:
                  EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize),
                ),
              ),
              child: Text(
                widget.l10n.deleteAccountDesc,
                style: AppTheme.getCaption(widget.screenSize).copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
            child: Text(
              widget.l10n.cancel,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
              if (widget.onDelete != null) {
                setState(() => _isLoading = true);
                await widget.onDelete!();
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(widget.screenSize),
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.l10n.deleteAccount,
              style: AppTheme.getCaption(widget.screenSize).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(widget.screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(widget.screenSize)),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: AppTheme.errorColor,
                size: widget.screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Text(
                widget.l10n.dangerZone,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
          Text(
            widget.l10n.dangerZoneDesc,
            style: AppTheme.getCaption(widget.screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
          Container(
            padding:
                EdgeInsets.all(AppTheme.getSmallPadding(widget.screenSize)),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppTheme.getSmallRadius(widget.screenSize),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.errorColor,
                  size: widget.screenSize.width * 0.05,
                ),
                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.deleteAccount,
                        style:
                            AppTheme.getSubtitle2(widget.screenSize).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      SizedBox(height: widget.screenSize.height * 0.003),
                      Text(
                        widget.l10n.deleteAccountDesc,
                        style: AppTheme.getCaption(widget.screenSize).copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _showDeleteAccountDialog();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.getSmallPadding(widget.screenSize),
                      vertical:
                          AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.l10n.delete,
                    style: AppTheme.getCaption(widget.screenSize).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
