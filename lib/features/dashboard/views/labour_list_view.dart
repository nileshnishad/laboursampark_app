import 'package:flutter/material.dart';

import '../../../common/models/skill_model.dart';
import '../../../common/widgets/app_state_message.dart';
import '../../../services/api_service.dart';
import '../../../services/skills_service.dart';
import '../../../core/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_filter.dart';
import '../models/marketplace_user.dart';
import '../widgets/labour_id_card.dart';
import '../widgets/marketplace_filter_sheet.dart';

class LabourListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const LabourListView({super.key, required this.canViewSensitiveData});

  @override
  State<LabourListView> createState() => _LabourListViewState();
}

class _LabourListViewState extends State<LabourListView> {
  final TextEditingController _searchController = TextEditingController();
  final List<SkillModel> _availableSkills = [];
  MarketplaceFilter _filter = const MarketplaceFilter();
  List<MarketplaceUser> _allLabours = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadAvailableSkills();
    _loadLabours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSkills() async {
    final skillsResult = await SkillsService.getAllSkills();
    if (!mounted) return;
    if (skillsResult['success'] == true) {
      setState(() {
        _availableSkills.clear();
        _availableSkills.addAll((skillsResult['skills'] as List<SkillModel>));
      });
    }
  }

  String _resolveSkillLabel(List<String> skillIds, String locale) {
    for (final id in skillIds) {
      final index = _availableSkills.indexWhere((skill) => skill.id == id);
      if (index != -1) {
        final skill = _availableSkills[index];
        switch (locale.toLowerCase()) {
          case 'hi':
            return skill.hiName.isNotEmpty ? skill.hiName : skill.enName;
          case 'mr':
            return skill.mrName.isNotEmpty ? skill.mrName : skill.enName;
          default:
            return skill.enName;
        }
      }
    }
    return '';
  }

  Future<void> _loadLabours({bool useSavedCity = true}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (useSavedCity) {
      final userData = await AuthService.getUserData();
      final location = userData?['location'] as Map<String, dynamic>?;
      final savedCity = (userData?['city'] ?? location?['city'] ?? '')
          .toString();
      if (savedCity.isNotEmpty && _filter.city.isEmpty) {
        _filter = _filter.copyWith(city: savedCity);
      }
    }

    final response = await ApiService.fetchLabours(filter: _filter);
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allLabours = users
            .map(
              (user) => MarketplaceUser.fromJson(user as Map<String, dynamic>),
            )
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (response['message'] ?? 'Unable to load labours').toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allLabours.where((labour) {
      final haystack =
          '${labour.fullName} ${labour.city} ${labour.mobile} ${labour.experienceLabel}'
              .toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppStateMessage(
            icon: Icons.badge_outlined,
            title: 'Could not load labour list',
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadLabours, child: const Text('Retry')),
        ],
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1600
        ? 4
        : width >= 1100
        ? 3
        : width >= 760
        ? 2
        : 1;
    final crossAxisSpacing = 12.0;
    final horizontalPadding = width >= 1100 ? 28.0 : 16.0;
    final itemWidth =
        (width - horizontalPadding - crossAxisSpacing * (crossAxisCount - 1)) /
        crossAxisCount;
    final desiredItemHeight = width >= 1600
        ? 380
        : width >= 1100
        ? 360
        : width >= 760
        ? 380
        : 380;
    final childAspectRatio = itemWidth / desiredItemHeight;

    return RefreshIndicator(
      onRefresh: () => _loadLabours(useSavedCity: false),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Subscription inactive. Labour contact details are masked. Activate subscription to unlock full details and apply/create actions.',
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.labourProfiles,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text(loc.filterLabel),
                onPressed: () async {
                  final result = await showModalBottomSheet<MarketplaceFilter>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => MarketplaceFilterSheet(
                      initialFilter: _filter,
                      skills: _availableSkills,
                      businessTypes: const [],
                      isLabourPage: true,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _filter = result;
                    });
                    await _loadLabours(useSavedCity: false);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: loc.searchLabour,
              hintText: loc.searchLabourHint,
            ),
          ),
          const SizedBox(height: 12),
          if (_filter.hasAnyFilter)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Active filter: ${_filter.city.isNotEmpty ? 'City=${_filter.city}; ' : ''}${_filter.minRating > 0 ? 'Rating≥${_filter.minRating}; ' : ''}${_filter.minExperience > 0 ? 'Experience≥${_filter.minExperience}; ' : ''}${_filter.skillIds.isNotEmpty ? 'Skills=${_filter.skillIds.length}; ' : ''}'
                    .trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          if (filtered.isEmpty)
            AppStateMessage(
              icon: Icons.credit_card_off,
              title: loc.noLabourProfilesFound,
              subtitle: loc.tryAnotherSearchKeyword,
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final user = filtered[index];
                final skillLabel = _resolveSkillLabel(
                  user.skills,
                  Localizations.localeOf(context).languageCode,
                );

                return LabourIdCard(
                  user: user,
                  skillLabel: skillLabel,
                  canViewSensitiveData: widget.canViewSensitiveData,
                );
              },
            ),
        ],
      ),
    );
  }
}
