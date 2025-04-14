// lib/models/user_preferences.dart
class UserPreferences {
  final String userId;
  final List<String> preferredPropertyTypes;
  final List<String> preferredLocations;
  final Map<String, double> budgetRange;
  final List<String> requiredAmenities;
  final String travelPurpose;
  final int typicalGroupSize;
  final Map<String, int> stayDuration;
  final bool interestedInWorldCup; // Spécifique à la Coupe du Monde 2030

  UserPreferences({
    required this.userId,
    this.preferredPropertyTypes = const [],
    this.preferredLocations = const [],
    this.budgetRange = const {'min': 0, 'max': 1000},
    this.requiredAmenities = const [],
    this.travelPurpose = '',
    this.typicalGroupSize = 1,
    this.stayDuration = const {'min': 1, 'max': 7},
    this.interestedInWorldCup = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferredPropertyTypes': preferredPropertyTypes,
      'preferredLocations': preferredLocations,
      'budgetRange': budgetRange,
      'requiredAmenities': requiredAmenities,
      'travelPurpose': travelPurpose,
      'typicalGroupSize': typicalGroupSize,
      'stayDuration': stayDuration,
      'interestedInWorldCup': interestedInWorldCup,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      preferredPropertyTypes: List<String>.from(map['preferredPropertyTypes'] ?? []),
      preferredLocations: List<String>.from(map['preferredLocations'] ?? []),
      budgetRange: Map<String, double>.from(map['budgetRange'] ?? {'min': 0, 'max': 1000}),
      requiredAmenities: List<String>.from(map['requiredAmenities'] ?? []),
      travelPurpose: map['travelPurpose'] ?? '',
      typicalGroupSize: map['typicalGroupSize'] ?? 1,
      stayDuration: Map<String, int>.from(map['stayDuration'] ?? {'min': 1, 'max': 7}),
      interestedInWorldCup: map['interestedInWorldCup'] ?? false,
    );
  }
}