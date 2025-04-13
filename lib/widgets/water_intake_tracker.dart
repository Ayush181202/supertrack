import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class WaterIntakeTracker extends StatelessWidget {
  final double current;
  final double goal;
  final Function() onAddWater;

  const WaterIntakeTracker({
    Key? key,
    required this.current,
    required this.goal,
    required this.onAddWater,
  }) : super(key: key);

  double get percentage => (current / goal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Water Intake',
            style: AppTextStyles.headerSmall,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.md,
            boxShadow: [AppShadows.small],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.toStringAsFixed(1)}L / ${goal.toStringAsFixed(1)}L',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.water,
                        ),
                      ),
                      Text(
                        '${(percentage * 100).toInt()}% of daily goal',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onAddWater,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.water,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: AppBorderRadius.md,
                    child: Stack(
                      children: [
                        // Background container
                        Container(
                          height: 24,
                          width: constraints.maxWidth,
                          color: Colors.grey.shade200,
                        ),
                        // Water progress
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 24,
                          width: constraints.maxWidth * percentage,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF17A2B8),
                                Color(0xFF0DCAF0),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: List.generate(
                              (constraints.maxWidth / 15).floor(),
                              (index) => Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: const Icon(
                                  Icons.opacity,
                                  color: Colors.white30,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _getWaterFeedback(),
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWaterFeedback() {
    if (percentage >= 1.0) {
      return 'Great job! You\'ve met your water intake goal for today.';
    } else if (percentage >= 0.75) {
      return 'Almost there! Keep drinking water to reach your goal.';
    } else if (percentage >= 0.5) {
      return 'Halfway to your goal. Don\'t forget to stay hydrated.';
    } else if (percentage >= 0.25) {
      return 'Remember to drink water regularly throughout the day.';
    } else {
      return 'Start your day right by drinking more water!';
    }
  }
} 