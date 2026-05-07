import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TimelineTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeRange;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Color indicatorColor;
  final List<String>? participants;
  final IconData? icon;
  final bool isBreak;

  const TimelineTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeRange,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    required this.indicatorColor,
    this.participants,
    this.icon,
    this.isBreak = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBreak) {
      return Padding(
        padding: const EdgeInsets.only(left: 48, top: 8, bottom: 8),
        child: Row(
          children: [
            Text(
              timeRange,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outline.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon ?? Icons.restaurant,
              size: 20,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical guide with node
            Column(
              children: [
                Container(width: 1, height: 12, color: AppColors.outline.withValues(alpha: 0.1)),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: indicatorColor, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(width: 1, color: AppColors.outline.withValues(alpha: 0.1)),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Task Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: indicatorColor == AppColors.primary
                      ? AppColors.surfaceContainer
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeRange,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: indicatorColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor ?? AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: badgeTextColor ?? AppColors.onSecondaryContainer,
                                letterSpacing: 1.0,
                              ),
                            ),
                          )
                        else if (icon != null)
                          Icon(icon, color: indicatorColor, size: 20),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                    if (participants != null && participants!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 24,
                        child: Stack(
                          children: List.generate(participants!.length, (index) {
                            return Positioned(
                              left: index * 16.0,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.surfaceContainerLowest,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundImage: participants![index].startsWith('assets/')
                                    ? AssetImage(participants![index]) as ImageProvider
                                    : NetworkImage(participants![index]),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
