import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatefulWidget {
  final String title;
  final int percent;
  final String label; // Secure / Covered / Protected

  const DonutChart({
    super.key,
    required this.title,
    required this.percent,
    required this.label,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.percent.clamp(0, 100).toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        double chartSize;
        if (width > 320) {
          chartSize = 190;
        } else if (width > 260) {
          chartSize = 165;
        } else {
          chartSize = 145;
        }

        return SizedBox(
          width: chartSize + 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555B65),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: chartSize,
                width: chartSize,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final double value = _animation.value;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Subtle Shadow Ring
                        Container(
                          height: chartSize,
                          width: chartSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        /// Donut Chart
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 0,
                            centerSpaceRadius: chartSize * 0.34,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF43A047), // Green
                                value: value,
                                showTitle: false,
                                radius: chartSize * 0.22,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFE53935), // Red
                                value: 100 - value,
                                showTitle: false,
                                radius: chartSize * 0.22,
                              ),
                            ],
                          ),
                        ),

                        /// Animated Center Text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${value.toInt()}%",
                              style: TextStyle(
                                fontSize: chartSize * 0.16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: chartSize * 0.08,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



