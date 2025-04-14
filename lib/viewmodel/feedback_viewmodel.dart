// lib/viewmodel/feedback_viewmodel.dart
import 'package:flutter/material.dart';

class FeedbackViewModel extends ChangeNotifier {
  String? _feedbackText;
  int? _emojiRating;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _showBigEmoji = false;

  // Getters
  String? get feedbackText => _feedbackText;
  int? get emojiRating => _emojiRating;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get showBigEmoji => _showBigEmoji;

  // Setters qui notifient les listeners (Vue)
  void setFeedbackText(String value) {
    _feedbackText = value;
    notifyListeners();
  }

  void setEmojiRating(int value) {
    _emojiRating = value;
    _showBigEmoji = true;
    notifyListeners();

    // Masquer le grand emoji après un délai
    Future.delayed(const Duration(milliseconds: 1500), () {
      _showBigEmoji = false;
      notifyListeners();
    });
  }

  Future<bool> submitFeedback() async {
    // Validation de base
    if (_emojiRating == null) {
      _errorMessage = 'Veuillez sélectionner une émotion';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Ici, vous pouvez ajouter la logique pour envoyer les données à un backend
      // Par exemple:
      // final result = await apiService.submitFeedback(_feedbackText, _emojiRating);

      _isSubmitting = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Une erreur s\'est produite: $e';
      notifyListeners();
      return false;
    }
  }
}