import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../model/user_interaction.dart';
import '../model/user_preferences.dart';

class UserInteractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Références aux collections Firestore
  CollectionReference get _userInteractions => _firestore.collection('UserInteractions');
  CollectionReference get _userPreferences => _firestore.collection('UserPreferences');

  // Stockage temporaire pour les interactions de visualisation
  final Map<String, DateTime> _viewStartTimes = {};

  /// Enregistre une interaction utilisateur
  ///
  /// [userId] - ID de l'utilisateur
  /// [propertyId] - ID de la propriété
  /// [interactionType] - Type d'interaction ('view', 'click', 'favorite', 'booking')
  /// [contextInfo] - Informations contextuelles sur l'interaction
  Future<String> trackInteraction(
      String userId,
      String propertyId,
      String interactionType,
      {Map<String, dynamic> contextInfo = const {}}
      ) async {
    try {
      // Obtenir les informations sur l'appareil
      final deviceInfo = await _getDeviceInfo();

      final interactionData = {
        'userId': userId,
        'propertyId': propertyId,
        'interactionType': interactionType,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': deviceInfo,
        'contextInfo': contextInfo,
        'duration': 0,
      };

      // Si c'est une visualisation, enregistrer l'heure de début
      if (interactionType == 'view') {
        _viewStartTimes['$userId-$propertyId'] = DateTime.now();
      }

      // Ajouter l'interaction à Firestore
      final docRef = await _userInteractions.add(interactionData);
      return docRef.id;
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de l\'interaction: $e');
      rethrow;
    }
  }

  /// Met à jour la durée d'une visualisation
  ///
  /// [interactionId] - ID de l'interaction
  /// [userId] - ID de l'utilisateur
  /// [propertyId] - ID de la propriété
  Future<void> updateViewDuration(String interactionId, String userId, String propertyId) async {
    try {
      final key = '$userId-$propertyId';
      if (_viewStartTimes.containsKey(key)) {
        final startTime = _viewStartTimes[key]!;
        final duration = DateTime.now().difference(startTime).inSeconds;

        await _userInteractions.doc(interactionId).update({
          'duration': duration
        });

        // Nettoyer le cache
        _viewStartTimes.remove(key);
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la durée: $e');
    }
  }

  /// Enregistre ou met à jour les préférences de l'utilisateur
  ///
  /// [preferences] - Objet UserPreferences contenant les préférences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      await _userPreferences.doc(preferences.userId).set(
          preferences.toMap(),
          SetOptions(merge: true)
      );
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des préférences: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des interactions d'un utilisateur
  ///
  /// [userId] - ID de l'utilisateur
  /// [limit] - Nombre maximum d'interactions à récupérer
  Future<List<UserInteraction>> getUserInteractionHistory(String userId, {int limit = 20}) async {
    try {
      final querySnapshot = await _userInteractions
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        return UserInteraction.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id
        );
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  /// Récupère les préférences explicites d'un utilisateur
  ///
  /// [userId] - ID de l'utilisateur
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final docSnapshot = await _userPreferences.doc(userId).get();

      if (docSnapshot.exists) {
        return UserPreferences.fromMap(
            docSnapshot.data() as Map<String, dynamic>
        );
      }

      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des préférences: $e');
      return null;
    }
  }

  /// Obtient les informations sur l'appareil de l'utilisateur
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final Map<String, dynamic> info = {};

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        info['type'] = 'web';
        info['browser'] = webInfo.browserName.name;
        info['platform'] = webInfo.platform;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info['type'] = 'mobile';
        info['os'] = 'android';
        info['model'] = androidInfo.model;
        info['brand'] = androidInfo.brand;
        info['version'] = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info['type'] = 'mobile';
        info['os'] = 'ios';
        info['model'] = iosInfo.model;
        info['version'] = iosInfo.systemVersion;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des informations de l\'appareil: $e');
    }

    return info;
  }

  /// Ajoute une propriété aux favoris d'un utilisateur
  Future<void> addToFavorites(String userId, String propertyId) async {
    try {
      // Enregistrer l'interaction de type "favorite"
      await trackInteraction(userId, propertyId, 'favorite');

      // Mettre à jour la liste des favoris de l'utilisateur
      await _firestore.collection('Users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([propertyId])
      });
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout aux favoris: $e');
      rethrow;
    }
  }

  /// Supprime une propriété des favoris d'un utilisateur
  Future<void> removeFromFavorites(String userId, String propertyId) async {
    try {
      // Mettre à jour la liste des favoris de l'utilisateur
      await _firestore.collection('Users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([propertyId])
      });
    } catch (e) {
      debugPrint('Erreur lors de la suppression des favoris: $e');
      rethrow;
    }
  }

  /// Vérifie si une propriété est dans les favoris d'un utilisateur
  Future<bool> isFavorite(String userId, String propertyId) async {
    try {
      final docSnapshot = await _firestore.collection('Users').doc(userId).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        final favorites = List<String>.from(userData['favorites'] ?? []);
        return favorites.contains(propertyId);
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }
}