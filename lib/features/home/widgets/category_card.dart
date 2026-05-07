import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String taskCount;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? iconContainerColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.taskCount,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.iconContainerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconContainerColor ?? AppColors.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: foregroundColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                ),
              ),
              Text(
                taskCount,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
