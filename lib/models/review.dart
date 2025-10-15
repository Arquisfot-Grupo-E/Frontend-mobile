class Review {
  final String id;
  final String userId;
  final String content;
  final int rating;
  final int karmaScore;
  final String createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.content,
    required this.rating,
    required this.karmaScore,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      rating: json['rating'],
      karmaScore: json['karma_score'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}
