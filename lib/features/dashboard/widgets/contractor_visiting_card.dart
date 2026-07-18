import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/models/business_type_model.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_user.dart';
import '../utils/masking_utils.dart';

class ContractorVisitingCard extends StatelessWidget {
  final MarketplaceUser user;
  final bool canViewSensitiveData;
  final List<BusinessTypeModel> availableBusinessTypes;

  const ContractorVisitingCard({
    super.key,
    required this.user,
    required this.canViewSensitiveData,
    required this.availableBusinessTypes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : Colors.white;
    final cardBorderColor = isDark
        ? theme.colorScheme.outline.withValues(alpha: 0.55)
        : theme.colorScheme.onSurface.withValues(alpha: 0.16);
    final cardShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.08);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 4,
      shadowColor: cardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardBorderColor, width: 1.4),
      ),
      child: InkWell(
        onTap: () => _showProfileSheet(context),
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Opacity(
                      opacity: 0.10,
                      child: Image.asset(
                        'assets/logo.jpg',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.businessName.isEmpty
                                  ? user.fullName.toUpperCase()
                                  : user.businessName.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.userType.toLowerCase() == 'contractor'
                                  ? '---- ${loc.contractorRoleTitle.toUpperCase()}'
                                  : '---- ${loc.subcontractorRoleTitle.toUpperCase()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (_businessTypeLabel(context).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _businessTypeLabel(context),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: user.logoUrl != null
                            ? NetworkImage(user.logoUrl!)
                            : null,
                        child: user.logoUrl == null
                            ? Icon(
                                Icons.business,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: canViewSensitiveData
                        ? () => _launchPhone(user.mobile)
                        : null,
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            canViewSensitiveData
                                ? user.mobile
                                : maskPhone(user.mobile),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: canViewSensitiveData
                              ? () => _launchEmail(user.email)
                              : null,
                          child: Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  canViewSensitiveData
                                      ? user.email
                                      : maskEmail(user.email),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.city.isEmpty
                                    ? loc.notSpecified
                                    : user.city,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        canViewSensitiveData
                            ? loc.businessProfile.toUpperCase()
                            : loc.subscriptionRequired.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _businessTypeLabel(BuildContext context) {
    if (user.businessTypes.isEmpty) return '';

    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    final labels = <String>[];

    for (final typeId in user.businessTypes) {
      if (typeId.isEmpty) continue;
      final match = availableBusinessTypes.firstWhere(
        (type) => type.id == typeId,
        orElse: () => BusinessTypeModel(
          id: typeId,
          enName: typeId,
          hiName: '',
          mrName: '',
          category: '',
        ),
      );

      final label = switch (locale) {
        'hi' => match.hiName.isNotEmpty ? match.hiName : match.enName,
        'mr' => match.mrName.isNotEmpty ? match.mrName : match.enName,
        _ => match.enName,
      };

      if (label.isNotEmpty) {
        labels.add(label);
      }
    }

    return labels.join(', ');
  }

  Future<void> _showProfileSheet(BuildContext context) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final loc = AppLocalizations.of(sheetContext);
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 52,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.businessName.isEmpty
                                        ? user.fullName
                                        : user.businessName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.userType.toLowerCase() == 'contractor'
                                        ? loc.contractorRoleTitle
                                        : loc.subcontractorRoleTitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (user.logoUrl != null)
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(user.logoUrl!),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (user.profilePhotoUrl != null)
                          Center(
                            child: CircleAvatar(
                              radius: 44,
                              backgroundImage: NetworkImage(
                                user.profilePhotoUrl!,
                              ),
                            ),
                          ),
                        if (user.profilePhotoUrl != null)
                          const SizedBox(height: 18),
                        _DetailRow(label: loc.fullName, value: user.fullName),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.skillsLabel,
                          value: user.skills.isNotEmpty
                              ? user.skills.join(', ')
                              : loc.notSpecified,
                        ),
                        if (_businessTypeLabel(sheetContext).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: loc.businessTypesLabel,
                            value: _businessTypeLabel(sheetContext),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.mobileNumber,
                          value: canViewSensitiveData
                              ? user.mobile
                              : maskPhone(user.mobile),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.email,
                          value: canViewSensitiveData ? user.email : loc.hidden,
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.cityLabel,
                          value: user.city.isEmpty
                              ? loc.notSpecified
                              : user.city,
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.experienceYearsLabel,
                          value: user.experienceLabel,
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.ratingLabel,
                          value: user.rating.toStringAsFixed(1),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.jobs,
                          value: user.completedJobs.toString(),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: loc.availabilityLabel,
                          value: user.availability
                              ? loc.available
                              : loc.currentlyBusy,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
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
