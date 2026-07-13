import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_user.dart';
import '../utils/masking_utils.dart';

class LabourIdCard extends StatelessWidget {
  final MarketplaceUser user;
  final String skillLabel;
  final bool canViewSensitiveData;

  const LabourIdCard({
    super.key,
    required this.user,
    required this.skillLabel,
    required this.canViewSensitiveData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset('assets/images/app_logo.png'),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        loc.labourProfileCardTitle.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 24,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          backgroundImage: user.profilePhotoUrl != null
                              ? NetworkImage(user.profilePhotoUrl!)
                              : null,
                          child: user.profilePhotoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 34,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (skillLabel.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    skillLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.availability
                                        ? Colors.green.withValues(alpha: 0.16)
                                        : Colors.grey.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.availability
                                        ? loc.available
                                        : loc.busy,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: user.availability
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            label: loc.experienceYearsLabel,
                            value: user.experienceLabel,
                            icon: Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoChip(
                            label: loc.jobs,
                            value: user.completedJobs.toString(),
                            icon: Icons.work_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            label: loc.ratingLabel,
                            value: user.rating.toStringAsFixed(1),
                            icon: Icons.star,
                            valueColor: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoChip(
                            label: loc.cityLabelDropdown,
                            value: user.city.isEmpty
                                ? loc.notAvailable
                                : user.city,
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: loc.contactLabel,
                            value: canViewSensitiveData
                                ? user.mobile
                                : maskPhone(user.mobile),
                            valueStyle: valueStyle,
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: loc.email,
                            value: canViewSensitiveData
                                ? user.email
                                : maskEmail(user.email),
                            valueStyle: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: () => _showDetailsDialog(context, loc),
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 18,
                          ),
                          label: Text(loc.viewDetails),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDetailsDialog(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${loc.labourProfileCardTitle} • ${user.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user.profilePhotoUrl != null)
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: NetworkImage(user.profilePhotoUrl!),
                    ),
                  ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: loc.businessName,
                  value: user.businessName.isNotEmpty
                      ? user.businessName
                      : loc.professionUnknown,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.cityLabelDropdown,
                  value: user.city.isEmpty ? loc.notAvailable : user.city,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.experienceYearsLabel,
                  value: user.experienceLabel,
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.ratingLabel,
                  value: user.rating.toStringAsFixed(1),
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.jobs,
                  value: user.completedJobs.toString(),
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.contactLabel,
                  value: canViewSensitiveData
                      ? user.mobile
                      : maskPhone(user.mobile),
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.email,
                  value: canViewSensitiveData
                      ? user.email
                      : maskEmail(user.email),
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: loc.availabilityLabel,
                  value: user.availability ? loc.available : loc.busy,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.cancel),
            ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 76),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
