import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  StudentProfileModel? _studentProfile;
  LecturerProfileModel? _lecturerProfile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  StudentProfileModel? get studentProfile => _studentProfile;
  LecturerProfileModel? get lecturerProfile => _lecturerProfile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> loadStudentProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getStudentProfile();
      _studentProfile = StudentProfileModel.fromJson(data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLecturerProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getLecturerProfile();
      _lecturerProfile = LecturerProfileModel.fromJson(data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String? fullName, String? phone) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _service.updateProfile(fullName, phone);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }
}