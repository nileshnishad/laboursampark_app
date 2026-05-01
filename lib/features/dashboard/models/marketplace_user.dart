class MarketplaceUser {
  final String id;
  final String fullName;
  final String email;
  final String userType;
  final String businessName;
  final String city;
  final String mobile;
  final double rating;
  final int completedJobs;
  final bool availability;
  final String experienceLabel;
  final String? logoUrl;
  final String? profilePhotoUrl;

  const MarketplaceUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userType,
    required this.businessName,
    required this.city,
    required this.mobile,
    required this.rating,
    required this.completedJobs,
    required this.availability,
    required this.experienceLabel,
    required this.logoUrl,
    required this.profilePhotoUrl,
  });

  factory MarketplaceUser.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final fallbackCity = (location?['city'] ?? '').toString();
    final rawExperience =
        (json['experience'] ?? json['experienceRange'] ?? '')
            .toString();

    return MarketplaceUser(
      id: (json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userType: (json['userType'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
      city: (json['city'] ?? fallbackCity).toString(),
      mobile: (json['mobile'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      availability: (json['availability'] as bool?) ?? false,
      experienceLabel:
          rawExperience.isEmpty ? 'N/A' : rawExperience,
      logoUrl: _normalizeUrl(json['companyLogoUrl'] as String?),
      profilePhotoUrl:
          _normalizeUrl(json['profilePhotoUrl'] as String?),
    );
  }

  static String? _normalizeUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
