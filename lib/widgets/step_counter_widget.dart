import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StepCounterWidget extends StatelessWidget {
  final int currentSteps;
  final int stepGoal;

  const StepCounterWidget({
    Key? key,
    required this.currentSteps,
    required this.stepGoal,
  }) : super(key: key);

  double get percentage => (currentSteps / stepGoal).clamp(0.0, 1.0);

  String get formattedSteps {
    if (currentSteps >= 1000) {
      return '${(currentSteps / 1000).toStringAsFixed(1)}k';
    }
    return currentSteps.toString();
  }

  String get formattedGoal {
    if (stepGoal >= 1000) {
      return '${(stepGoal / 1000).toStringAsFixed(1)}k';
    }
    return stepGoal.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Step Counter',
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
          child: Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    // Background circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.transparent,
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage >= 1.0 ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ),
                    // Center text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedSteps,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'steps',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Step details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goal: $formattedGoal steps',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(percentage * 100).toInt()}% complete',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 1.0 ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _getStepFeedback(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStepFeedback() {
    if (percentage >= 1.0) {
      return 'Congratulations! You\'ve reached your daily step goal.';
    } else if (percentage >= 0.75) {
      return 'Almost there! Keep moving to reach your goal.';
    } else if (percentage >= 0.5) {
      return 'Halfway there. A short walk would help you progress.';
    } else if (percentage >= 0.25) {
      return 'Good start! Try to be more active today.';
    } else {
      return 'Get moving to reach your daily step goal!';
    }
  }
} 