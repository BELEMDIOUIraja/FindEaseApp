// lib/viewmodel/match_reference_viewmodel.dart
import 'package:flutter/material.dart';
import '../model/match_reference.dart';

class MatchReferenceViewModel extends ChangeNotifier {
  final MatchReference _matchReference = MatchReference();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  MatchReference get matchReference => _matchReference;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters qui notifient les listeners (Vue)
  void setMatchDate(String value) {
    _matchReference.matchDate = value;
    notifyListeners();
  }

  void setMatchZone(String value) {
    _matchReference.matchZone = value;
    notifyListeners();
  }

  void setUserName(String value) {
    _matchReference.userName = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _matchReference.phoneNumber = value;
    notifyListeners();
  }

  void setBudget(String value) {
    _matchReference.budget = value;
    notifyListeners();
  }

  Future<bool> submitForm() async {
    // Validation basique
    if (_matchReference.matchDate == null || _matchReference.matchDate!.isEmpty ||
        _matchReference.matchZone == null || _matchReference.matchZone!.isEmpty ||
        _matchReference.userName == null || _matchReference.userName!.isEmpty ||
        _matchReference.phoneNumber == null || _matchReference.phoneNumber!.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs obligatoires';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Ici, vous pouvez ajouter la logique pour envoyer les données à un backend
      // Par exemple:
      // final result = await apiService.submitMatchReference(_matchReference);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Une erreur s\'est produite: $e';
      notifyListeners();
      return false;
    }
  }
}