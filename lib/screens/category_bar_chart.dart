import 'package:expense_tracker/providers/categries_colors_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryBarChart extends ConsumerStatefulWidget {
  final Map<String, double> data;

  const CategoryBarChart({super.key, required this.data});

  @override
  ConsumerState<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends ConsumerState<CategoryBarChart> {
  @override
  Widget build(BuildContext context) {
    final categoryServices = ref.watch(categoryServiceProvider);
    final barCount = widget.data.length;
    const minSpacing = 40.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final requiredWidth = barCount * minSpacing;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: requiredWidth > screenWidth ? requiredWidth : screenWidth,
        child: BarChart(
          BarChartData(
            barGroups:
                widget.data.entries.map((entry) {
                  final category = entry.key;
                  final amount = entry.value;
                  final color = categoryServices.getCategoryColor(category);

                  return BarChartGroupData(
                    x: widget.data.keys.toList().indexOf(category),
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: color,
                        width: 10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    String category = widget.data.keys.elementAt(value.toInt());
                    return Icon(
                      categoryServices.getCategoryIcon(category),
                      size: 14,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
