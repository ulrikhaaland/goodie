class ReviewPost {
  final String restaurantName;
  final String location;
  final String cuisineType;
  final String website;
  final String username;
  final String profilePicture;
  final DateTime reviewDate;
  final double rating;
  final String reviewText;
  final List<String> images;
  final DateTime visitDate;
  final String priceRange;
  final int likes;
  final List<String> comments;
  final bool recommendations;
  final List<String> tags;
  final String specialOffers;

  ReviewPost({
    required this.restaurantName,
    required this.location,
    required this.cuisineType,
    required this.website,
    required this.username,
    required this.profilePicture,
    required this.reviewDate,
    required this.rating,
    required this.reviewText,
    required this.images,
    required this.visitDate,
    required this.priceRange,
    required this.likes,
    required this.comments,
    required this.recommendations,
    required this.tags,
    required this.specialOffers,
  });
}
