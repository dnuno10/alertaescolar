import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../managers/student_provider.dart';

class StudentFamilyInfoCard extends StatefulWidget {
  final StudentDetails student;
  final Size screenSize;

  const StudentFamilyInfoCard({
    super.key,
    required this.student,
    required this.screenSize,
  });

  @override
  State<StudentFamilyInfoCard> createState() => _StudentFamilyInfoCardState();
}

class _StudentFamilyInfoCardState extends State<StudentFamilyInfoCard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _familyContacts = [];
  bool _isLoading = true;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    // Don't load data here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadFamilyContacts();
    }
  }

  Future<void> _loadFamilyContacts() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      // Step 1: Get tutor IDs from alumno_tutores table using student ID
      final tutorResponse = await _supabase
          .from('alumno_tutores')
          .select('id_tutor')
          .eq('id_alumno', widget.student.id);

      if (tutorResponse.isEmpty) {
        if (mounted) {
          setState(() {
            _familyContacts = [];
            _isLoading = false;
          });
        }
        return;
      }

      // Step 2: Extract tutor IDs
      final tutorIds =
          tutorResponse.map((record) => record['id_tutor']).toList();

      // Step 3: Get family contacts using id_usuario (not id_tutor)
      final contactsResponse = await _supabase
          .from('contactos_familiares')
          .select('*')
          .inFilter('id_usuario', tutorIds)
          .order('fecha_registro');

      if (mounted) {
        setState(() {
          _familyContacts = List<Map<String, dynamic>>.from(contactsResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading family contacts: $e');
      if (mounted) {
        setState(() {
          _familyContacts = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
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
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.getTextPrimaryColor(context),
              ),
              SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),
              Text(
                l10n.loadingFamilyContacts,
                style: AppTheme.getBodyMedium(widget.screenSize).copyWith(
                  color: AppTheme.getTextPrimaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize)),
                ),
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: AppTheme.accentPurple,
                  size: widget.screenSize.height * 0.025,
                ),
              ),
              SizedBox(width: AppTheme.getSmallPadding(widget.screenSize)),
              Expanded(
                child: Text(
                  l10n.familyContacts,
                  style: AppTheme.getH2(widget.screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      AppTheme.getSmallPadding(widget.screenSize) * 0.75,
                  vertical: AppTheme.getSmallPadding(widget.screenSize) * 0.5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppTheme.getSmallRadius(widget.screenSize) * 0.5),
                ),
                child: Text(
                  '${_familyContacts.length} ${l10n.contacts}',
                  style: AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getMediumPadding(widget.screenSize)),

          // Family Members List
          if (_familyContacts.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(
                    AppTheme.getMediumPadding(widget.screenSize)),
                child: Text(
                  'No hay contactos familiares registrados',
                  style: AppTheme.getCaption(widget.screenSize).copyWith(
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ),
            )
          else
            ..._familyContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _FamilyMemberItem(
                member: contact,
                screenSize: widget.screenSize,
                isLast: index == _familyContacts.length - 1,
                l10n: l10n,
              );
            }),

          SizedBox(height: AppTheme.getSmallPadding(widget.screenSize)),
        ],
      ),
    );
  }
}

class _FamilyMemberItem extends StatelessWidget {
  final Map<String, dynamic> member;
  final Size screenSize;
  final bool isLast;
  final AppLocalizations l10n;

  const _FamilyMemberItem({
    required this.member,
    required this.screenSize,
    required this.isLast,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : AppTheme.getMediumPadding(screenSize),
      ),
      padding: EdgeInsets.all(AppTheme.getSmallPadding(screenSize)),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(AppTheme.getMediumRadius(screenSize)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and relationship
          Row(
            children: [
              Expanded(
                child: Text(
                  member['nombre']?.toString() ?? 'Sin nombre',
                  style: AppTheme.getSubtitle1(screenSize).copyWith(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          // Relationship
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.getSmallPadding(screenSize) * 0.75,
              vertical: AppTheme.getSmallPadding(screenSize) * 0.25,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  AppTheme.getSmallRadius(screenSize) * 0.5),
            ),
            child: Text(
              member['parentesco']?.toString() ?? 'Sin parentesco',
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Contact Information
          if (member['telefono'] != null)
            _ContactRow(
              icon: Icons.phone_rounded,
              label: l10n.phone,
              value: member['telefono'].toString(),
              screenSize: screenSize,
              color: AppTheme.successColor,
            ),

          if (member['telefono'] != null && member['email'] != null)
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          if (member['email'] != null)
            _ContactRow(
              icon: Icons.email_rounded,
              label: 'Email',
              value: member['email'].toString(),
              screenSize: screenSize,
              color: AppTheme.accentBlue,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Size screenSize;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.screenSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: screenSize.height * 0.018,
        ),
        SizedBox(width: AppTheme.getSmallPadding(screenSize) * 0.5),
        Text(
          '$label: ',
          style: AppTheme.getCaptionSmall(screenSize).copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.getCaptionSmall(screenSize).copyWith(
              color: AppTheme.getTextPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
