// lib/viewmodel/property_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/property.dart';

class PropertyViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Propriétés observables
  Property? _property;
  bool _isLoading = false;
  String? _error;

  // Getters
  Property? get property => _property;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les détails d'une propriété
  Future<void> loadPropertyDetails(String propertyId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docSnapshot = await _firestore.collection('Properties').doc(propertyId).get();

      if (docSnapshot.exists) {
        _property = Property.fromMap(docSnapshot.data() as Map<String, dynamic>, propertyId);
      } else {
        _error = 'Propriété non trouvée';
        _property = null;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des détails de la propriété: $e');
      _error = 'Impossible de charger les détails de la propriété';
      _property = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les propriétés par type
  Future<List<Property>> getPropertiesByType(String type, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('Properties')
          .where('type', isEqualTo: type)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement des propriétés par type: $e');
      _error = 'Impossible de charger les propriétés';
      notifyListeners();
      return [];
    }
  }

  /// Recherche de propriétés
  Future<List<Property>> searchProperties({
    String? query,
    String? location,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    List<String>? amenities,
  }) async {
    try {
      Query propertiesQuery = _firestore.collection('Properties');

      // Appliquer les filtres
      if (type != null && type.isNotEmpty) {
        propertiesQuery = propertiesQuery.where('type', isEqualTo: type);
      }

      if (location != null && location.isNotEmpty) {
        propertiesQuery = propertiesQuery.where('location.city', isEqualTo: location);
      }
      if (minPrice != null) {
        propertiesQuery = propertiesQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        propertiesQuery = propertiesQuery.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minBedrooms != null) {
        propertiesQuery = propertiesQuery.where('bedrooms', isGreaterThanOrEqualTo: minBedrooms);
      }

      // Note: Firestore ne permet pas de filtrer sur plusieurs champs différents avec des opérateurs complexes
      // Pour les amenities, nous filtrerons après avoir récupéré les résultats

      final querySnapshot = await propertiesQuery.limit(20).get();

      List<Property> properties = querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filtrer par recherche textuelle si spécifiée
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        properties = properties.where((property) {
          return property.title.toLowerCase().contains(queryLower) ||
              property.description.toLowerCase().contains(queryLower) ||
              property.location['city'].toString().toLowerCase().contains(queryLower) ||
              property.location['address'].toString().toLowerCase().contains(queryLower);
        }).toList();
      }

      // Filtrer par amenities si spécifiées
      if (amenities != null && amenities.isNotEmpty) {
        properties = properties.where((property) {
          return amenities.every((amenity) => property.amenities.contains(amenity));
        }).toList();
      }

      return properties;
    } catch (e) {
      debugPrint('Erreur lors de la recherche de propriétés: $e');
      _error = 'Impossible d\'effectuer la recherche';
      notifyListeners();
      return [];
    }
  }

  /// Réserve une propriété pour certaines dates
  Future<bool> bookProperty(String propertyId, String userId, DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Vérifier si la propriété est disponible pour ces dates
      final bookingsSnapshot = await _firestore
          .collection('Bookings')
          .where('propertyId', isEqualTo: propertyId)
          .get();

      // Vérifier s'il y a des chevauchements de dates
      final existingBookings = bookingsSnapshot.docs.map((doc) => doc.data()).toList();
      final hasConflict = existingBookings.any((booking) {
        final bookingStart = (booking['startDate'] as Timestamp).toDate();
        final bookingEnd = (booking['endDate'] as Timestamp).toDate();

        // Vérifier le chevauchement
        return (startDate.isBefore(bookingEnd) && endDate.isAfter(bookingStart));
      });

      if (hasConflict) {
        _error = 'La propriété n\'est pas disponible pour ces dates';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Créer la réservation
      await _firestore.collection('Bookings').add({
        'propertyId': propertyId,
        'userId': userId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending'
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la réservation: $e');
      _error = 'Impossible de réserver la propriété';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Vérifie si une propriété est disponible pour certaines dates
  Future<bool> checkAvailability(String propertyId, DateTime startDate, DateTime endDate) async {
    try {
      final bookingsSnapshot = await _firestore
          .collection('Bookings')
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isNotEqualTo: 'cancelled')
          .get();

      // Vérifier s'il y a des chevauchements de dates
      final existingBookings = bookingsSnapshot.docs.map((doc) => doc.data()).toList();
      final hasConflict = existingBookings.any((booking) {
        final bookingStart = (booking['startDate'] as Timestamp).toDate();
        final bookingEnd = (booking['endDate'] as Timestamp).toDate();

        // Vérifier le chevauchement
        return (startDate.isBefore(bookingEnd) && endDate.isAfter(bookingStart));
      });

      return !hasConflict;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de disponibilité: $e');
      _error = 'Impossible de vérifier la disponibilité';
      notifyListeners();
      return false;
    }
  }

  /// Obtient les propriétés spéciales pour la Coupe du Monde
  Future<List<Property>> getWorldCupProperties({String? country}) async {
    try {
      Query query = _firestore.collection('Properties')
          .where('worldCupInfo.worldCupSpecial', isEqualTo: true);

      if (country != null && country.isNotEmpty) {
        query = query.where('location.country', isEqualTo: country);
      }

      final querySnapshot = await query.limit(10).get();

      return querySnapshot.docs
          .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des propriétés Coupe du Monde: $e');
      return [];
    }
  }

  /// Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }
}