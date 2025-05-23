class GoogleUserData {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  GoogleUserData({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
