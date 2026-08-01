import 'package:flutter/material.dart';

import '../../../common/models/skill_model.dart';
import '../../../common/widgets/app_state_message.dart';
import '../../../common/widgets/loading_skeleton.dart';
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
    final labels = <String>[];
    for (final id in skillIds) {
      final index = _availableSkills.indexWhere((skill) => skill.id == id);
      if (index == -1) continue;

      final skill = _availableSkills[index];
      final label = switch (locale.toLowerCase()) {
        'hi' => skill.hiName.isNotEmpty ? skill.hiName : skill.enName,
        'mr' => skill.mrName.isNotEmpty ? skill.mrName : skill.enName,
        _ => skill.enName,
      };

      if (label.isNotEmpty) {
        labels.add(label);
      }
    }
    return labels.join(', ');
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
      final loc = AppLocalizations.of(context);
      setState(() {
        _error = (response['message'] ?? loc.couldNotLoadLabourList).toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (AuthService.isInUserInitiatedLogoutGrace) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(height: 10),
            Text('Logging out...'),
          ],
        ),
      );
    }

    final localeCode = Localizations.localeOf(context).languageCode;
    final selectedSkillLabels = _resolveSkillLabel(
      _filter.skillIds,
      localeCode,
    );
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allLabours.where((labour) {
      final haystack =
          '${labour.fullName} ${labour.city} ${labour.mobile} ${labour.experienceLabel}'
              .toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    if (_loading) {
      return const LoadingSkeleton(
        type: LoadingSkeletonType.card,
        itemCount: 3,
      );
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppStateMessage(
            icon: Icons.badge_outlined,
            title: loc.couldNotLoadLabourList,
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadLabours, child: Text(loc.retry)),
        ],
      );
    }

    final headerSection = Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  loc.subscriptionInactiveLabourMasked,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 9,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: loc.searchLabour,
                    hintText: loc.searchLabourHint,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: Tooltip(
                    message: loc.filterLabel,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<MarketplaceFilter>(
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
                      child: const Icon(Icons.filter_list, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_filter.hasAnyFilter)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${loc.activeFilterLabel} ${_filter.city.isNotEmpty ? '${loc.filterCity}${_filter.city}; ' : ''}${_filter.minRating > 0 ? '${loc.filterRating}${_filter.minRating}; ' : ''}${_filter.minExperience > 0 ? '${loc.filterExperience}${_filter.minExperience}; ' : ''}${_filter.skillIds.isNotEmpty ? '${loc.filterSkills}${selectedSkillLabels.isNotEmpty ? selectedSkillLabels : _filter.skillIds.join(', ')}; ' : ''}'
                          .trim(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        _filter = const MarketplaceFilter();
                      });
                      await _loadLabours(useSavedCity: false);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    label: Text(loc.clearLabel),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final contentSection = filtered.isEmpty
        ? ListView(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            children: [
              AppStateMessage(
                icon: Icons.credit_card_off,
                title: loc.noLabourProfilesFound,
                subtitle: loc.tryAnotherSearchKeyword,
              ),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
          );

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
      child: Column(
        children: [
          headerSection,
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadLabours(useSavedCity: false),
              child: contentSection,
            ),
          ),
        ],
      ),
    );
  }
}
