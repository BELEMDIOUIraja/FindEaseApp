class Room {
  final String title;
  final String description;
  final String price;
  final List<String> imagePaths;
  final String distance;
  final double rating;
  final String dates;
  final String category;
  final String location;
  final String style;
  final String interest;
  final String priceRange;
  bool isFavorite;
  int userRating; // Nouveau champ pour le rating utilisateur

  Room({
    required this.title,
    required this.description,
    required this.price,
    required this.imagePaths,
    required this.distance,
    required this.rating,
    required this.dates,
    required this.category,
    required this.location,
    required this.style,
    required this.interest,
    required this.priceRange,
    this.isFavorite = false,
    this.userRating = 0, // Initialisé à 0
  });
}