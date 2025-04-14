import 'package:cloud_firestore/cloud_firestore.dart';


class PropertyCorrelation {
  final String propertyA;
  final String propertyB;
  final int cooccurrenceCount;
  final DateTime lastUpdated;

  PropertyCorrelation({
    required this.propertyA,
    required this.propertyB,
    required this.cooccurrenceCount,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyA': propertyA,
      'propertyB': propertyB,
      'cooccurrenceCount': cooccurrenceCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory PropertyCorrelation.fromMap(Map<String, dynamic> map) {
    return PropertyCorrelation(
      propertyA: map['propertyA'] ?? '',
      propertyB: map['propertyB'] ?? '',
      cooccurrenceCount: map['cooccurrenceCount'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}