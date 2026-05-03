import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../models/job_history_entry.dart';
import '../widgets/history_card.dart';
import '../widgets/stat_card.dart';

class HistoryView extends StatefulWidget {
  final String token;
  final String userType;

  const HistoryView({super.key, required this.token, required this.userType});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<JobHistoryEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.fetchJobHistory(widget.token);
    if (!mounted) return;
    if (result['success'] == true) {
      final list = (result['data'] as List? ?? []);
      setState(() {
        _entries = list
            .map((e) => JobHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = (result['message'] ?? 'Failed to load history').toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'accepted':
        return const Color(0xFF2563EB);
      case 'applied':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'accepted':
        return Icons.thumb_up_rounded;
      case 'applied':
        return Icons.send_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'COMPLETED';
      case 'accepted':
        return 'ACCEPTED';
      case 'applied':
        return 'APPLIED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF374151))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  size: 36, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 14),
            const Text('No History Yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 6),
            const Text('Your job applications will appear here.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    final completedCount =
        _entries.where((e) => e.status == 'completed').length;
    final acceptedCount = _entries.where((e) => e.status == 'accepted').length;
    final appliedCount = _entries.where((e) => e.status == 'applied').length;
    final rejectedCount = _entries.where((e) => e.status == 'rejected').length;
    final isContractorView = widget.userType == 'contractor';

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Summary stat row
          if (isContractorView)
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        label: 'Applied',
                        value: appliedCount.toString(),
                        color: const Color(0xFFF59E0B),
                        icon: Icons.send_rounded)),
                const SizedBox(width: 6),
                Expanded(
                    child: StatCard(
                        label: 'Accepted',
                        value: acceptedCount.toString(),
                        color: const Color(0xFF2563EB),
                        icon: Icons.thumb_up_rounded)),
                const SizedBox(width: 6),
                Expanded(
                    child: StatCard(
                        label: 'Done',
                        value: completedCount.toString(),
                        color: const Color(0xFF059669),
                        icon: Icons.check_circle_rounded)),
                const SizedBox(width: 6),
                Expanded(
                    child: StatCard(
                        label: 'Rejected',
                        value: rejectedCount.toString(),
                        color: const Color(0xFFDC2626),
                        icon: Icons.cancel_rounded)),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        label: 'Applied',
                        value: appliedCount.toString(),
                        color: const Color(0xFFF59E0B),
                        icon: Icons.send_rounded)),
                const SizedBox(width: 8),
                Expanded(
                    child: StatCard(
                        label: 'Accepted',
                        value: acceptedCount.toString(),
                        color: const Color(0xFF2563EB),
                        icon: Icons.thumb_up_rounded)),
                const SizedBox(width: 8),
                Expanded(
                    child: StatCard(
                        label: 'Completed',
                        value: completedCount.toString(),
                        color: const Color(0xFF059669),
                        icon: Icons.check_circle_rounded)),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Text(
                isContractorView
                    ? 'APPLICATIONS RECEIVED (${_entries.length})'
                    : 'JOB APPLICATIONS (${_entries.length})',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._entries.map((entry) => HistoryCard(
                entry: entry,
                isContractorView: isContractorView,
                statusColor: _statusColor(entry.status),
                statusIcon: _statusIcon(entry.status),
                statusLabel: _statusLabel(entry.status),
                formatDate: _formatShortDate,
              )),
        ],
      ),
    );
  }
}

