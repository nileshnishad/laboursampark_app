import 'package:flutter/material.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final String label;
  const ProfilePhotoPicker({super.key, this.imagePath, required this.onPick, required this.label});

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
                    Icons.camera_alt,
                    size: 32,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
