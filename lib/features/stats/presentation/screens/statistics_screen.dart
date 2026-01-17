// [1] VERSION: 1.0.0 - Analytics Screen
// UI segment: Charts & Graphs
// BACKEND segment: Uses local calculations on Task List

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskListProvider);
    final categoryState = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: taskState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (tasks) {
          if (tasks.isEmpty) return const Center(child: Text("No data yet. Go do some tasks!"));

          // --- 1. Calculate Summary Stats ---
          final total = tasks.length;
          final completed = tasks.where((t) => t.isCompleted).length;
          final pending = total - completed;
          final completionRate = total == 0 ? 0 : (completed / total * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Completion Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF556270)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Productivity Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text("$completionRate%", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          value: completed / (total == 0 ? 1 : total),
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                          strokeWidth: 8,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Bar Chart (Completed vs Pending)
                const Text("Task Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: total.toDouble() + 1, // Dynamic Max Y
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold));
                              if (value == 1) return const Text('Done', style: TextStyle(fontWeight: FontWeight.bold));
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: pending.toDouble(), color: Colors.orangeAccent, width: 30, borderRadius: BorderRadius.circular(6))
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(toY: completed.toDouble(), color: const Color(0xFF4ECDC4), width: 30, borderRadius: BorderRadius.circular(6))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Category Breakdown (Pie Chart)
                const Text("Category Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 250, // Height for Pie Chart
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: categoryState.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (categories) {
                      // Calculate count per category
                      final Map<int, int> categoryCounts = {};
                      for (var t in tasks) {
                        if (t.categoryId != null) {
                          categoryCounts[t.categoryId!] = (categoryCounts[t.categoryId!] ?? 0) + 1;
                        }
                      }

                      if (categoryCounts.isEmpty) return const Center(child: Text("No categorized tasks"));

                      return PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: categoryCounts.entries.map((entry) {
                            final cat = categories.firstWhere((c) => c.id == entry.key, orElse: () => categories.first);
                            final count = entry.value;
                            final color = Color(int.parse('0xFF${cat.colorHex.replaceAll('#', '')}'));

                            return PieChartSectionData(
                              color: color,
                              value: count.toDouble(),
                              title: '$count',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}