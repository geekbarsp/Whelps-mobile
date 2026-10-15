import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'components.dart';

class QuickAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const QuickAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color = FurUColors.sage,
  });
  @override
  Widget build(BuildContext context) => FurUPress(
    child: Material(
      color: color,
      elevation: 1,
      shadowColor: const Color(0x1A203B32),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: FurUColors.forest, size: 23),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: FurUColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, height: 1.4)),
            ],
          ),
        ),
      ),
    ),
  );
}
