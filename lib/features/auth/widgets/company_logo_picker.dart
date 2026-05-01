import 'package:flutter/material.dart';

class CompanyLogoPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  const CompanyLogoPicker({super.key, this.imagePath, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPick,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: imagePath != null ? AssetImage(imagePath!) : null,
            child: imagePath == null
                ? Icon(Icons.add_business, size: 32, color: Colors.grey[600])
                : null,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Company Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
