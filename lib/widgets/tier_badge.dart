import 'package:flutter/material.dart';
import '../utils/tier_utils.dart';

class TierBadge extends StatelessWidget {
  final int reviewCount;
  final bool showLabel;

  const TierBadge({
    super.key,
    required this.reviewCount,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final tier = TierUtils.getTierForReviewCount(reviewCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33), // Dark gaming-style background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tier.color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tier.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tier.icon, size: 16, color: tier.color),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              tier.name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: tier.color,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
