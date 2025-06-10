import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_student_service.dart';

class StudentProvider extends ChangeNotifier {
  List<Alumno> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Alumno> get students => List.unmodifiable(_students);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStudents => _students.isNotEmpty;
  int get studentsCount => _students.length;

  final MockStudentService _studentService = MockStudentService();

  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentService.getStudents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(Alumno student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newStudent = await _studentService.addStudent(student);
      _students.add(newStudent);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(Alumno student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedStudent = await _studentService.updateStudent(student);
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = updatedStudent;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeStudent(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _studentService.removeStudent(studentId);
      _students.removeWhere((s) => s.id == studentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Alumno? getStudentById(String id) {
    try {
      return _students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }
}
