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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _primeFromStudentOrLoad();
    }
  }

  void _primeFromStudentOrLoad() {
    // Si ya viene precargado desde el Provider, úsalo y evita una ida a red
    if (widget.student.familyContacts.isNotEmpty) {
      _familyContacts =
          List<Map<String, dynamic>>.from(widget.student.familyContacts);
      _sortContactsInPlace(_familyContacts);
      setState(() => _isLoading = false);
    } else {
      _loadFamilyContacts();
    }
  }

  Future<void> _loadFamilyContacts() async {
    if (!mounted) return;
    try {
      setState(() => _isLoading = true);

      // Única consulta: alumno_tutores -> usuarios.contactos_familiares
      final resp = await _supabase.from('alumno_tutores').select('''
        usuarios!inner(
          contactos_familiares(
            id,
            id_usuario,
            nombre,
            parentesco,
            telefono,
            email,
            fecha_registro
          )
        )
      ''').eq('id_alumno', widget.student.id);

      final List<Map<String, dynamic>> flattened = [];
      for (final row in (resp as List)) {
        final usr = row['usuarios'];
        final contacts = (usr?['contactos_familiares'] as List?) ?? const [];
        for (final c in contacts) {
          flattened.add(Map<String, dynamic>.from(c as Map));
        }
      }

      _sortContactsInPlace(flattened);

      if (!mounted) return;
      setState(() {
        _familyContacts = flattened;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading family contacts: $e');
      if (!mounted) return;
      setState(() {
        _familyContacts = [];
        _isLoading = false;
      });
    }
  }

  void _sortContactsInPlace(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      final sa = (a['fecha_registro'] ?? '')?.toString();
      final sb = (b['fecha_registro'] ?? '')?.toString();
      if (sa!.isEmpty && sb!.isEmpty) return 0;
      if (sa!.isEmpty) return 1; // nulls last
      if (sb!.isEmpty) return -1;
      return sa.compareTo(sb);
    });
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
              // Contador + refresh
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
                child: Row(
                  children: [
                    Text(
                      '${_familyContacts.length} ${l10n.contacts}',
                      style:
                          AppTheme.getCaptionSmall(widget.screenSize).copyWith(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        width: AppTheme.getSmallPadding(widget.screenSize)),
                    InkWell(
                      onTap: _loadFamilyContacts,
                      borderRadius: BorderRadius.circular(
                        AppTheme.getSmallRadius(widget.screenSize),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          AppTheme.getSmallPadding(widget.screenSize) * 0.25,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: widget.screenSize.height * 0.022,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
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
                  l10n.noFamilyContactsRegistered,
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
    final nombre = (member['nombre'] ?? '').toString().trim();
    final parentesco = (member['parentesco'] ?? '').toString().trim();
    final telefono = (member['telefono'] ?? '').toString().trim();
    final email = (member['email'] ?? '').toString().trim();

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
          // Name
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre.isEmpty ? l10n.noName : nombre,
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
              parentesco.isEmpty ? l10n.noRelationship : parentesco,
              style: AppTheme.getCaptionSmall(screenSize).copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: AppTheme.getSmallPadding(screenSize)),

          // Contact Information
          if (telefono.isNotEmpty)
            _ContactRow(
              icon: Icons.phone_rounded,
              label: l10n.phone,
              value: telefono,
              screenSize: screenSize,
              color: AppTheme.successColor,
            ),

          if (telefono.isNotEmpty && email.isNotEmpty)
            SizedBox(height: AppTheme.getSmallPadding(screenSize) * 0.5),

          if (email.isNotEmpty)
            _ContactRow(
              icon: Icons.email_rounded,
              label: 'Email',
              value: email,
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
