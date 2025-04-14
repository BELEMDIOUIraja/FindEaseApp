// lib/model/match_reference.dart
class MatchReference {
  String? matchDate;
  String? matchZone;
  String? userName;
  String? phoneNumber;
  String? budget;

  MatchReference({
    this.matchDate,
    this.matchZone,
    this.userName,
    this.phoneNumber,
    this.budget,
  });

  Map<String, dynamic> toJson() {
    return {
      'matchDate': matchDate,
      'matchZone': matchZone,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'budget': budget,
    };
  }

  factory MatchReference.fromJson(Map<String, dynamic> json) {
    return MatchReference(
      matchDate: json['matchDate'],
      matchZone: json['matchZone'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      budget: json['budget'],
    );
  }
}