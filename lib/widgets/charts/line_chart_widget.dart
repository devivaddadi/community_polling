import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/custom_painters.dart';

class LineChartWidget extends StatefulWidget {
  final List<double> dataPoints;
  final List<String> xLabels;
  final double height;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    required this.dataPoints,
    required this.xLabels,
    this.height = 180,
    this.lineColor = AppColors.primary,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: LineChartPainter(
              dataPoints: widget.dataPoints,
              xLabels: widget.xLabels,
              lineColor: widget.lineColor,
              animationProgress: _animation.value,
            ),
          );
        },
      ),
    );
  }
}
