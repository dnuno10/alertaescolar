import 'package:alertaescolar/app/app_theme.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DigitalCredentialCard extends StatelessWidget {
  final StudentDetails student;
  final Size screenSize;
  final String schoolName;

  const DigitalCredentialCard({
    super.key,
    required this.student,
    required this.screenSize,
    this.schoolName = '-',
  });

  String get _name =>
      (student.nombre).trim().isEmpty ? '-' : student.nombre.trim();
  String get _matricula =>
      (student.matricula).trim().isEmpty ? '-' : student.matricula.trim();
  String get _grupo =>
      (student.grupo).trim().isEmpty ? 'Sin asignar' : student.grupo.trim();
  String get _turno => ((student.turno) ?? '').trim().isEmpty
      ? 'Sin asignar'
      : student.turno!.trim();
  String get _school => schoolName.trim().isEmpty ? '-' : schoolName.trim();

  @override
  Widget build(BuildContext context) {
    // Colores profesionales
    const primaryColor = AppTheme.accentBlue; // Azul institucional
    const accentColor = Color(0xFF059669); // Verde para validación
    const textDark = Color(0xFF0F172A);
    const textLight = Color(0xFF475569);
    const bgCard = Color(0xFFFAFAFA);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 380,
          height: 750,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            children: [
              // Header Simple
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'images/alertaescolar_logo.png',
                      width: 140,
                      height: 60,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _school.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CREDENCIAL ESTUDIANTIL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido Principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del estudiante
                      Text(
                        'ESTUDIANTE',
                        style: TextStyle(
                          color: textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _name.toUpperCase(),
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Información académica en grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'MATRÍCULA',
                              _matricula,
                              Icons.badge_outlined,
                              textDark,
                              textLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'GRUPO',
                              _grupo,
                              Icons.groups_outlined,
                              textDark,
                              textLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        'TURNO',
                        _turno,
                        Icons.schedule_outlined,
                        textDark,
                        textLight,
                        fullWidth: true,
                      ),

                      SizedBox(height: 32),

                      // QR Code centrado
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgCard,
                                borderRadius: BorderRadius.circular(32),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: QrImageView(
                                data: _matricula,
                                version: QrVersions.auto,
                                size: 170,
                                gapless: true,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: textDark,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Código de acceso',
                              style: TextStyle(
                                color: textLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer minimal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      'VÁLIDA • CICLO 2025-2026',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color textDark,
    Color textLight, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1E40AF)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textLight,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
