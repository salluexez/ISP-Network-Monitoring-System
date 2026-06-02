class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  final String id;
  final String email;
  final String fullName;
  final bool isActive;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}
