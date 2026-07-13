class MarketplaceFilter {
  final String state;
  final String city;
  final String area;
  final double minRating;
  final int minExperience;
  final List<String> skillIds;
  final List<String> businessTypeIds;

  const MarketplaceFilter({
    this.state = '',
    this.city = '',
    this.area = '',
    this.minRating = 0,
    this.minExperience = 0,
    this.skillIds = const [],
    this.businessTypeIds = const [],
  });

  bool get hasAnyFilter {
    return state.isNotEmpty ||
        city.isNotEmpty ||
        area.isNotEmpty ||
        minRating > 0 ||
        minExperience > 0 ||
        skillIds.isNotEmpty ||
        businessTypeIds.isNotEmpty;
  }

  MarketplaceFilter copyWith({
    String? state,
    String? city,
    String? area,
    double? minRating,
    int? minExperience,
    List<String>? skillIds,
    List<String>? businessTypeIds,
  }) {
    return MarketplaceFilter(
      state: state ?? this.state,
      city: city ?? this.city,
      area: area ?? this.area,
      minRating: minRating ?? this.minRating,
      minExperience: minExperience ?? this.minExperience,
      skillIds: skillIds ?? this.skillIds,
      businessTypeIds: businessTypeIds ?? this.businessTypeIds,
    );
  }

  Map<String, dynamic> toQueryParameters({required bool isLabour}) {
    final params = <String, dynamic>{};

    if (state.isNotEmpty) params['state'] = state.trim();
    if (city.isNotEmpty) params['city'] = city.trim();
    if (area.isNotEmpty) params['area'] = area.trim();
    if (minRating > 0) params['minRating'] = minRating.toString();
    if (minExperience > 0) params['minExperience'] = minExperience.toString();
    if (isLabour && skillIds.isNotEmpty) {
      params['skillIds'] = skillIds.join(',');
    }
    if (!isLabour && businessTypeIds.isNotEmpty) {
      params['businessTypeIds'] = businessTypeIds.join(',');
    }

    return params;
  }
}
