import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final bool showPercentage;
  final String unit;

  const NutritionProgressBar({
    Key? key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.showPercentage = true,
    this.unit = '',
  }) : super(key: key);

  double get percentage => (current / goal).clamp(0.0, 1.0);
  
  bool get isComplete => current >= goal;

  Color get progressColor {
    if (isComplete) {
      return AppColors.secondary;
    } else if (percentage > 0.6) {
      return color;
    } else {
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${current.toInt()}/${goal.toInt()}$unit',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Stack(
          children: [
            // Background
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: AppBorderRadius.sm,
              ),
            ),
            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 16,
              width: MediaQuery.of(context).size.width * percentage * 0.85, // Accounting for padding
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: AppBorderRadius.sm,
              ),
              child: percentage > 0.2 && showPercentage
                  ? Center(
                      child: Text(
                        '${(percentage * 100).toInt()}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }
} 