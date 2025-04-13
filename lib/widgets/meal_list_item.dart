import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/meal_model.dart';

class MealListItem extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onDelete;

  const MealListItem({
    Key? key,
    required this.meal,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        boxShadow: [AppShadows.small],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Meal icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppBorderRadius.sm,
              ),
              child: Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Meal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${meal.calories} cal • ${meal.protein}g protein • ${meal.carbs}g carbs • ${meal.fat}g fat',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_formatHour(meal.timestamp)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hourFormatted = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$hourFormatted:$minute $period';
  }
} 