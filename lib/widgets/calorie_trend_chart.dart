import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<double> calorieData;
  final double calorieGoal;
  final List<String> dateLabels;

  const CalorieTrendChart({
    Key? key,
    required this.calorieData,
    required this.calorieGoal,
    required this.dateLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Calorie Trend',
            style: AppTextStyles.headerSmall,
          ),
        ),
        Container(
          height: 220,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.md,
            boxShadow: [AppShadows.small],
          ),
          child: calorieData.isEmpty
              ? const Center(
                  child: Text(
                    'No data available',
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 500,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index >= 0 && index < dateLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dateLabels[index],
                                  style: AppTextStyles.bodySmall,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 500,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.bodySmall,
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    minX: 0,
                    maxX: calorieData.length.toDouble() - 1,
                    minY: 0,
                    maxY: (calorieData.reduce((a, b) => a > b ? a : b) > calorieGoal
                        ? calorieData.reduce((a, b) => a > b ? a : b) * 1.2
                        : calorieGoal * 1.2),
                    lineBarsData: [
                      // Calorie Goal Line
                      LineChartBarData(
                        spots: List.generate(
                          calorieData.length,
                          (index) => FlSpot(index.toDouble(), calorieGoal),
                        ),
                        isCurved: false,
                        color: AppColors.primary.withOpacity(0.5),
                        barWidth: 1,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Calorie Actual Line
                      LineChartBarData(
                        spots: List.generate(
                          calorieData.length,
                          (index) => FlSpot(index.toDouble(), calorieData[index]),
                        ),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: AppColors.textDark.withOpacity(0.8),
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;
                            if (flSpot.barIndex == 0) {
                              return const LineTooltipItem(
                                'Goal',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return LineTooltipItem(
                                '${flSpot.y.toInt()} cal',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
} 