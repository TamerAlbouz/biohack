import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/doctor/stats/bloc/statistics_bloc.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';

import '../models/statistics_models.dart';

/// Monthly Revenue Trend Line Chart for Overview Tab
class MonthlyRevenueChart extends StatelessWidget {
  final StatisticsLoaded stats;

  const MonthlyRevenueChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    // Create example monthly data based on current revenue
    final monthlyData = _generateMonthlyData();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: stats.revenue / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
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
                        if (value.toInt() >= 0 &&
                            value.toInt() < monthlyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthlyData[value.toInt()].month,
                              style: const TextStyle(
                                fontSize: Font.extraSmall,
                                color: Colors.grey,
                              ),
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
                      interval: stats.revenue / 5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currencyFormat.format(value),
                          style: const TextStyle(
                            fontSize: Font.extraSmall,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: monthlyData.length - 1.0,
                minY: 0,
                maxY: stats.revenue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(monthlyData.length, (index) {
                      return FlSpot(
                          index.toDouble(), monthlyData[index].revenue);
                    }),
                    isCurved: true,
                    color: MyColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: MyColors.primary,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: MyColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '${monthlyData[touchedSpot.x.toInt()].month}: ${currencyFormat.format(touchedSpot.y)}',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ${currencyFormat.format(stats.revenue)}',
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  stats.revenueChange >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: stats.revenueChange >= 0 ? Colors.green : Colors.red,
                  size: 14,
                ),
                Text(
                  '${stats.revenueChange.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: stats.revenueChange >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' vs prev. period',
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<MonthlyRevenue> _generateMonthlyData() {
    // Create example monthly data based on current revenue and trend
    final now = DateTime.now();
    final months = <String>[];

    // Get last 6 months including current
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMM').format(month));
    }

    // Create revenue data with a trend
    final revenueMultipliers = [0.8, 0.85, 0.9, 0.85, 0.95, 1.0];

    return List.generate(6, (index) {
      return MonthlyRevenue(
        month: months[index],
        revenue: stats.revenue * revenueMultipliers[index],
      );
    });
  }
}

/// Revenue by Service Type Pie Chart for Overview Tab
class ServiceRevenueChart extends StatelessWidget {
  final StatisticsLoaded stats;

  const ServiceRevenueChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Get top services (up to 4)
    final topServices = stats.topServices.take(4).toList();

    // Define colors
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(topServices.length, (index) {
                    final service = topServices[index];

                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: service.revenue.toDouble(),
                      title: '',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                  borderData: FlBorderData(show: false),
                ),
              ),
              Center(
                child: Text(
                  currencyFormat.format(stats.revenue),
                  style: const TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(topServices.length, (index) {
            final service = topServices[index];
            final color = colors[index % colors.length];
            final percentage = (service.revenue / stats.revenue) * 100;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${service.name}: ${currencyFormat.format(service.revenue)} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: Font.extraSmall,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// Revenue by Appointment Type Bar Chart for Appointments Tab
class AppointmentTypeRevenueChart extends StatelessWidget {
  final StatisticsLoaded stats;

  const AppointmentTypeRevenueChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Example appointment types with revenue distribution
    final appointmentTypes = [
      TypeRevenue(
          type: 'Follow-up', revenue: stats.revenue * 0.45, color: Colors.blue),
      TypeRevenue(
          type: 'New Patient',
          revenue: stats.revenue * 0.25,
          color: Colors.green),
      TypeRevenue(
          type: 'Consultation',
          revenue: stats.revenue * 0.20,
          color: Colors.orange),
      TypeRevenue(
          type: 'Procedure',
          revenue: stats.revenue * 0.10,
          color: Colors.purple),
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: stats.revenue * 0.5,
                // Maximum value is the highest revenue
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${appointmentTypes[groupIndex].type}\n${currencyFormat.format(appointmentTypes[groupIndex].revenue)}',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < appointmentTypes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              appointmentTypes[value.toInt()]
                                  .type
                                  .split(' ')[0],
                              style: const TextStyle(
                                fontSize: Font.extraSmall,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currencyFormat.format(value),
                          style: const TextStyle(
                            fontSize: Font.extraSmall,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: stats.revenue * 0.1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(appointmentTypes.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: appointmentTypes[index].revenue,
                        color: appointmentTypes[index].color,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: appointmentTypes.map((type) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: type.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${type.type}: ${currencyFormat.format(type.revenue)}',
                  style: const TextStyle(
                    fontSize: Font.extraSmall,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Revenue by Day of Week Bar Chart for Appointments Tab
class RevenueDayChart extends StatelessWidget {
  final StatisticsLoaded stats;

  const RevenueDayChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    // Calculate revenue per day based on busiest days
    final days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final revenueByDay = _calculateRevenueByDay();

    // Find the highest revenue day
    final highestRevenue = revenueByDay.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: highestRevenue * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = days[groupIndex];
                      return BarTooltipItem(
                        '$day: ${currencyFormat.format(revenueByDay[day])}',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                fontSize: Font.extraSmall,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currencyFormat.format(value),
                          style: const TextStyle(
                            fontSize: Font.extraSmall,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: highestRevenue / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(days.length, (index) {
                  final day = days[index];
                  final revenue = revenueByDay[day] ?? 0.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: _getBarColor(day, revenueByDay),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final revenue = revenueByDay[day] ?? 0;
            final isHighest = revenue == highestRevenue;

            return Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  currencyFormat.format(revenue),
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    color: isHighest ? Colors.green : MyColors.subtitleDark,
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Map<String, double> _calculateRevenueByDay() {
    // Calculate mock revenue per day based on busiest days
    final revenueByDay = <String, double>{};
    final shortDayNames = {
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat',
      'Sunday': 'Sun',
    };

    for (final day in stats.busiestDays) {
      final shortName = shortDayNames[day.day] ?? day.day.substring(0, 3);
      revenueByDay[shortName] = (day.percentage / 100) * stats.revenue;
    }

    // Fill in any missing days with minimal revenue
    for (final day in shortDayNames.values) {
      revenueByDay.putIfAbsent(day, () => stats.revenue * 0.05);
    }

    return revenueByDay;
  }

  Color _getBarColor(String day, Map<String, double> revenueByDay) {
    final revenue = revenueByDay[day] ?? 0.0;
    final maxRevenue = revenueByDay.values.reduce((a, b) => a > b ? a : b);

    if (revenue == maxRevenue) {
      return Colors.green;
    } else if (revenue >= maxRevenue * 0.8) {
      return Colors.blue;
    } else if (revenue >= maxRevenue * 0.5) {
      return MyColors.primary;
    } else {
      return Colors.grey;
    }
  }
}
