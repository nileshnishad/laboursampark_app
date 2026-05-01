import 'package:flutter/material.dart';
import '../models/marketplace_user.dart';
import '../utils/masking_utils.dart';

class ContractorVisitingCard extends StatelessWidget {
  final MarketplaceUser user;
  final bool canViewSensitiveData;

  const ContractorVisitingCard({
    required this.user,
    required this.canViewSensitiveData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
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
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        canViewSensitiveData
                            ? user.mobile
                            : maskPhone(user.mobile),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: user.logoUrl != null
                      ? NetworkImage(user.logoUrl!)
                      : null,
                  child: user.logoUrl == null
                      ? Icon(
                          Icons.business,
                          color: theme.colorScheme.secondary,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(canViewSensitiveData
                ? user.mobile
                : maskPhone(user.mobile)),
            const SizedBox(height: 2),
            Text(user.city.isEmpty ? 'Not specified' : user.city),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(user.rating.toStringAsFixed(1)),
                const Spacer(),
                Text(
                  canViewSensitiveData
                      ? 'BUSINESS PROFILE'
                      : 'SUBSCRIPTION REQUIRED',
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
    );
  }
}
