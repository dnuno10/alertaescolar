import 'package:alertaescolar/components/headers/nav_header.dart';
import 'package:alertaescolar/components/buttons/solid_button.dart';
import 'package:alertaescolar/components/tips_cards/student_edit_info_card.dart';
import 'package:alertaescolar/components/students/student_profile_card.dart';
import 'package:alertaescolar/components/students/student_academic_info_card.dart';
import 'package:alertaescolar/components/students/student_key_info_card.dart';
import 'package:alertaescolar/components/students/student_action_buttons.dart';
import 'package:alertaescolar/managers/student_provider.dart';
import 'package:alertaescolar/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../app/app_theme.dart';
import '../schedule/schedule_view.dart';
import '../school/school_info_view.dart';

class StudentDetailView extends StatelessWidget {
  final Alumno student;

  const StudentDetailView({
    super.key,
    required this.student,
  });

  // Convert Alumno to StudentDetails
  StudentDetails _convertToStudentDetails(Alumno alumno) {
    return StudentDetails(
      id: alumno.id ?? '',
      nombre: alumno.nombre,
      matricula: alumno.matricula ?? '',
      escuelaId: alumno.id_escuela ?? '',
      grupoId: alumno.id_grupo ?? '',
      grupo: alumno.grupo ?? '',
      nivelEducativo: '', // Will be populated from database joins
      turnoId: null,
      turno: alumno.turno.toString().split('.').last,
      llaveId: alumno.id_llave,
      llaveCodigo: null,
      llaveActiva: alumno.vinculado,
      fechaRegistro: alumno.fecha_registro ?? DateTime.now(),
      fechaRegistroLlave: null,
      limiteVinculacion: null,
      tutores: [],
      familyContacts: [], // Add this field
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final studentDetails = _convertToStudentDetails(student);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(student.nombre),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
        child: Column(children: [
          StudentProfileCard(
            color: AppTheme.accentBlue,
            student: studentDetails,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          StudentAcademicInfoCard(
            student: studentDetails,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          StudentKeyInfoCard(
            student: studentDetails,
            screenSize: screenSize,
          ),
          SizedBox(height: AppTheme.getMediumPadding(screenSize)),
          StudentActionButtons(
            student: studentDetails,
            screenSize: screenSize,
          )
        ]),
      ),
    );
  }
}
