import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final double food;
  final double travel;
  final double shopping;
  final double bills;
  final double medical;
  final double entertainment;
  final double education;
  final double others;

  const ChartWidget({
    super.key,
    required this.food,
    required this.travel,
    required this.shopping,
    required this.bills,
    required this.medical,
    required this.entertainment,
    required this.education,
    required this.others,
  });

  @override
  Widget build(BuildContext context) {
    final total = food +
        travel +
        shopping +
        bills +
        medical +
        entertainment +
        education +
        others;

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No expense data available"),
        ),
      );
    }

    List<PieChartSectionData> sections = [];

    void addSection(String title, double value, Color color) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            value: value,
            title: "${((value / total) * 100).toStringAsFixed(0)}%",
            radius: 70,
            color: color,
          ),
        );
      }
    }

    addSection("Food", food, Colors.red);
    addSection("Travel", travel, Colors.blue);
    addSection("Shopping", shopping, Colors.orange);
    addSection("Bills", bills, Colors.purple);
    addSection("Medical", medical, Colors.green);
    addSection("Entertainment", entertainment, Colors.teal);
    addSection("Education", education, Colors.indigo);
    addSection("Others", others, Colors.grey);

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 45,
        ),
      ),
    );
  }
}
