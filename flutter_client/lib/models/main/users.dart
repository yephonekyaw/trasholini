class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final int wasteKg;
  final int carbonKg;
  final int points;
  final int rank;

  const User({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.wasteKg,
    required this.carbonKg,
    required this.points,
    required this.rank,
  });

  User copyWith({
    String? id,
    String? name,
    String? title,
    String? profileImageUrl,
    int? wasteKg,
    int? carbonKg,
    int? points,
    int? rank,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      wasteKg: wasteKg ?? this.wasteKg,
      carbonKg: carbonKg ?? this.carbonKg,
      points: points ?? this.points,
      rank: rank ?? this.rank,
    );
  }

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'wasteKg': wasteKg,
      'carbonKg': carbonKg,
      'points': points,
      'rank': rank,
    };
  }

  // Create from JSON from Firebase
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? 'assets/images/profile_placeholder.png',
      wasteKg: json['wasteKg'] ?? 0,
      carbonKg: json['carbonKg'] ?? 0,
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}