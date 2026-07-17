import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.35,
                      child: Opacity(
                        opacity: 0.05,
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.14,
                          ),
                          image: user.profilePhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.profilePhotoUrl == null
                            ? Icon(
                                Icons.person,
                                size: 82,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: user.availability
                                    ? Colors.green.withValues(alpha: 0.16)
                                    : Colors.grey.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                user.availability
                                    ? Icons.check_circle
                                    : Icons.remove_circle_outline,
                                color: user.availability
                                    ? Colors.green.shade700
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: canViewSensitiveData
                                  ? () => _launchPhone(user.mobile)
                                  : null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      canViewSensitiveData
                                          ? user.mobile
                                          : maskPhone(user.mobile),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.phone, size: 16),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            InkWell(
                              onTap: canViewSensitiveData
                                  ? () => _launchEmail(user.email)
                                  : null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      canViewSensitiveData
                                          ? user.email
                                          : maskEmail(user.email),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.email, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${loc.fullName}:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.82,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (skillLabel.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${loc.skillsLabel}:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.84,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            skillLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBlock(
                          label: loc.experienceYearsLabel,
                          value: user.experienceLabel,
                          icon: Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: _StatBlock(
                          label: loc.ratingLabel,
                          value: user.rating.toStringAsFixed(1),
                          icon: Icons.star,
                          iconColor: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBlock(
                          label: loc.cityLabelDropdown,
                          value: user.city.isEmpty
                              ? loc.notAvailable
                              : user.city,
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: _StatBlock(
                          label: loc.jobs,
                          value: user.completedJobs.toString(),
                          icon: Icons.work_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  FilledButton(
                    onPressed: () => _showDetailsSheet(context, loc),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      loc.viewDetails,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetailsSheet(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 52,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              loc.labourProfileCardTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (user.profilePhotoUrl != null)
                              Center(
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundImage: NetworkImage(
                                    user.profilePhotoUrl!,
                                  ),
                                ),
                              ),
                            if (user.profilePhotoUrl != null)
                              const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _DetailRow(
                                      label: loc.fullName,
                                      value: user.fullName,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.skillsLabel,
                                      value: skillLabel.isNotEmpty
                                          ? skillLabel
                                          : loc.notAvailable,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.cityLabelDropdown,
                                      value: user.city.isEmpty
                                          ? loc.notAvailable
                                          : user.city,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.experienceYearsLabel,
                                      value: user.experienceLabel,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.ratingLabel,
                                      value: user.rating.toStringAsFixed(1),
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.jobs,
                                      value: user.completedJobs.toString(),
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.contactLabel,
                                      value: canViewSensitiveData
                                          ? user.mobile
                                          : maskPhone(user.mobile),
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.email,
                                      value: canViewSensitiveData
                                          ? user.email
                                          : maskEmail(user.email),
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      label: loc.availabilityLabel,
                                      value: user.availability
                                          ? loc.available
                                          : loc.busy,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch phone dialer for $phone');
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch email client for $email');
    }
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
