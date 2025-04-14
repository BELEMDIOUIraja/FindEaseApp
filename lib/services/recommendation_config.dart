// lib/services/recommendation_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RecommendationConfig {
  // Constantes pour la configuration
  static const Map<String, double> INTERACTION_WEIGHTS = {
    'view': 1.0,
    'click': 2.0,
    'favorite': 5.0,
    'booking': 10.0
  };

  static const Map<String, dynamic> WORLD_CUP_INFO = {
    'hostCountries': ['Maroc', 'Espagne', 'Portugal'],
    'mainStadiums': {
      'Maroc': ['Stade Mohammed V', 'Grand Stade de Casablanca', 'Stade de Rabat'],
      'Espagne': ['Santiago Bernabéu', 'Camp Nou', 'Metropolitano'],
      'Portugal': ['Estádio da Luz', 'Estádio do Dragão', 'Estádio José Alvalade']
    },
  };

  // Initialise le système de recommandation
  static Future<bool> initRecommendationSystem() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Créer un document de configuration
      await firestore.collection('AppConfig').doc('recommendationSystem').set({
        'initialized': true,
        'version': '1.0.0',
        'lastUpdated': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));

      debugPrint('Système de recommandation initialisé avec succès');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du système de recommandation: $e');
      return false;
    }
  }
}