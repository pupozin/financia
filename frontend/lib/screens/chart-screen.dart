import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/widget/header.dart';

class ChartScreen extends StatefulWidget {
  final void Function()? onAvatarTap;
  final VoidCallback? onToggleMenu;
  final String userName;

  const ChartScreen({
    super.key,
    this.onAvatarTap,
    this.onToggleMenu,
    required this.userName,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool isIncomeSelected = true;
  String selectedTimeFilter = "Month";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SharedDashboardHeader(
              userName: widget.userName,
              onAvatarTap: widget.onAvatarTap,
              onToggleMenu: widget.onToggleMenu,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 37, 36, 36),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      'Graphic',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Filtros Income/Expense
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _filterButton("Income", isIncomeSelected, () {
                        setState(() => isIncomeSelected = true);
                      }, Colors.blue),
                      const SizedBox(width: 12),
                      _filterButton("Expense", !isIncomeSelected, () {
                        setState(() => isIncomeSelected = false);
                      }, Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Filtros por tempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["Day", "Week", "Month", "Year"].map((label) {
                      final isSelected = label == selectedTimeFilter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTimeFilter = label;
                          });
                        },
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 0),

                  // Gráfico
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            _lineBar(
                              isIncomeSelected ? [1, 2, 5, 8, 4, 4] : [3, 3, 2, 4, 6, 7],
                              color: isIncomeSelected ? Colors.blue : Colors.orange,
                            ),
                          ],
                          minY: 0,
                          maxY: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(List<double> values, {required Color color}) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: true),
    );
  }

  Widget _filterButton(String label, bool selected, VoidCallback onTap, Color activeColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}