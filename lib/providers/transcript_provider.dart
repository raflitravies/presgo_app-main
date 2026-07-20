import 'package:flutter/material.dart';
import '../models/transcript_model.dart';
import '../services/transcript_service.dart';

class TranscriptProvider extends ChangeNotifier {
  final TranscriptService _service = TranscriptService();

  TranscriptModel? _transcript;
  bool _isLoading = false;
  String? _errorMessage;

  TranscriptModel? get transcript => _transcript;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTranscript() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transcript = await _service.getMyTranscript();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}