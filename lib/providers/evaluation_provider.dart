import 'package:flutter/material.dart';
import '../models/evaluation_model.dart';
import '../services/evaluation_service.dart';

class EvaluationProvider extends ChangeNotifier {
  final EvaluationService _service = EvaluationService();

  List<EvaluationCourseModel> _pendingEvaluations = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<EvaluationCourseModel> get pendingEvaluations => _pendingEvaluations;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingEvaluations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingEvaluations = await _service.getMyPendingEvaluations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitEvaluation(
      int offeringId, List<Map<String, dynamic>> responses) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.submitEvaluation(offeringId, responses);
      // Hapus dari list setelah submit
      _pendingEvaluations.removeWhere((e) => e.offeringId == offeringId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}