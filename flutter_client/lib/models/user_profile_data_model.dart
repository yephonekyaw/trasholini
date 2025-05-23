class UserProfile {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final int totalScans;
  final int ecoPoints;

  UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.totalScans,
    required this.ecoPoints,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      email: json['email'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      totalScans: json['total_scans'] ?? 0,
      ecoPoints: json['eco_points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'total_scans': totalScans,
      'eco_points': ecoPoints,
    };
  }
}
