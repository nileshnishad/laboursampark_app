class SkillModel {
  final String id;
  final String enName;
  final String hiName;
  final String mrName;

  SkillModel({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.mrName,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String? ?? '',
      enName: json['enName'] as String? ?? '',
      hiName: json['hiName'] as String? ?? '',
      mrName: json['mrName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enName': enName,
      'hiName': hiName,
      'mrName': mrName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
