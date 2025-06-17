import 'package:alertaescolar/main.dart';
import 'package:alertaescolar/models/escuela.dart';
import 'package:flutter/material.dart';
import 'package:alertaescolar/components/loading_dialog.dart';
import 'package:alertaescolar/l10n/app_localizations.dart';

class SchoolProvider with ChangeNotifier {
  Escuela? _currentSchool;
  bool _isLoading = false;
  String? _error;

  Escuela? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Escuela?> getSchoolById(String schoolId, BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    // Remove LoadingDialog from here since it's already shown in the calling method
    try {
      _isLoading = true;
      notifyListeners();

      final response =
          await supabase.from('escuelas').select().eq('id', schoolId).single();

      if (response != null) {
        final school = Escuela.fromJson(response);
        return school;
      }
    } catch (e) {
      _error = '${l10n.errorFetchingSchool}: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<Escuela?> loadSchool(String schoolId,
      {required BuildContext context}) async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.loading);
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabase.from('escuelas').select().eq('id', schoolId).single();

      if (response != null) {
        _currentSchool = Escuela.fromJson(response);
      }
    } catch (e) {
      _error = '${l10n.errorLoadingSchool}: $e';
    } finally {
      LoadingDialog.hide(context);

      _isLoading = false;
      notifyListeners();
    }
    return _currentSchool;
  }

  Future<bool> updateSchool(Escuela updatedSchool,
      {required BuildContext context}) async {
    final l10n = AppLocalizations.of(context);
    LoadingDialog.show(context, message: l10n.updatingSchoolInformation);
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabase
          .from('escuelas')
          .update(
            updatedSchool.toJson(),
          )
          .eq('id', updatedSchool.id);

      _currentSchool = updatedSchool;
      return true;
    } catch (e) {
      _error = '${l10n.errorUpdatingSchool}: $e';
      return false;
    } finally {
      LoadingDialog.hide(context);
      _isLoading = false;
      notifyListeners();
    }
  }
}
