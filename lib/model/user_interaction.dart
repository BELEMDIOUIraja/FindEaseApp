import 'package:cloud_firestore/cloud_firestore.dart';

class UserInteraction {
  final String id;
  final String userId;
  final String propertyId;
  final String interactionType; // 'view', 'click', 'favorite', 'booking'
  final DateTime timestamp;
  final int duration;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> contextInfo;

  UserInteraction({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.interactionType,
    required this.timestamp,
    this.duration = 0,
    this.deviceInfo = const {},
    this.contextInfo = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'propertyId': propertyId,
      'interactionType': interactionType,
      'timestamp': FieldValue.serverTimestamp(),
      'duration': duration,
      'deviceInfo': deviceInfo,
      'contextInfo': contextInfo,
    };
  }

  factory UserInteraction.fromMap(Map<String, dynamic> map, String documentId) {
    return UserInteraction(
      id: documentId,
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      interactionType: map['interactionType'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: map['duration'] ?? 0,
      deviceInfo: map['deviceInfo'] ?? {},
      contextInfo: map['contextInfo'] ?? {},
    );
  }
}