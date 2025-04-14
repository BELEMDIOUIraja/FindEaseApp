class Property {
  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final Map<String, dynamic> location;
  final List<String> amenities;
  final int capacity;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double? popularityScore;
  final Map<String, dynamic>? interactionStats;
  final Map<String, dynamic>? worldCupInfo; // Information spécifique à la Coupe du Monde

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.location,
    required this.amenities,
    required this.capacity,
    required this.bedrooms,
    required this.bathrooms,
    required this.images,
    this.rating = 0,
    this.reviewCount = 0,
    this.popularityScore,
    this.interactionStats,
    this.worldCupInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'price': price,
      'location': location,
      'amenities': amenities,
      'capacity': capacity,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'popularityScore': popularityScore,
      'interactionStats': interactionStats,
      'worldCupInfo': worldCupInfo,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map, String documentId) {
    return Property(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      location: map['location'] ?? {},
      amenities: List<String>.from(map['amenities'] ?? []),
      capacity: map['capacity'] ?? 0,
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      popularityScore: map['popularityScore']?.toDouble(),
      interactionStats: map['interactionStats'],
      worldCupInfo: map['worldCupInfo'],
    );
  }
}