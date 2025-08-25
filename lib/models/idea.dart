class Idea {
  final String id;
  final String startupName;
  final String tagline;
  final String description;
  final int aiRating;
  final int voteCount;
  final DateTime createdAt;
  final String userId;

  Idea({
    required this.id,
    required this.startupName,
    required this.tagline,
    required this.description,
    required this.aiRating,
    required this.voteCount,
    required this.createdAt,
    required this.userId,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'] ?? '',
      startupName: json['startup_name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      aiRating: (json['ai_rating'] ?? 0) as int,
      voteCount: (json['vote_count'] ?? 0) as int,
      createdAt: DateTime.parse(
        (json['created_at'] ?? DateTime.now().toIso8601String()) as String,
      ),
      userId: json['user_id'] ?? '',
    );
  }

  Idea copyWith({
    String? id,
    String? startupName,
    String? tagline,
    String? description,
    int? aiRating,
    int? voteCount,
    DateTime? createdAt,
    String? userId,
  }) {
    return Idea(
      id: id ?? this.id,
      startupName: startupName ?? this.startupName,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      aiRating: aiRating ?? this.aiRating,
      voteCount: voteCount ?? this.voteCount,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
