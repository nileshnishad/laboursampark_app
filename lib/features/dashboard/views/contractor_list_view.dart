import 'package:flutter/material.dart';

import '../../../common/widgets/app_state_message.dart';
import '../../../services/api_service.dart';
import '../models/marketplace_user.dart';
import '../widgets/contractor_visiting_card.dart';

class ContractorListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const ContractorListView({super.key, required this.canViewSensitiveData});

  @override
  State<ContractorListView> createState() => _ContractorListViewState();
}

class _ContractorListViewState extends State<ContractorListView> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketplaceUser> _allContractors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadContractors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContractors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService.fetchContractors();
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allContractors = users
            .map((user) => MarketplaceUser.fromJson(user as Map<String, dynamic>))
            .where((user) =>
                user.userType == 'contractor' || user.userType == 'sub_contractor')
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (response['message'] ?? 'Unable to load contractors').toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allContractors.where((contractor) {
      final haystack =
          '${contractor.businessName} ${contractor.fullName} ${contractor.city} ${contractor.mobile}'
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
            icon: Icons.wifi_off,
            title: 'Could not load contractors',
            subtitle: _error!,
          ),
          TextButton(onPressed: _loadContractors, child: const Text('Retry')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContractors,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Subscription inactive. Contact details are masked. Activate subscription to view full details and use job actions.',
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Verified Contractors',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${filtered.length}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search contractor',
              hintText: 'Name, city, or mobile',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const AppStateMessage(
              icon: Icons.search_off,
              title: 'No contractors found',
              subtitle: 'Try another search keyword.',
            )
          else
            ...filtered.map(
              (contractor) => ContractorVisitingCard(
                user: contractor,
                canViewSensitiveData: widget.canViewSensitiveData,
              ),
            ),
        ],
      ),
    );
  }
}
