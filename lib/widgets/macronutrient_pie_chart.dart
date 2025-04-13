import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';

class MacronutrientPieChart extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;

  const MacronutrientPieChart({
    Key? key,
    required this.protein,
    required this.carbs,
    required this.fat,
  }) : super(key: key);

  double get totalCalories {
    // 4 calories per gram of protein and carbs, 9 calories per gram of fat
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  double get proteinPercentage => protein * 4 / totalCalories;
  double get carbsPercentage => carbs * 4 / totalCalories;
  double get fatPercentage => fat * 9 / totalCalories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Macronutrient Breakdown',
            style: AppTextStyles.headerSmall,
          ),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.md,
            boxShadow: [AppShadows.small],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.protein,
                        value: protein * 4,
                        title: '${(proteinPercentage * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppColors.carbs,
                        value: carbs * 4,
                        title: '${(carbsPercentage * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppColors.fat,
                        value: fat * 9,
                        title: '${(fatPercentage * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Protein', AppColors.protein, '${protein}g'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildLegendItem('Carbs', AppColors.carbs, '${carbs}g'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildLegendItem('Fat', AppColors.fat, '${fat}g'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 