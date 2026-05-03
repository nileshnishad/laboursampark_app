import 'package:flutter/material.dart';

import '../../../common/widgets/app_state_message.dart';
import '../../../services/api_service.dart';
import '../models/marketplace_user.dart';
import '../widgets/labour_id_card.dart';

class LabourListView extends StatefulWidget {
  final bool canViewSensitiveData;

  const LabourListView({super.key, required this.canViewSensitiveData});

  @override
  State<LabourListView> createState() => _LabourListViewState();
}

class _LabourListViewState extends State<LabourListView> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketplaceUser> _allLabours = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadLabours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLabours() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService.fetchLabours();
    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      final users = (data?['users'] as List<dynamic>? ?? const []);
      setState(() {
        _allLabours = users
            .map((user) => MarketplaceUser.fromJson(user as Map<String, dynamic>))
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

    return RefreshIndicator(
      onRefresh: _loadLabours,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (!widget.canViewSensitiveData)
            Card(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Subscription inactive. Labour contact details are masked. Activate subscription to unlock full details and apply/create actions.',
                ),
              ),
            ),
          if (!widget.canViewSensitiveData) const SizedBox(height: 10),
          Text(
            'Labour ID Cards',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search labour',
              hintText: 'Name, city, or mobile',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const AppStateMessage(
              icon: Icons.credit_card_off,
              title: 'No labour profiles found',
              subtitle: 'Try another search keyword.',
            )
          else
            ...filtered.map(
              (labour) => LabourIdCard(
                user: labour,
                canViewSensitiveData: widget.canViewSensitiveData,
              ),
            ),
        ],
      ),
    );
  }
}
