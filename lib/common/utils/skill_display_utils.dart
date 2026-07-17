import '../models/skill_model.dart';

String resolveSkillDisplayName({
  required String skillId,
  required List<SkillModel> skills,
  String? localeCode,
  String? fallback,
}) {
  final normalizedLocale = (localeCode ?? '').toLowerCase();

  for (final skill in skills) {
    if (skill.id != skillId) continue;

    if (normalizedLocale == 'hi' && skill.hiName.isNotEmpty) {
      return skill.hiName;
    }

    if (normalizedLocale == 'mr' && skill.mrName.isNotEmpty) {
      return skill.mrName;
    }

    if (skill.enName.isNotEmpty) {
      return skill.enName;
    }

    break;
  }

  return fallback ?? skillId;
}

List<String> resolveSkillDisplayNames({
  required Iterable<String> skillIds,
  required List<SkillModel> skills,
  String? localeCode,
  String? fallback,
}) {
  return skillIds
      .map(
        (skillId) => resolveSkillDisplayName(
          skillId: skillId,
          skills: skills,
          localeCode: localeCode,
          fallback: fallback,
        ),
      )
      .toList();
}
