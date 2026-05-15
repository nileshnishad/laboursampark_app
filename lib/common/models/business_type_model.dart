class BusinessTypeModel {
  final String id;
  final String enName;
  final String hiName;
  final String mrName;
  final String category;

  BusinessTypeModel({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.mrName,
    required this.category,
  });

  factory BusinessTypeModel.fromJson(Map<String, dynamic> json) {
    return BusinessTypeModel(
      id: json['id'] as String? ?? '',
      enName: json['enName'] as String? ?? '',
      hiName: json['hiName'] as String? ?? '',
      mrName: json['mrName'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enName': enName,
      'hiName': hiName,
      'mrName': mrName,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessTypeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
