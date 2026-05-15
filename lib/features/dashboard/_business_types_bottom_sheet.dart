import 'package:flutter/material.dart';

class BusinessTypesBottomSheet extends StatelessWidget {
  final List<dynamic> availableBusinessTypes;
  final List<String> selectedBusinessTypeIds;
  final Color primaryColor;
  final void Function(List<String>) onSelectionChanged;

  const BusinessTypesBottomSheet({
    super.key,
    required this.availableBusinessTypes,
    required this.selectedBusinessTypeIds,
    required this.primaryColor,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tempSelected = List<String>.from(selectedBusinessTypeIds);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.category_outlined, color: Color(0xFF2563EB)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Business Types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Choose multiple business types', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: availableBusinessTypes.isEmpty
                ? const Center(child: Text('No business types available', style: TextStyle(color: Color(0xFF6B7280))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableBusinessTypes.length,
                    itemBuilder: (context, index) {
                      final bt = availableBusinessTypes[index];
                      final isSelected = tempSelected.contains(bt.id);
                      return InkWell(
                        onTap: () {
                          if (isSelected) {
                            tempSelected.remove(bt.id);
                          } else {
                            tempSelected.add(bt.id);
                          }
                          onSelectionChanged(List<String>.from(tempSelected));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withOpacity(0.08) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bt.enName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? primaryColor : const Color(0xFF111827))),
                                    if (bt.hiName.isNotEmpty)
                                      Text(bt.hiName, style: TextStyle(fontSize: 12, color: isSelected ? primaryColor : const Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${tempSelected.length} selected',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
