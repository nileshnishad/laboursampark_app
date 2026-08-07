class AppMetadata {
  static const String appName = 'Labour Sampark';

  static const String supportEmail = 'laboursampark@gmail.com';
  static const String supportPhone = '9702701777';
  static const String privacyPolicyUrl =
      'https://laboursampark.com/privacy-policy';
  static const String supportUrl = 'https://laboursampark.com/privacy-policy';

  static const String appStoreCategory = 'Business';
  static const String appStoreAgeRating = '4+';
  static const String appStoreKeywords =
      'labour, contractor, jobs, workers, work, hiring';

  static bool get hasSupportEmail => supportEmail.trim().isNotEmpty;
  static bool get hasSupportPhone => supportPhone.trim().isNotEmpty;
  static bool get hasPrivacyPolicyUrl => privacyPolicyUrl.trim().isNotEmpty;
  static bool get hasSupportUrl => supportUrl.trim().isNotEmpty;
}
