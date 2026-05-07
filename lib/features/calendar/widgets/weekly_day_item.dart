import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WeeklyDayItem extends StatelessWidget {
  final String dayName;
  final String date;
  final bool isActive;

  const WeeklyDayItem({
    super.key,
    required this.dayName,
    required this.date,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayName.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 1.5,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 52,
          height: 64,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : AppColors.onSurface,
                ),
              ),
              if (isActive)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
