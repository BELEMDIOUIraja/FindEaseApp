// lib/services/recommendation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/property.dart';
import '../model/user_interaction.dart';
import '../model/user_preferences.dart';
import './recommendation_config.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Références aux collections Firestore
  CollectionReference get _properties => _firestore.collection('Properties');
  CollectionReference get _userInteractions => _firestore.collection('UserInteractions');
  CollectionReference get _userPreferences => _firestore.collection('UserPreferences');
  CollectionReference get _propertyCorrelations => _firestore.collection('PropertyCorrelations');

  /// Génère des recommandations personnalisées pour un utilisateur
  ///
  /// [userId] - ID de l'utilisateur
  /// [limit] - Nombre maximum de recommandations à retourner
  /// [options] - Options de filtrage pour les recommandations
  Future<List<Property>> getRecommendationsForUser(
      String userId, {
        int limit = 10,
        Map<String, dynamic> options = const {},
      }) async {
    try {
      // 1. Récupérer le profil d'intérêt de l'utilisateur
      final userProfile = await _getUserProfile(userId);

      // 2. Si nous n'avons pas assez de données sur l'utilisateur,
      // utiliser les recommandations populaires ou basées sur ses préférences explicites
      if (userProfile == null ||
          userProfile['interactedPropertyTypes'] == null ||
          userProfile['interactedPropertyTypes'].isEmpty) {
        return await _getFallbackRecommendations(userId, limit, options);
      }

      // 3. Construire la requête pour récupérer des propriétés similaires
      Query query = _buildRecommendationQuery(userProfile, options);

      // 4. Récupérer les propriétés recommandées
      final querySnapshot = await query.limit(limit).get();
      final List<Property> recommendedProperties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // 5. Exclure les propriétés que l'utilisateur a déjà vues récemment
      final recentlyViewedIds = await _getRecentlyViewedPropertyIds(userId);
      final filteredRecommendations = recommendedProperties
          .where((property) => !recentlyViewedIds.contains(property.id))
          .toList();

      // Si on a filtré trop de propriétés, compléter avec d'autres recommandations
      if (filteredRecommendations.length < limit ~/ 2) {
        final additionalProperties = await _getAdditionalRecommendations(
            userId,
            limit - filteredRecommendations.length,
            [...recentlyViewedIds, ...filteredRecommendations.map((p) => p.id)]
        );

        return [...filteredRecommendations, ...additionalProperties];
      }

      return filteredRecommendations;
    } catch (e) {
      debugPrint('Erreur lors de la génération des recommandations: $e');
      return await _getFallbackRecommendations(userId, limit, options);
    }
  }
  /// Méthode pour obtenir les propriétés populaires
  Future<List<Property>> getPopularProperties(int limit) async {
    try {
      // Récupérer les propriétés les mieux notées
      final querySnapshot = await _properties
          .orderBy('rating', descending: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit)
          .get();

      // Convertir les documents en objets Property
      return querySnapshot.docs.map((doc) {
        return Property.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des propriétés populaires: $e');
      return [];
    }
  }


  /// Récupère le profil d'intérêt d'un utilisateur basé sur ses interactions
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      // 1. Récupérer les interactions de l'utilisateur
      final querySnapshot = await _userInteractions
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final interactions = querySnapshot.docs
          .map((doc) => UserInteraction.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (interactions.isEmpty) {
        return null;
      }

      // 2. Récupérer les propriétés correspondant à ces interactions
      final propertyIds = interactions.map((i) => i.propertyId).toSet().toList();
      final propertiesSnapshot = await _properties
          .where(FieldPath.documentId, whereIn: propertyIds)
          .get();

      final properties = propertiesSnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // 3. Créer un mapping des propriétés pour un accès facile
      final propertyMap = {
        for (var property in properties) property.id: property
      };

      // 4. Analyser les interactions pour construire le profil
      final profile = {
        'interactedPropertyTypes': <String>[],
        'favoriteLocations': <String>[],
        'priceRange': {'min': 0.0, 'max': 0.0},
        'preferredAmenities': <String, double>{},
        'interactionScores': <String, double>{}, // Score par propriété
      };

      // Poids des différents types d'interactions
      final interactionWeights = RecommendationConfig.INTERACTION_WEIGHTS;

      // Parcourir les interactions pour construire le profil
      for (final interaction in interactions) {
        final property = propertyMap[interaction.propertyId];
        if (property == null) continue;

        // Calculer le score de cette interaction
        final baseScore = interactionWeights[interaction.interactionType] ?? 1.0;
        final recencyFactor = _calculateRecencyFactor(interaction.timestamp);
        final durationFactor = interaction.duration > 0
            ? (interaction.duration / 60.0).clamp(0, 5) / 5 + 1 // Bonus pour durée de visionnage longue
            : 1.0;

        final interactionScore = baseScore * recencyFactor * durationFactor;

        // Ajouter ou mettre à jour le score de cette propriété
        final propertyId = property.id;
        // Solution plus concise:
        final scores = profile['interactionScores'] as Map<String, double>? ?? <String, double>{};
        profile['interactionScores'] = scores;
        scores[propertyId] = (scores[propertyId] ?? 0.0) + interactionScore;
        // Mettre à jour le profil avec les caractéristiques de cette propriété
        _updateProfileWithProperty(profile, property, interactionScore);
      }

      // 5. Normaliser et finaliser le profil
      _finalizeProfile(profile);

      return profile;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil utilisateur: $e');
      return null;
    }
  }

  /// Calcule un facteur de récence pour une date donnée
  double _calculateRecencyFactor(DateTime timestamp) {
    final now = DateTime.now();
    final ageInDays = now.difference(timestamp).inHours / 24;

    // Interactions des 7 derniers jours ont un poids supplémentaire
    return (2 - (ageInDays / 7)).clamp(1.0, 2.0);
  }

  /// Met à jour le profil utilisateur avec les caractéristiques d'une propriété
  void _updateProfileWithProperty(
      Map<String, dynamic> profile,
      Property property,
      double score
      ) {
    // Ajouter le type de propriété s'il n'existe pas déjà
    if (!profile['interactedPropertyTypes'].contains(property.type)) {
      profile['interactedPropertyTypes'].add(property.type);
    }

    // Mettre à jour les localisations favorites
    final location = property.location;
    final locationKey = '${location['city']}, ${location['country']}';
    profile['favoriteLocations'].add(locationKey);

    // Mettre à jour la fourchette de prix
    if (profile['priceRange']['min'] == 0 || property.price < profile['priceRange']['min']) {
      profile['priceRange']['min'] = property.price;
    }

    if (property.price > profile['priceRange']['max']) {
      profile['priceRange']['max'] = property.price;
    }

    // Mettre à jour les équipements préférés
    for (final amenity in property.amenities) {
      profile['preferredAmenities'][amenity] =
          (profile['preferredAmenities'][amenity] ?? 0.0) + score;
    }
  }

  /// Finalise le profil utilisateur en normalisant les données
  void _finalizeProfile(Map<String, dynamic> profile) {
    // Limiter aux 3 types de propriétés les plus communs
    if (profile['interactedPropertyTypes'].length > 3) {
      profile['interactedPropertyTypes'] = profile['interactedPropertyTypes'].sublist(0, 3);
    }

    // Trouver les localisations les plus fréquentes
    final locationCounts = <String, int>{};
    for (final location in profile['favoriteLocations']) {
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }

    // Trier les localisations par fréquence et prendre les 3 plus fréquentes
    final sortedLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    profile['favoriteLocations'] = sortedLocations
        .take(3)
        .map((entry) => entry.key)
        .toList();

    // Ajuster la fourchette de prix (± 20%)
    final range = profile['priceRange']['max'] - profile['priceRange']['min'];
    profile['priceRange']['min'] = (profile['priceRange']['min'] - (range * 0.2)).clamp(0, double.infinity);
    profile['priceRange']['max'] = profile['priceRange']['max'] + (range * 0.2);

    // Trouver les 5 équipements préférés
    final sortedAmenities = profile['preferredAmenities'].entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    profile['topAmenities'] = sortedAmenities
        .take(5)
        .map((entry) => entry.key)
        .toList();
  }

  /// Construit une requête pour trouver des propriétés similaires au profil utilisateur
  Query _buildRecommendationQuery(
      Map<String, dynamic> userProfile,
      Map<String, dynamic> options
      ) {
    Query query = _properties;

    // Filtrer par type de propriété
    if (userProfile['interactedPropertyTypes'].isNotEmpty) {
      query = query.where('type', whereIn: userProfile['interactedPropertyTypes']);
    }

    // Filtrer par localisation si une localisation spécifique est demandée
    if (options.containsKey('location') && options['location'] != null) {
      query = query.where('location.city', isEqualTo: options['location']);
    }
    // Sinon, vous ne pouvez pas utiliser whereIn sur un sous-champ comme "location.city",
    // donc nous filtrerons les résultats après la requête pour les localisations préférées

    // Filtrer par fourchette de prix
    final minPrice = options['minPrice'] ?? userProfile['priceRange']['min'];
    final maxPrice = options['maxPrice'] ?? userProfile['priceRange']['max'];

    query = query.where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice);

    // Note: Firestore ne permet pas de filtrer sur plusieurs champs différents dans une seule requête
    // Pour les filtres supplémentaires comme les équipements, nous allons récupérer plus de résultats
    // et filtrer manuellement

    return query;
  }

  /// Récupère les IDs des propriétés récemment vues par l'utilisateur
  Future<List<String>> _getRecentlyViewedPropertyIds(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

      final querySnapshot = await _userInteractions
          .where('userId', isEqualTo: userId)
          .where('interactionType', whereIn: ['view', 'click'])
          .where('timestamp', isGreaterThan: sevenDaysAgo)
          .get();

      return querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['propertyId'] as String)
          .toSet()
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des propriétés récemment vues: $e');
      return [];
    }
  }

  /// Obtient des recommandations supplémentaires
  Future<List<Property>> _getAdditionalRecommendations(
      String userId,
      int limit,
      List<String> excludeIds
      ) async {
    try {
      // Récupérer les préférences explicites de l'utilisateur
      final docSnapshot = await _userPreferences.doc(userId).get();
      UserPreferences? userPreferences;

      if (docSnapshot.exists) {
        userPreferences = UserPreferences.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }

      // Construire une requête basée sur les préférences explicites si disponibles
      Query query = _properties;

      if (userPreferences != null) {
        if (userPreferences.preferredPropertyTypes.isNotEmpty) {
          query = query.where('type', whereIn: userPreferences.preferredPropertyTypes);
        }

        if (userPreferences.budgetRange.isNotEmpty) {
          final minPrice = userPreferences.budgetRange['min'] ?? 0.0;
          final maxPrice = userPreferences.budgetRange['max'] ?? 1000.0;

          query = query.where('price', isGreaterThanOrEqualTo: minPrice)
              .where('price', isLessThanOrEqualTo: maxPrice);
        }

        // Note: Pour les localisations et équipements, nous filtrerons après
      }

      // Nous ne pouvons pas utiliser "whereNotIn" avec une liste longue d'IDs,
      // donc nous allons récupérer plus de résultats et filtrer manuellement
      final querySnapshot = await query.limit(limit * 2).get();

      List<Property> properties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((property) => !excludeIds.contains(property.id))
          .toList();

      // Filtrer par localisation si spécifiée
      if (userPreferences != null && userPreferences.preferredLocations.isNotEmpty) {
        properties = properties.where((property) {
          final city = property.location['city'] as String? ?? '';
          return userPreferences!.preferredLocations.contains(city);
        }).toList();
      }

      // Filtrer par équipements si spécifiés
      if (userPreferences != null && userPreferences.requiredAmenities.isNotEmpty) {
        properties = properties.where((property) {
          return userPreferences!.requiredAmenities.every(
                  (amenity) => property.amenities.contains(amenity)
          );
        }).toList();
      }

      // Limiter au nombre requis
      if (properties.length > limit) {
        properties = properties.sublist(0, limit);
      }

      // Si nous n'avons pas assez de propriétés, utiliser les plus populaires
      if (properties.length < limit) {
        final additionalPopular = await _getPopularProperties(
            limit - properties.length,
            [...excludeIds, ...properties.map((p) => p.id)]
        );

        properties.addAll(additionalPopular);
      }

      return properties;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des recommandations supplémentaires: $e');
      return _getPopularProperties(limit, excludeIds);
    }
  }

  /// Obtient des recommandations par défaut si aucune donnée utilisateur n'est disponible
  Future<List<Property>> _getFallbackRecommendations(
      String userId,
      int limit,
      Map<String, dynamic> options
      ) async {
    try {
      // 1. Essayer d'utiliser les préférences explicites de l'utilisateur
      final docSnapshot = await _userPreferences.doc(userId).get();

      if (docSnapshot.exists) {
        final userPreferences = UserPreferences.fromMap(docSnapshot.data() as Map<String, dynamic>);

        // Construire une requête basée sur les préférences explicites
        final query = _buildQueryFromPreferences(userPreferences, options);

        final querySnapshot = await query.limit(limit).get();

        final properties = querySnapshot.docs
            .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Si on a trouvé suffisamment de propriétés, les retourner
        if (properties.length >= limit ~/ 2) {
          return properties;
        }
      }

      // 2. Sinon, retourner les propriétés populaires
      return await _getPopularProperties(limit);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des recommandations par défaut: $e');
      return await _getPopularProperties(limit);
    }
  }

  /// Construit une requête à partir des préférences explicites d'un utilisateur
  Query _buildQueryFromPreferences(
      UserPreferences preferences,
      Map<String, dynamic> options
      ) {
    Query query = _properties;

    // Ajouter les critères de type de propriété
    if (preferences.preferredPropertyTypes.isNotEmpty) {
      query = query.where('type', whereIn: preferences.preferredPropertyTypes);
    }

    // Ajouter les critères de localisation
    if (options.containsKey('location') && options['location'] != null) {
      query = query.where('location.city', isEqualTo: options['location']);
    }

    // Ajouter les critères de budget
    if (preferences.budgetRange.isNotEmpty) {
      final minPrice = options['minPrice'] ?? preferences.budgetRange['min'] ?? 0.0;
      final maxPrice = options['maxPrice'] ?? preferences.budgetRange['max'] ?? 1000.0;

      query = query.where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);
    } else if (options.containsKey('minPrice') || options.containsKey('maxPrice')) {
      final minPrice = options['minPrice'] ?? 0.0;
      final maxPrice = options['maxPrice'] ?? 1000.0;

      query = query.where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);
    }

    // Note: Pour les autres critères comme les équipements, nous filtrerons après la requête

    return query;
  }

  /// Récupère les propriétés les plus populaires
  Future<List<Property>> _getPopularProperties(int limit, [List<String> excludeIds = const []]) async {
    try {
      // Construire la requête
      var query = _properties
          .orderBy('rating', descending: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit * 2); // Récupérer plus pour permettre le filtrage

      final querySnapshot = await query.get();

      List<Property> properties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((property) => !excludeIds.contains(property.id))
          .take(limit)
          .toList();

      return properties;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des propriétés populaires: $e');
      return [];
    }
  }

  /// Récupère des recommandations basées sur une propriété spécifique
  Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 5}) async {
    try {
      // 1. Récupérer les détails de la propriété
      final docSnapshot = await _properties.doc(propertyId).get();

      if (!docSnapshot.exists) {
        throw Exception('Propriété non trouvée');
      }

      final property = Property.fromMap(docSnapshot.data() as Map<String, dynamic>, propertyId);

      // 2. Récupérer les propriétés corrélées si disponibles
      final correlationsSnapshot = await _propertyCorrelations
          .where('propertyA', isEqualTo: propertyId)
          .orderBy('cooccurrenceCount', descending: true)
          .limit(limit)
          .get();

      final correlatedPropertyIds = correlationsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['propertyB'] as String)
          .toList();

      if (correlatedPropertyIds.isNotEmpty) {
        // 2.1 Si des corrélations existent, récupérer ces propriétés
        final correlatedPropertiesSnapshot = await _properties
            .where(FieldPath.documentId, whereIn: correlatedPropertyIds)
            .get();

        final correlatedProperties = correlatedPropertiesSnapshot.docs
            .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (correlatedProperties.length >= limit ~/ 2) {
          return correlatedProperties;
        }
      }

      // 3. Sinon, rechercher des propriétés similaires par attributs

      // 3.1 Construire une requête pour trouver des propriétés similaires
      Query query = _properties
          .where('type', isEqualTo: property.type)
          .where('location.city', isEqualTo: property.location['city'])
          .where(FieldPath.documentId, isNotEqualTo: propertyId);

      // 3.2 Ajouter un filtre de prix approximatif
      final minPrice = property.price * 0.8;
      final maxPrice = property.price * 1.2;

      query = query.where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);

      final querySnapshot = await query.limit(limit).get();

      final similarProperties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // 4. Si on n'a pas assez de résultats, élargir la recherche
      if (similarProperties.length < limit) {
        // Recherche plus large : même type, pas forcément même ville
        Query broaderQuery = _properties
            .where('type', isEqualTo: property.type)
            .where(FieldPath.documentId, isNotEqualTo: propertyId);

        // Exclure les propriétés déjà trouvées
        final excludeIds = [propertyId, ...similarProperties.map((p) => p.id)];

        final broaderSnapshot = await broaderQuery.limit(limit * 2).get();

        final additionalProperties = broaderSnapshot.docs
            .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((p) => !excludeIds.contains(p.id))
            .take(limit - similarProperties.length)
            .toList();

        return [...similarProperties, ...additionalProperties];
      }

      return similarProperties;
    } catch (e) {
      debugPrint('Erreur lors de la recherche de propriétés similaires: $e');
      return [];
    }
  }

  /// Récupère les recommandations spécifiques à la Coupe du Monde 2030
  Future<List<Property>> getWorldCupRecommendations(
      String userId, {
        String? hostCountry,
        String? stadiumNearby,
        DateTime? matchDate,
        int limit = 10
      }) async {
    try {
      // Base de la requête
      Query query = _properties;

      // Filtrer par pays hôte si spécifié
      if (hostCountry != null) {
        query = query.where('location.country', isEqualTo: hostCountry);
      }

      // Filtrer par proximité du stade si spécifié
      if (stadiumNearby != null) {
        query = query.where('worldCupInfo.nearbyStadium', isEqualTo: stadiumNearby);
      }

      // Filtrer par disponibilité pendant la date du match si spécifiée
      // Cela nécessite un système de gestion des disponibilités

      // Récupérer les propriétés
      final querySnapshot = await query
          .where('worldCupInfo.worldCupSpecial', isEqualTo: true)
          .orderBy('worldCupInfo.stadiumDistanceKm', descending: false)
          .limit(limit * 2)
          .get();

      List<Property> worldCupProperties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filtrer par date si nécessaire
      if (matchDate != null) {
        // Cette logique dépend de votre système de gestion des disponibilités
        // Ici, nous supposons qu'il y a un champ "availableDates" dans worldCupInfo
      }

      // Exclure les propriétés déjà vues
      final recentlyViewedIds = await _getRecentlyViewedPropertyIds(userId);
      worldCupProperties = worldCupProperties
          .where((property) => !recentlyViewedIds.contains(property.id))
          .take(limit)
          .toList();

      // Si pas assez de résultats, ajouter des propriétés standards
      if (worldCupProperties.length < limit) {
        final additionalProperties = await getRecommendationsForUser(
            userId,
            limit: limit - worldCupProperties.length,
            options: {'excludeIds': worldCupProperties.map((p) => p.id).toList()}
        );

        worldCupProperties.addAll(additionalProperties);
      }

      return worldCupProperties;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des recommandations Coupe du Monde: $e');
      return [];
    }
  }
}