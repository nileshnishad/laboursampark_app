import 'package:flutter/material.dart';

class CompanyLogoPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  const CompanyLogoPicker({super.key, this.imagePath, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onPick,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: imagePath != null ? AssetImage(imagePath!) : null,
            child: imagePath == null
                ? Icon(
                    Icons.add_business,
                    size: 32,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Company Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
