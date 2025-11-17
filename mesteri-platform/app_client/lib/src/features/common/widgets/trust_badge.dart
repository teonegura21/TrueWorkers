import 'package:flutter/material.dart';

enum TrustBadgeType { verified, premium, secure, rated, active }

class TrustBadge extends StatelessWidget {
  final bool isVerified;
  final bool isPremium;
  final TrustBadgeType? type;
  final double? size;
  final bool showLabel;
  final VoidCallback? onTap;

  const TrustBadge({
    super.key,
    this.isVerified = false,
    this.isPremium = false,
    this.type,
    this.size,
    this.showLabel = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeType =
        type ??
        (isPremium
            ? TrustBadgeType.premium
            : (isVerified ? TrustBadgeType.verified : TrustBadgeType.active));
    final iconSize = size ?? 16;

    Color color;
    IconData icon;
    String label;

    switch (badgeType) {
      case TrustBadgeType.premium:
        color = Colors.amber;
        icon = Icons.star;
        label = 'Premium';
        break;
      case TrustBadgeType.verified:
        color = Colors.blue;
        icon = Icons.verified;
        label = 'Verified';
        break;
      case TrustBadgeType.secure:
        color = Colors.green;
        icon = Icons.security;
        label = 'Secure';
        break;
      case TrustBadgeType.rated:
        color = Colors.orange;
        icon = Icons.star_rate;
        label = 'Rated';
        break;
      case TrustBadgeType.active:
      default:
        color = Colors.grey;
        icon = Icons.check_circle;
        label = 'Active';
        break;
    }

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.white),
          if (showLabel) const SizedBox(width: 4),
          if (showLabel)
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: iconSize * 0.75),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: badge);
    }

    return badge;
  }
}
