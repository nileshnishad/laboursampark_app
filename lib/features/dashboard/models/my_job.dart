class MyJob {
  final String id;
  final String workTitle;
  final String description;
  final List<String> target;
  final int workersNeeded;
  final List<String> requiredSkills;
  final List<String> images;
  final num? estimatedBudget;
  final String status;
  final bool visibility;
  final int totalApplications;
  final String city;
  final String area;
  final String state;
  final String address;
  final String pincode;
  final DateTime? createdAt;

  const MyJob({
    required this.id,
    required this.workTitle,
    required this.description,
    required this.target,
    required this.workersNeeded,
    required this.requiredSkills,
    required this.images,
    required this.estimatedBudget,
    required this.status,
    required this.visibility,
    required this.totalApplications,
    required this.city,
    required this.area,
    required this.state,
    required this.address,
    required this.pincode,
    required this.createdAt,
  });

  factory MyJob.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    return MyJob(
      id: (json['_id'] ?? '').toString(),
      workTitle: (json['workTitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      target:
          (json['target'] as List? ?? []).map((e) => e.toString()).toList(),
      workersNeeded: (json['workersNeeded'] as num?)?.toInt() ?? 1,
      requiredSkills: (json['requiredSkills'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      estimatedBudget: json['estimatedBudget'] as num?,
      status: (json['status'] ?? 'open').toString(),
      visibility: (json['visibility'] as bool?) ?? false,
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 0,
      city: (loc['city'] ?? '').toString(),
      area: (loc['area'] ?? '').toString(),
      state: (loc['state'] ?? '').toString(),
      address: (loc['address'] ?? '').toString(),
      pincode: (loc['pincode'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
