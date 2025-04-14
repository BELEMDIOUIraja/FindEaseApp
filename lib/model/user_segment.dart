// lib/models/user_segment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSegment {
  final String id;
  final Map<String, List<String>> segments;
  final DateTime createdAt;
  final int totalUsers;

  UserSegment({
    required this.id,
    required this.segments,
    required this.createdAt,
    required this.totalUsers,
  });

  Map<String, dynamic> toMap() {
    return {
      'segments': segments,
      'createdAt': FieldValue.serverTimestamp(),
      'totalUsers': totalUsers,
    };
  }

  factory UserSegment.fromMap(Map<String, dynamic> map, String documentId) {
    final Map<String, List<String>> segmentsMap = {};

    if (map['segments'] != null) {
      (map['segments'] as Map<String, dynamic>).forEach((key, value) {
        segmentsMap[key] = List<String>.from(value);
      });
    }

    return UserSegment(
      id: documentId,
      segments: segmentsMap,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalUsers: map['totalUsers'] ?? 0,
    );
  }
}