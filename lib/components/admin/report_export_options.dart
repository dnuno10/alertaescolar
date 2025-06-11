import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../components/buttons/solid_button.dart';

class ReportExportOptions extends StatelessWidget {
  final Size screenSize;

  const ReportExportOptions({
    super.key,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.getLargeRadius(screenSize)),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  Icons.file_download_rounded,
                  color: AppTheme.accentPurple,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(screenSize)),
              Text(
                l10n.exportReport,
                style: AppTheme.getH2(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Text(
            l10n.selectExportFormat ?? 'Seleccione el formato de exportación',
            style: AppTheme.getCaption(screenSize).copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          // Export options
          Row(
            children: [
              Expanded(
                child: _ExportOptionCard(
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'PDF',
                  description: l10n.pdfExportDesc ?? 'Documento PDF para imprimir',
                  color: AppTheme.errorColor,
                  onTap: () => _exportAsPDF(context, l10n),
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _ExportOptionCard(
                  icon: Icons.table_chart_rounded,
                  title: 'Excel',
                  description: l10n.excelExportDesc ?? 'Hoja de cálculo Excel',
                  color: AppTheme.successColor,
                  onTap: () => _exportAsExcel(context, l10n),
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(screenSize)),

          Row(
            children: [
              Expanded(
                child: _ExportOptionCard(
                  icon: Icons.image_rounded,
                  title: 'PNG',
                  description: l10n.imageExportDesc ?? 'Imagen para presentaciones',
                  color: AppTheme.accentBlue,
                  onTap: () => _exportAsImage(context, l10n),
                  screenSize: screenSize,
                ),
              ),
              SizedBox(width: AppTheme.getMediumPadding(screenSize)),
              Expanded(
                child: _ExportOptionCard(
                  icon: Icons.share_rounded,
                  title: l10n.share,
                  description: l10n.shareReportDesc ?? 'Compartir reporte directamente',
                  color: AppTheme.accentPurple,
                  onTap: () => _shareReport(context, l10n),
                  screenSize: screenSize,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getLargePadding(screenSize)),

          // Generate Report Button
          SolidButton(
            backgroundColor: AppTheme.accentPurple,
            onPressed: () => _generateReport(context, l10n),
            label: l10n.generateReport,
            icon: Icons.analytics_rounded,
            screenSize: screenSize,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(BuildContext context, AppLocalizations l10n) {
    _showExportDialog(context, l10n, 'PDF');
  }

  void _exportAsExcel(BuildContext context, AppLocalizations l10n) {
    _showExportDialog(context, l10n, 'Excel');
  }

  void _exportAsImage(BuildContext context, AppLocalizations l10n) {
    _showExportDialog(context, l10n, 'PNG');
  }

  void _shareReport(BuildContext context, AppLocalizations l10n) {
    _showExportDialog(context, l10n, 'Compartir');
  }

  void _generateReport(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          l10n.generateReport,
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.reportGenerationConfirm ?? '¿Desea generar el reporte con los filtros seleccionados?',
          style: AppTheme.getBodyMedium(screenSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar(context, l10n, l10n.reportGenerated ?? 'Reporte generado exitosamente');
            },
            child: Text(
              l10n.generate ?? 'Generar',
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppLocalizations l10n, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        ),
        title: Text(
          '${l10n.exportAs ?? 'Exportar como'} $format',
          style: AppTheme.getSubtitle1(screenSize).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${l10n.exportConfirm ?? 'El reporte será exportado en formato'} $format',
          style: AppTheme.getBodyMedium(screenSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateExport(context, l10n, format);
            },
            child: Text(
              l10n.export ?? 'Exportar',
              style: AppTheme.getCaption(screenSize).copyWith(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateExport(BuildContext context, AppLocalizations l10n, String format) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.exporting ?? 'Exportando'} $format...',
          style: AppTheme.getCaption(screenSize).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.accentBlue,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      _showSuccessSnackBar(
        context, 
        l10n, 
        '${l10n.exportedSuccessfully ?? 'Exportado exitosamente en formato'} $format'
      );
    }
  }

  void _showSuccessSnackBar(BuildContext context, AppLocalizations l10n, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.getCaption(screenSize).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
        ),
      ),
    );
  }
}

class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final Size screenSize;

  const _ExportOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
        child: Container(
          padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize) * 0.75),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTheme.getSmallRadius(screenSize)),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenSize.height * 0.025,
                ),
              ),
              SizedBox(height: AppTheme.getSmallPadding(screenSize)),
              Text(
                title,
                style: AppTheme.getCaption(screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
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
      ),
    );
  }
}
