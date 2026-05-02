class JobHistoryEntry {
  final String id;
  final String jobId;
  final String workTitle;
  final String description;
  final String city;
  final String state;
  final String area;
  final String address;
  final List<String> requiredSkills;
  final int workersNeeded;
  final double? estimatedBudget;
  final String workType;
  final String jobStatus; // open | completed

  // Who posted the job (populated for labour view, empty string for contractor view)
  final String postedByName;
  final String postedByUserType;
  final String postedByPhoto;

  // Applicant details (contractor view: who applied to the job)
  final String applicantName;
  final String applicantUserType;
  final String applicantPhoto;
  final String applicantMobile;
  final String applicantEmail;
  final double applicantRating;
  final String applicantExperience;
  final List<String> applicantSkills;

  final String status; // applied | accepted | completed | rejected
  final String applicationMessage;
  final String rejectionReason;

  final DateTime? appliedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;

  const JobHistoryEntry({
    required this.id,
    required this.jobId,
    required this.workTitle,
    required this.description,
    required this.city,
    required this.state,
    required this.area,
    required this.address,
    required this.requiredSkills,
    required this.workersNeeded,
    this.estimatedBudget,
    this.workType = '',
    this.jobStatus = '',
    required this.postedByName,
    required this.postedByUserType,
    required this.postedByPhoto,
    required this.applicantName,
    required this.applicantUserType,
    required this.applicantPhoto,
    required this.applicantMobile,
    required this.applicantEmail,
    this.applicantRating = 0.0,
    this.applicantExperience = '',
    this.applicantSkills = const [],
    required this.status,
    required this.applicationMessage,
    this.rejectionReason = '',
    this.appliedAt,
    this.acceptedAt,
    this.completedAt,
    this.rejectedAt,
  });

  factory JobHistoryEntry.fromJson(Map<String, dynamic> json) {
    // jobId may be a populated Map, plain String, or null
    final jobIdRaw = json['jobId'];
    final jobIdMap = jobIdRaw is Map<String, dynamic> ? jobIdRaw : <String, dynamic>{};
    final jobIdStr = jobIdRaw is String ? jobIdRaw : (jobIdMap['_id'] ?? '').toString();

    // Location: prefer jobId.location, fallback to jobDetails.location
    final jobIdLoc = jobIdMap['location'] is Map<String, dynamic>
        ? jobIdMap['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    final jobDetails = json['jobDetails'] is Map<String, dynamic>
        ? json['jobDetails'] as Map<String, dynamic>
        : <String, dynamic>{};
    final jobDetailsLoc = jobDetails['location'] is Map<String, dynamic>
        ? jobDetails['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    final timeline = json['timeline'] is Map<String, dynamic>
        ? json['timeline'] as Map<String, dynamic>
        : <String, dynamic>{};

    // postedBy may be populated Map or plain String ID
    final postedByRaw = json['postedBy'];
    final postedByMap = postedByRaw is Map<String, dynamic> ? postedByRaw : <String, dynamic>{};

    // userId = applicant (for contractor view) or null
    final userIdRaw = json['userId'];
    final userIdMap = userIdRaw is Map<String, dynamic> ? userIdRaw : <String, dynamic>{};
    final userDetails = json['userDetails'] is Map<String, dynamic>
        ? json['userDetails'] as Map<String, dynamic>
        : <String, dynamic>{};

    List<String> parseList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    DateTime? parseDate(dynamic v) {
      if (v == null || v.toString().isEmpty) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return JobHistoryEntry(
      id: (json['_id'] ?? '').toString(),
      jobId: jobIdStr,
      workTitle: (jobIdMap['workTitle'] ?? jobDetails['workTitle'] ?? '').toString(),
      description: (jobIdMap['description'] ?? jobDetails['description'] ?? '').toString(),
      city: (jobIdLoc['city'] ?? jobDetailsLoc['city'] ?? '').toString(),
      state: (jobIdLoc['state'] ?? jobDetailsLoc['state'] ?? '').toString(),
      area: (jobIdLoc['area'] ?? jobDetailsLoc['area'] ?? '').toString(),
      address: (jobIdLoc['address'] ?? jobDetailsLoc['address'] ?? '').toString(),
      requiredSkills: parseList(jobIdMap['requiredSkills'] ?? jobDetails['requiredSkills']),
      workersNeeded: parseInt(jobIdMap['workersNeeded'] ?? jobDetails['workersNeeded']),
      estimatedBudget: parseDouble(jobIdMap['estimatedBudget'] ?? jobDetails['estimatedBudget']),
      workType: (jobDetails['workType'] ?? '').toString(),
      jobStatus: (jobIdMap['status'] ?? '').toString(),
      postedByName: (postedByMap['fullName'] ?? '').toString(),
      postedByUserType: (postedByMap['userType'] ?? '').toString(),
      postedByPhoto: (postedByMap['profilePhotoUrl'] ?? '').toString(),
      applicantName: (userIdMap['fullName'] ?? userDetails['name'] ?? '').toString(),
      applicantUserType: (userIdMap['userType'] ?? userDetails['userType'] ?? '').toString(),
      applicantPhoto: (userIdMap['profilePhotoUrl'] ?? userDetails['profilePhotoUrl'] ?? '').toString(),
      applicantMobile: (userIdMap['mobile'] ?? userDetails['mobile'] ?? '').toString(),
      applicantEmail: (userIdMap['email'] ?? userDetails['email'] ?? '').toString(),
      applicantRating: parseDouble(userIdMap['rating'] ?? userDetails['rating']) ?? 0.0,
      applicantExperience: (userIdMap['experience'] ?? userDetails['experience'] ?? '').toString(),
      applicantSkills: parseList(userIdMap['skills'] ?? userDetails['skills']),
      status: (json['status'] ?? 'applied').toString(),
      applicationMessage: (json['applicationMessage'] ?? '').toString(),
      rejectionReason: (timeline['rejectionReason'] ?? '').toString(),
      appliedAt: parseDate(timeline['appliedAt']),
      acceptedAt: parseDate(timeline['acceptedAt']),
      completedAt: parseDate(timeline['completedAt']),
      rejectedAt: parseDate(timeline['rejectedAt']),
    );
  }
}
