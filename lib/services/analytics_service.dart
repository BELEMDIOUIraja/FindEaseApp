// lib/services/analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Analyse les interactions utilisateur pour améliorer les recommandations
  /// Cette méthode est conçue pour s'exécuter périodiquement en arrière-plan
  Future<void> analyzeUserInteractions() async {
    try {
      // 1. Récupérer toutes les interactions des 30 derniers jours
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final querySnapshot = await _firestore.collection('UserInteractions')
          .where('timestamp', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      final interactions = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      if (interactions.isEmpty) {
        debugPrint('Aucune interaction à analyser');
        return;
      }

      // 2. Calculer les statistiques d'interaction par propriété
      final propertyStats = calculatePropertyStats(interactions);

      // 3. Mettre à jour les scores de popularité des propriétés
      await updatePropertyPopularityScores(propertyStats);

      // 4. Mettre à jour les statistiques utilisateur
      await updateUserStats(interactions);

      // 5. Trouver des corrélations entre les propriétés
      await findPropertyCorrelations(interactions);

      debugPrint('Analyse des interactions terminée');
    } catch (error) {
      debugPrint('Erreur lors de l\'analyse des interactions: $error');
    }
  }

  /// Calcule les statistiques d'interaction par propriété
  /// @param interactions - Liste d'interactions utilisateur
  /// @returns - Statistiques par propriété
  Map<String, Map<String, dynamic>> calculatePropertyStats(List<Map<String, dynamic>> interactions) {
    final propertyStats = <String, Map<String, dynamic>>{};

    // Poids des différents types d'interactions
    const interactionWeights = {
      'view': 1,
      'click': 2,
      'favorite': 5,
      'booking': 10
    };

    // Parcourir toutes les interactions
    for (final interaction in interactions) {
      final propertyId = interaction['propertyId'] as String;
      final interactionType = interaction['interactionType'] as String;
      final interactionWeight = interactionWeights[interactionType] ?? 1;
      final userId = interaction['userId'] as String;

      // Initialiser les statistiques de la propriété si nécessaire
      if (!propertyStats.containsKey(propertyId)) {
        propertyStats[propertyId] = {
          'totalInteractions': 0,
          'weightedScore': 0,
          'viewCount': 0,
          'clickCount': 0,
          'favoriteCount': 0,
          'bookingCount': 0,
          'uniqueUsers': <String>{},
        };
      }

      // Mettre à jour les statistiques
      propertyStats[propertyId]!['totalInteractions'] =
          (propertyStats[propertyId]!['totalInteractions'] as int) + 1;

      propertyStats[propertyId]!['weightedScore'] =
          (propertyStats[propertyId]!['weightedScore'] as int) + interactionWeight;

      (propertyStats[propertyId]!['uniqueUsers'] as Set<String>).add(userId);

      // Incrémenter les compteurs spécifiques
      switch (interactionType) {
        case 'view':
          propertyStats[propertyId]!['viewCount'] =
              (propertyStats[propertyId]!['viewCount'] as int) + 1;
          break;
        case 'click':
          propertyStats[propertyId]!['clickCount'] =
              (propertyStats[propertyId]!['clickCount'] as int) + 1;
          break;
        case 'favorite':
          propertyStats[propertyId]!['favoriteCount'] =
              (propertyStats[propertyId]!['favoriteCount'] as int) + 1;
          break;
        case 'booking':
          propertyStats[propertyId]!['bookingCount'] =
              (propertyStats[propertyId]!['bookingCount'] as int) + 1;
          break;
      }
    }

    // Convertir les ensembles d'utilisateurs uniques en nombres
    for (final propertyId in propertyStats.keys) {
      final uniqueUsers = propertyStats[propertyId]!['uniqueUsers'] as Set<String>;
      propertyStats[propertyId]!['uniqueUserCount'] = uniqueUsers.length;
      propertyStats[propertyId]!.remove('uniqueUsers'); // Supprimer l'ensemble pour ne garder que le nombre
    }

    return propertyStats;
  }

  /// Met à jour les scores de popularité des propriétés dans la base de données
  /// @param propertyStats - Statistiques par propriété
  Future<void> updatePropertyPopularityScores(Map<String, Map<String, dynamic>> propertyStats) async {
    try {
      // Parcourir toutes les propriétés avec des statistiques
      for (final entry in propertyStats.entries) {
        final propertyId = entry.key;
        final stats = entry.value;

        // Calculer un score de popularité normalisé
        final viewCount = stats['viewCount'] as int;
        final clickCount = stats['clickCount'] as int;
        final favoriteCount = stats['favoriteCount'] as int;
        final bookingCount = stats['bookingCount'] as int;

        final popularityScore = (
            (viewCount * 1) +
                (clickCount * 2) +
                (favoriteCount * 5) +
                (bookingCount * 10)
        ) / 10; // Normalisation

        // Calculer un taux de conversion (clics / vues)
        final conversionRate = viewCount > 0
            ? (clickCount / viewCount) * 100
            : 0.0;

        // Mettre à jour la propriété dans la base de données
        await _firestore.collection('Properties').doc(propertyId).update({
          'popularityScore': popularityScore,
          'interactionStats': {
            'totalInteractions': stats['totalInteractions'],
            'weightedScore': stats['weightedScore'],
            'viewCount': viewCount,
            'clickCount': clickCount,
            'favoriteCount': favoriteCount,
            'bookingCount': bookingCount,
            'uniqueUserCount': stats['uniqueUserCount'],
            'conversionRate': conversionRate
          },
          'lastAnalyzed': FieldValue.serverTimestamp()
        });
      }
    } catch (error) {
      debugPrint('Erreur lors de la mise à jour des scores de popularité: $error');
      rethrow;
    }
  }

  /// Met à jour les statistiques d'utilisation par utilisateur
  /// @param interactions - Liste d'interactions utilisateur
  Future<void> updateUserStats(List<Map<String, dynamic>> interactions) async {
    try {
      // Regrouper les interactions par utilisateur
      final userInteractionMap = <String, List<Map<String, dynamic>>>{};

      for (final interaction in interactions) {
        final userId = interaction['userId'] as String;

        if (!userInteractionMap.containsKey(userId)) {
          userInteractionMap[userId] = [];
        }

        userInteractionMap[userId]!.add(interaction);
      }

      // Mettre à jour les statistiques pour chaque utilisateur
      for (final entry in userInteractionMap.entries) {
        final userId = entry.key;
        final userInteractions = entry.value;

        // Compter les différents types d'interactions
        final interactionCounts = {
          'view': 0,
          'click': 0,
          'favorite': 0,
          'booking': 0
        };

        // Collecter les IDs de propriétés uniques
        final uniquePropertyIds = <String>{};

        // Analyser les interactions
        for (final interaction in userInteractions) {
          final interactionType = interaction['interactionType'] as String;
          final propertyId = interaction['propertyId'] as String;

          interactionCounts[interactionType] = (interactionCounts[interactionType] ?? 0) + 1;
          uniquePropertyIds.add(propertyId);
        }

        // Calculer les métriques d'engagement
        final totalInteractions = userInteractions.length;
        final uniquePropertyCount = uniquePropertyIds.length;

        // Trouver la date de la dernière interaction
        final timestamps = userInteractions
            .map((i) => (i['timestamp'] as Timestamp).toDate().millisecondsSinceEpoch)
            .toList();
        final lastInteractionDate = DateTime.fromMillisecondsSinceEpoch(timestamps.reduce((a, b) => a > b ? a : b));

        // Mettre à jour les statistiques utilisateur
        await _firestore.collection('UserStats').doc(userId).set({
          'interactionCounts': interactionCounts,
          'totalInteractions': totalInteractions,
          'uniquePropertyCount': uniquePropertyCount,
          'lastInteractionDate': lastInteractionDate,
          'lastAnalyzed': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
      }
    } catch (error) {
      debugPrint('Erreur lors de la mise à jour des statistiques utilisateur: $error');
      rethrow;
    }
  }

  /// Trouve des corrélations entre les propriétés basées sur les interactions utilisateur
  /// @param interactions - Liste d'interactions utilisateur
  Future<void> findPropertyCorrelations(List<Map<String, dynamic>> interactions) async {
    try {
      // 1. Créer un mapping des propriétés consultées par chaque utilisateur
      final userPropertyMap = <String, Set<String>>{};

      for (final interaction in interactions) {
        final userId = interaction['userId'] as String;
        final propertyId = interaction['propertyId'] as String;

        if (!userPropertyMap.containsKey(userId)) {
          userPropertyMap[userId] = <String>{};
        }

        userPropertyMap[userId]!.add(propertyId);
      }

      // 2. Initialiser une matrice de corrélation entre propriétés
      final propertyCorrelations = <String, Map<String, dynamic>>{};

      // 3. Parcourir tous les utilisateurs et leurs propriétés
      for (final entry in userPropertyMap.entries) {
        final propertyIds = entry.value.toList();

        // Pour chaque paire de propriétés
        for (var i = 0; i < propertyIds.length; i++) {
          for (var j = i + 1; j < propertyIds.length; j++) {
            final propA = propertyIds[i];
            final propB = propertyIds[j];

            // Créer une clé pour la paire (toujours dans le même ordre pour éviter les doublons)
            final sortedProps = [propA, propB]..sort();
            final pairKey = '${sortedProps[0]}-${sortedProps[1]}';

            if (!propertyCorrelations.containsKey(pairKey)) {
              propertyCorrelations[pairKey] = {
                'propertyA': sortedProps[0],
                'propertyB': sortedProps[1],
                'cooccurrenceCount': 0
              };
            }

            propertyCorrelations[pairKey]!['cooccurrenceCount'] =
                (propertyCorrelations[pairKey]!['cooccurrenceCount'] as int) + 1;
          }
        }
      }

      // 4. Filtrer les corrélations significatives (au moins 2 cooccurrences)
      final significantCorrelations = propertyCorrelations.values
          .where((corr) => (corr['cooccurrenceCount'] as int) >= 2)
          .toList();

      // 5. Mettre à jour ou insérer les corrélations dans la base de données
      for (final correlation in significantCorrelations) {
        final propertyA = correlation['propertyA'] as String;
        final propertyB = correlation['propertyB'] as String;

        // Créer un ID de document unique basé sur les deux propriétés
        final docId = '$propertyA-$propertyB';

        await _firestore.collection('PropertyCorrelations').doc(docId).set({
          'propertyA': propertyA,
          'propertyB': propertyB,
          'cooccurrenceCount': correlation['cooccurrenceCount'],
          'lastUpdated': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
      }
    } catch (error) {
      debugPrint('Erreur lors de la recherche de corrélations entre propriétés: $error');
      rethrow;
    }
  }

  /// Analyse le comportement des utilisateurs pour segmenter la clientèle
  /// Utile pour des stratégies marketing ciblées
  Future<void> segmentUsers() async {
    try {
      // 1. Récupérer les statistiques de tous les utilisateurs
      final querySnapshot = await _firestore.collection('UserStats').get();
      final userStats = querySnapshot.docs.map((doc) => {
        ...doc.data(),
        'userId': doc.id
      }).toList();

      if (userStats.isEmpty) {
        debugPrint('Aucune statistique utilisateur à analyser');
        return;
      }

      // 2. Définir les segments utilisateur
      final userSegments = {
        'highlyActive': <String>[],  // Utilisateurs très actifs
        'browsers': <String>[],      // Consultent beaucoup mais réservent peu
        'collectors': <String>[],    // Favorisent souvent
        'quickBookers': <String>[],  // Réservent directement
        'inactive': <String>[],      // Inactifs depuis longtemps
        'niche': <String>[],         // Se concentrent sur peu de propriétés
        'explorers': <String>[],     // Explorent de nombreuses propriétés
        'worldCupFans': <String>[]   // Intéressés par la Coupe du Monde
      };

      // 3. Date limite pour considérer un utilisateur comme inactif (30 jours)
      final inactiveThreshold = DateTime.now().subtract(const Duration(days: 30));

      // 4. Segmenter les utilisateurs
      for (final user in userStats) {
        final userId = user['userId'] as String;
        final lastInteractionDate = (user['lastInteractionDate'] as Timestamp).toDate();

        // Vérifier si l'utilisateur est inactif
        if (lastInteractionDate.isBefore(inactiveThreshold)) {
          userSegments['inactive']!.add(userId);
          continue;
        }

        // Récupérer les compteurs d'interaction
        final interactionCounts = user['interactionCounts'] as Map<String, dynamic>? ?? {};
        final viewCount = interactionCounts['view'] as int? ?? 0;
        final clickCount = interactionCounts['click'] as int? ?? 0;
        final favoriteCount = interactionCounts['favorite'] as int? ?? 0;
        final bookingCount = interactionCounts['booking'] as int? ?? 0;
        final totalInteractions = user['totalInteractions'] as int? ?? 0;
        final uniquePropertyCount = user['uniquePropertyCount'] as int? ?? 0;

        // Segmenter selon les critères
        if (totalInteractions > 20) {
          userSegments['highlyActive']!.add(userId);
        }

        if (viewCount > 10 && bookingCount == 0) {
          userSegments['browsers']!.add(userId);
        }

        if (favoriteCount > 5) {
          userSegments['collectors']!.add(userId);
        }

        if (bookingCount > 0 && viewCount > 0 && bookingCount / viewCount > 0.2) {
          userSegments['quickBookers']!.add(userId);
        }

        if (uniquePropertyCount > 15) {
          userSegments['explorers']!.add(userId);
        }

        if (totalInteractions > 10 && uniquePropertyCount < 5) {
          userSegments['niche']!.add(userId);
        }
      }

      // 5. Mettre à jour les segments dans la base de données
      await _firestore.collection('UserSegments').add({
        'segments': userSegments,
        'createdAt': FieldValue.serverTimestamp(),
        'totalUsers': userStats.length
      });

      // 6. Mettre à jour le segment de chaque utilisateur
      for (final entry in userSegments.entries) {
        final segment = entry.key;
        final userIds = entry.value;

        for (final userId in userIds) {
          await _firestore.collection('Users').doc(userId).update({
            'userSegment': segment
          });
        }
      }

      debugPrint('Segmentation des utilisateurs terminée');
    } catch (error) {
      debugPrint('Erreur lors de la segmentation des utilisateurs: $error');
      rethrow;
    }
  }

  /// Exécute toutes les analyses en une seule opération
  /// Peut être appelé périodiquement (par exemple, une fois par jour)
  Future<void> runAllAnalytics() async {
    try {
      debugPrint('Démarrage des analyses...');

      // 1. Analyser les interactions utilisateur
      await analyzeUserInteractions();

      // 2. Segmenter les utilisateurs
      await segmentUsers();

      debugPrint('Toutes les analyses ont été effectuées avec succès');
    } catch (error) {
      debugPrint('Erreur lors de l\'exécution des analyses: $error');
    }
  }
}