import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ExportOptionsCard extends StatelessWidget {
  final Size screenSize;
  final ValueChanged<String> onExportSelected;

  const ExportOptionsCard({
    super.key,
    required this.screenSize,
    required this.onExportSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getShadowColor(context),
            blurRadius: screenSize.height * 0.015,
            offset: Offset(0, screenSize.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.file_download_rounded,
                color: AppTheme.accentBlue,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.exportAs,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Export Options
          Row(
            children: [
              Expanded(
                child: _buildExportOption(
                  context,
                  'PDF',
                  l10n.pdfExportDesc,
                  Icons.picture_as_pdf_rounded,
                  AppTheme.errorColor,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildExportOption(
                  context,
                  'Excel',
                  l10n.excelExportDesc,
                  Icons.table_chart_rounded,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          Row(
            children: [
              Expanded(
                child: _buildExportOption(
                  context,
                  'Image',
                  l10n.imageExportDesc,
                  Icons.image_rounded,
                  AppTheme.accentPurple,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Expanded(
                child: _buildExportOption(
                  context,
                  'Share',
                  l10n.shareReportDesc,
                  Icons.share_rounded,
                  AppTheme.accentBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String format,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => onExportSelected(format),
      child: Container(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: screenSize.width * 0.08,
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize)),
            Text(
              format,
              style: AppTheme.getBodyMedium(screenSize).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),
            Text(
              description,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
