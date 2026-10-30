import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PollProgressBar extends StatelessWidget {
  final double percentage;
  final Color? color;
  final Gradient? gradient;
  final double height;
  final bool animate;

  const PollProgressBar({
    super.key,
    required this.percentage,
    this.color,
    this.gradient,
    this.height = 8,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = (percentage / 100).clamp(0.0, 1.0);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveWidth = constraints.maxWidth * clampedPercent;

          return Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: animate ? 650 : 0),
                curve: Curves.easeOutCubic,
                width: effectiveWidth,
                decoration: BoxDecoration(
                  gradient: gradient ??
                      (color == null
                          ? const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                            )
                          : null),
                  color: gradient == null ? (color ?? AppColors.primary) : null,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    if (clampedPercent > 0.05)
                      BoxShadow(
                        color: (color ?? AppColors.primary).withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
