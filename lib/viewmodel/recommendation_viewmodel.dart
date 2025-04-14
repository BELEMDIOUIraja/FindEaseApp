// lib/viewmodel/recommendation_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../model/property.dart'; // Adaptez selon votre modèle de propriété
import '../services/recommendation_service.dart';
import '../services/user_interaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class RecommendationViewModel extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  final UserInteractionService _interactionService = UserInteractionService();
  // Ajouter dans la classe RecommendationViewModel dans recommendation_viewmodel.dart

  Future<void> refreshAll(String userId) async {
    _error = null;
    notifyListeners();

    try {
      // Si un utilisateur est connecté, recharger toutes les recommandations
      if (userId.isNotEmpty) {
        await loadAllRecommendations(userId);
      } else {
        // Sinon, recharger uniquement les propriétés populaires
        await loadPopularProperties();
      }
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement des recommandations: $e');
      _error = 'Impossible de rafraîchir les recommandations';
      notifyListeners();
    }
  }
  Future<bool> checkIsFavorite(String userId, String propertyId) async {
    try {
      // Vérifier dans Firestore si la propriété est en favoris
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('UserInteractions')
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .where('interactionType', isEqualTo: 'favorite')
          .limit(1)
          .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }
  // Propriétés observables
  List<Property> _personalizedRecommendations = [];
  List<Property> _similarProperties = [];
  List<Property> _worldCupRecommendations = [];
  List<Property> _popularProperties = [];

  bool _isLoadingPersonalized = false;
  bool _isLoadingSimilar = false;
  bool _isLoadingWorldCup = false;
  bool _isLoadingPopular = false;

  String? _error;
  Map<String, dynamic> _currentFilters = {};

  // Getters
  List<Property> get personalizedRecommendations => _personalizedRecommendations;
  List<Property> get similarProperties => _similarProperties;
  List<Property> get worldCupRecommendations => _worldCupRecommendations;
  List<Property> get popularProperties => _popularProperties;
  bool get isLoadingPersonalized => _isLoadingPersonalized;
  bool get isLoadingSimilar => _isLoadingSimilar;
  bool get isLoadingWorldCup => _isLoadingWorldCup;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoading => _isLoadingPersonalized || _isLoadingSimilar || _isLoadingWorldCup || _isLoadingPopular;

  String? get error => _error;

  // Méthodes
  Future<void> loadPersonalizedRecommendations(String userId, {int limit = 10}) async {
    if (_isLoadingPersonalized) return;

    _isLoadingPersonalized = true;
    _error = null;
    notifyListeners();

    try {
      final recommendations = await _recommendationService.getRecommendationsForUser(
          userId,
          limit: limit,
          options: _currentFilters
      );

      _personalizedRecommendations = recommendations;
    } catch (e) {
      debugPrint('Erreur lors du chargement des recommandations personnalisées: $e');
      _error = 'Impossible de charger les recommandations personnalisées';
    } finally {
      _isLoadingPersonalized = false;
      notifyListeners();
    }
  }

  Future<void> loadSimilarProperties(String propertyId, {int limit = 5}) async {
    if (_isLoadingSimilar) return;

    _isLoadingSimilar = true;
    _error = null;
    notifyListeners();

    try {
      final properties = await _recommendationService.getSimilarProperties(
          propertyId,
          limit: limit
      );

      _similarProperties = properties;
    } catch (e) {
      debugPrint('Erreur lors du chargement des propriétés similaires: $e');
      _error = 'Impossible de charger les propriétés similaires';
    } finally {
      _isLoadingSimilar = false;
      notifyListeners();
    }
  }

  Future<void> loadWorldCupRecommendations(
      String userId, {
        String? hostCountry,
        String? stadiumNearby,
        DateTime? matchDate,
        int limit = 10
      }) async {
    if (_isLoadingWorldCup) return;

    _isLoadingWorldCup = true;
    _error = null;
    notifyListeners();

    try {
      final recommendations = await _recommendationService.getWorldCupRecommendations(
          userId,
          hostCountry: hostCountry,
          stadiumNearby: stadiumNearby,
          matchDate: matchDate,
          limit: limit
      );

      _worldCupRecommendations = recommendations;
    } catch (e) {
      debugPrint('Erreur lors du chargement des recommandations Coupe du Monde: $e');
      _error = 'Impossible de charger les recommandations pour la Coupe du Monde';
    } finally {
      _isLoadingWorldCup = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularProperties({int limit = 10}) async {
    if (_isLoadingPopular) return;

    _isLoadingPopular = true;
    _error = null;
    notifyListeners();

    try {
      final properties = await _recommendationService.getPopularProperties(limit);
      _popularProperties = properties;
    } catch (e) {
      debugPrint('Erreur lors du chargement des propriétés populaires: $e');
      _error = 'Impossible de charger les propriétés populaires';
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> trackPropertyClick(String userId, String propertyId, Map<String, dynamic> contextInfo) async {
    try {
      await _interactionService.trackInteraction(
          userId,
          propertyId,
          'click',
          contextInfo: contextInfo
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement du clic: $e');
    }
  }


  Future<String?> trackPropertyView(String userId, String propertyId) async {
    try {
      final interactionId = await _interactionService.trackInteraction(
          userId,
          propertyId,
          'view'
      );
      return interactionId;
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de la visualisation: $e');
      return null;
    }
  }
  /// Supprime une propriété des favoris d'un utilisateur
  Future<void> removeFromFavorites(String userId, String propertyId) async {
    try {
      // Trouver l'interaction de type 'favorite' existante
      final querySnapshot = await FirebaseFirestore.instance
          .collection('UserInteractions')
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .where('interactionType', isEqualTo: 'favorite')
          .limit(1)
          .get();

      // Supprimer le document trouvé
      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('UserInteractions')
            .doc(querySnapshot.docs.first.id)
            .delete();
      }

      // Mettre à jour l'interface utilisateur si nécessaire
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression des favoris: $e');
      _error = 'Impossible de supprimer des favoris';
      notifyListeners();
    }
  }

  Future<void> updateViewDuration(String interactionId, String userId, String propertyId) async {
    try {
      await _interactionService.updateViewDuration(interactionId, userId, propertyId);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la durée: $e');
    }
  }

  Future<void> addToFavorites(String userId, String propertyId) async {
    try {
      await _interactionService.trackInteraction(
          userId,
          propertyId,
          'favorite'
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout aux favoris: $e');
      _error = 'Impossible d\'ajouter aux favoris';
      notifyListeners();
    }
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _currentFilters = filters;

    // Recharger les recommandations avec les nouveaux filtres
    final userId = 'guest'; // Remplacer par l'ID utilisateur actuel si disponible
    await loadAllRecommendations(userId);

    notifyListeners();
  }

  Future<void> loadAllRecommendations(String userId, {String? currentPropertyId}) async {
    try {
      // Charger les recommandations personnalisées
      loadPersonalizedRecommendations(userId);

      // Charger les recommandations pour la Coupe du Monde
      loadWorldCupRecommendations(userId);

      // Charger les propriétés populaires
      loadPopularProperties();

      // Charger les propriétés similaires si un ID de propriété est fourni
      if (currentPropertyId != null) {
        loadSimilarProperties(currentPropertyId);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de toutes les recommandations: $e');
      _error = 'Impossible de charger certaines recommandations';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}