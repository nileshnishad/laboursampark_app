import 'package:flutter/material.dart';
import 'profile_field.dart';

class VerificationSection extends StatelessWidget {
  final bool emailVerified;
  final bool mobileVerified;
  final bool aadharVerified;

  const VerificationSection({
    required this.emailVerified,
    required this.mobileVerified,
    required this.aadharVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ProfileField(
              label: 'Email Verified',
              value: emailVerified ? 'Yes' : 'No',
            ),
            ProfileField(
              label: 'Mobile Verified',
              value: mobileVerified ? 'Yes' : 'No',
            ),
            ProfileField(
              label: 'Aadhaar Verified',
              value: aadharVerified ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }
}
