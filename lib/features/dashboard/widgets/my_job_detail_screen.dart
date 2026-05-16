import 'package:flutter/material.dart';
import '../models/my_job.dart';
import '../../../common/models/skill_model.dart';
import '../../../common/models/business_type_model.dart';

class MyJobDetailScreen extends StatelessWidget {
  final MyJob job;
  final Color primaryColor;
  final List<SkillModel> skills;
  final List<BusinessTypeModel> businessTypes;
  final List<SkillModel> skillsList;

  const MyJobDetailScreen({
    super.key,
    required this.job,
    required this.primaryColor,
    required this.skills,
    required this.businessTypes,
    required this.skillsList,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _targetLabel(String t) {
    switch (t) {
      case 'sub_contractor':
        return 'Sub-Contractor';
      case 'labour':
        return 'Labour';
      default:
        return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final location = [
      job.area,
      job.city,
      job.state,
    ].where((e) => e.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        // ensure icons (back arrow) and title use the theme's onSurface color
        iconTheme: IconThemeData(color: cs.onSurface),
        foregroundColor: cs.onSurface,
        leading: BackButton(color: cs.onSurface),
        title: Text(
          'Job Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HERO SECTION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATUS
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: job.isActive
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            job.isActive ? 'LIVE' : 'HIDDEN',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${job.totalApplications} Applications',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // TITLE
                Text(
                  job.workTitle.isEmpty ? 'Untitled Job' : job.workTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                // QUICK STATS
                Row(
                  children: [
                    _heroStat(
                      icon: Icons.groups_rounded,
                      label: 'Workers',
                      value: '${job.workersNeeded}',
                    ),
                    const SizedBox(width: 12),
                    if (job.estimatedBudget != null)
                      _heroStat(
                        icon: Icons.currency_rupee_rounded,
                        label: 'Budget',
                        value: '₹${job.estimatedBudget!.toStringAsFixed(0)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // TARGET
          if (job.target.isNotEmpty)
            _sectionCard(
              title: 'Hiring For',
              icon: Icons.person_search_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.target.map((t) {
                  return _chip(
                    label: _targetLabel(t),
                    color: const Color(0xFF0369A1),
                  );
                }).toList(),
              ),
            ),
          // BUSINESS TYPES
          if (job.businessTypes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Business Types',
              icon: Icons.business_center_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.businessTypes.map((id) {
                  final bt = businessTypes.firstWhere(
                    (b) => b.id == id,
                    orElse: () => BusinessTypeModel(
                      id: id,
                      enName: id,
                      hiName: '',
                      mrName: '',
                      category: '',
                    ),
                  );
                  return _chip(
                    label: bt.hiName.isNotEmpty ? bt.hiName : bt.enName,
                    color: primaryColor,
                  );
                }).toList(),
              ),
            ),
          ],
          // SKILLS
          if (job.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Required Skills',
              icon: Icons.build_circle_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.requiredSkills.take(5).map((id) {
                  final skill = skillsList.firstWhere(
                    (s) => s.id == id,
                    orElse: () =>
                        SkillModel(id: id, enName: id, hiName: '', mrName: ''),
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill.enName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (skill.hiName.isNotEmpty)
                          Text(
                            skill.hiName,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: primaryColor.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          // DESCRIPTION
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              title: 'About this Job',
              icon: Icons.notes_rounded,
              child: Text(
                job.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.78),
                  height: 1.7,
                ),
              ),
            ),
          ],
          // ADDRESS
          if (job.address.isNotEmpty || job.pincode.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Address',
              icon: Icons.location_city_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (job.address.isNotEmpty)
                    Text(
                      job.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  if (job.pincode.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Pincode : ${job.pincode}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // IMAGES
          if (job.images.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Site Images',
              icon: Icons.image_outlined,
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _ImageViewer(image: job.images[i]),
                          ),
                        );
                      },
                      child: Hero(
                        tag: job.images[i],
                        child: Container(
                          width: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              job.images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 30),
          // POSTED DATE
          Center(
            child: Text(
              job.createdAt != null
                  ? 'Posted on ${_fmtDate(job.createdAt)}'
                  : '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.outline.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        );
      },
    );
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String image;

  const _ImageViewer({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: image,
          child: InteractiveViewer(
            child: Image.network(image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
