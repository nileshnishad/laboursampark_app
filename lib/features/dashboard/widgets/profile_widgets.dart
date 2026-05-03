import 'package:flutter/material.dart';

/// Pill badge (e.g. "SKILLED WORKER", "ID: #ABC123")
class ProfileBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const ProfileBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final bg =
        color != null ? color!.withValues(alpha: 0.1) : const Color(0xFFF3F4F6);
    final border =
        color != null ? color!.withValues(alpha: 0.3) : const Color(0xFFD1D5DB);
    final text = color ?? const Color(0xFF374151);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: text, letterSpacing: 0.3)),
    );
  }
}

/// Status info column (label + value) used in the STATUS / VISIBLE / AVAILABILITY row
class ProfileStatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const ProfileStatusItem(
      {super.key, required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1.3)),
      ],
    );
  }
}

/// Data class for a single info chip in the profile grid
class ProfileInfoItem {
  final String label;
  final String value;
  final Color? valueColor;

  const ProfileInfoItem(
      {required this.label, required this.value, this.valueColor});
}

/// 2-column grid of info chips (label on top, value below)
class ProfileInfoGrid extends StatelessWidget {
  final List<ProfileInfoItem> items;

  const ProfileInfoGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 76) / 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(item.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.valueColor ?? const Color(0xFF111827),
                        height: 1.3)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Section card — coloured left border, collapsible, with consistent header
class ProfileSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  State<ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<ProfileSectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                        color: widget.color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 10),
                  Icon(widget.icon, size: 16, color: widget.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: 0.4),
                    ),
                  ),
                  Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 20),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(padding: const EdgeInsets.all(14), child: widget.child),
          ],
        ],
      ),
    );
  }
}

/// Action row for Settings / Logout / Refresh
class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF374151);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: c))),
            Icon(Icons.chevron_right_rounded,
                color: const Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}
