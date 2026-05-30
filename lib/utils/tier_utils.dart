import 'package:flutter/material.dart';

class TierInfo {
  final String name;
  final Color color;
  final IconData icon;

  TierInfo({
    required this.name,
    required this.color,
    required this.icon,
  });
}

class TierUtils {
  static TierInfo getTierForReviewCount(int count) {
    if (count >= 100) {
      return TierInfo(
        name: "Diamond",
        color: const Color(0xFFB9F2FF), // Light blue Diamond
        icon: Icons.diamond,
      );
    } else if (count >= 50) {
      return TierInfo(
        name: "Platinum",
        color: const Color(0xFF1ABC9C), // Teal Platinum
        icon: Icons.verified,
      );
    } else if (count >= 25) {
      return TierInfo(
        name: "Gold",
        color: const Color(0xFFFFD700), // Gold
        icon: Icons.military_tech,
      );
    } else if (count >= 10) {
      return TierInfo(
        name: "Silver",
        color: const Color(0xFFC0C0C0), // Silver
        icon: Icons.military_tech,
      );
    } else if (count >= 3) {
      return TierInfo(
        name: "Bronze",
        color: const Color(0xFFCD7F32), // Bronze
        icon: Icons.military_tech,
      );
    } else {
      return TierInfo(
        name: "Iron",
        color: const Color(0xFF696969), // Dim Gray
        icon: Icons.circle, // Basic
      );
    }
  }
}
