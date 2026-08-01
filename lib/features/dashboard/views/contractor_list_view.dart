import 'package:flutter/material.dart';

import '../../../common/models/business_type_model.dart';
import '../../../common/widgets/app_state_message.dart';
import '../../../common/widgets/loading_skeleton.dart';
import '../../../services/api_service.dart';
import '../../../services/business_type_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_filter.dart';
import '../models/marketplace_user.dart';
import '../widgets/contractor_visiting_card.dart';
import '../widgets/marketplace_filter_sheet.dart';
import '../../../core/auth_service.dart';

class ContractorListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const ContractorListView({super.key, required this.canViewSensitiveData});

  @override
  State<ContractorListView> createState() => _ContractorListViewState();
}

class _ContractorListViewState extends State<ContractorListView> {
  final TextEditingController _searchController = TextEditingController();
  final List<BusinessTypeModel> _availableBusinessTypes = [];
  MarketplaceFilter _filter = const MarketplaceFilter();
  List<MarketplaceUser> _allContractors = [];
  bool _loading = true;
  String? _error;

  String _resolveBusinessTypeLabel(
    List<String> businessTypeIds,
    String locale,
  ) {
    final labels = <String>[];
    for (final id in businessTypeIds) {
      final index = _availableBusinessTypes.indexWhere((item) => item.id == id);
      if (index == -1) continue;

      final businessType = _availableBusinessTypes[index];
      final label = switch (locale.toLowerCase()) {
        'hi' =>
          businessType.hiName.isNotEmpty
              ? businessType.hiName
              : businessType.enName,
        'mr' =>
          businessType.mrName.isNotEmpty
              ? businessType.mrName
              : businessType.enName,
        _ => businessType.enName,
      };

      if (label.isNotEmpty) {
        labels.add(label);
      }
    }
    return labels.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadAvailableBusinessTypes();
    _loadContractors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBusinessTypes() async {
    final result = await BusinessTypeService.getAllBusinessTypes();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _availableBusinessTypes.clear();
        _availableBusinessTypes.addAll(
          (result['businessTypes'] as List<BusinessTypeModel>),
        );
      });
    }
  }

  Future<void> _loadContractors({bool useSavedCity = true}) async {
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

    final response = await ApiService.fetchContractors(filter: _filter);
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allContractors = users
            .map(
              (user) => MarketplaceUser.fromJson(user as Map<String, dynamic>),
            )
            .where(
              (user) =>
                  user.userType == 'contractor' ||
                  user.userType == 'sub_contractor',
            )
            .toList();
        _loading = false;
      });
    } else {
      final loc = AppLocalizations.of(context);
      setState(() {
        _error = (response['message'] ?? loc.couldNotLoadContractors)
            .toString();
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
    final selectedBusinessTypeLabels = _resolveBusinessTypeLabel(
      _filter.businessTypeIds,
      localeCode,
    );
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allContractors.where((contractor) {
      final haystack =
          '${contractor.businessName} ${contractor.fullName} ${contractor.city} ${contractor.mobile}'
              .toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    if (_loading) {
      return const LoadingSkeleton(
        type: LoadingSkeletonType.contractorCard,
        itemCount: 3,
      );
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppStateMessage(
            icon: Icons.wifi_off,
            title: loc.couldNotLoadContractors,
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadContractors, child: Text(loc.retry)),
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
                  loc.subscriptionInactiveContractorMasked,
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
                    labelText: loc.searchContractor,
                    hintText: loc.searchContractorHint,
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
                                skills: const [],
                                businessTypes: _availableBusinessTypes,
                                isLabourPage: false,
                              ),
                            );
                        if (result != null) {
                          setState(() {
                            _filter = result;
                          });
                          await _loadContractors(useSavedCity: false);
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
                      '${loc.activeFilterLabel} ${_filter.city.isNotEmpty ? '${loc.filterCity}${_filter.city}; ' : ''}${_filter.minRating > 0 ? '${loc.filterRating}${_filter.minRating}; ' : ''}${_filter.minExperience > 0 ? '${loc.filterExperience}${_filter.minExperience}; ' : ''}${_filter.businessTypeIds.isNotEmpty ? '${loc.filterBusinessTypes}${selectedBusinessTypeLabels.isNotEmpty ? selectedBusinessTypeLabels : _filter.businessTypeIds.join(', ')}; ' : ''}'
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
                      await _loadContractors(useSavedCity: false);
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
                icon: Icons.search_off,
                title: loc.noContractorsFound,
                subtitle: loc.tryAnotherSearchKeyword,
              ),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            itemCount: filtered.length,
            itemBuilder: (_, index) {
              final contractor = filtered[index];
              return ContractorVisitingCard(
                user: contractor,
                canViewSensitiveData: widget.canViewSensitiveData,
                availableBusinessTypes: _availableBusinessTypes,
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
              onRefresh: () => _loadContractors(useSavedCity: false),
              child: contentSection,
            ),
          ),
        ],
      ),
    );
  }
}
