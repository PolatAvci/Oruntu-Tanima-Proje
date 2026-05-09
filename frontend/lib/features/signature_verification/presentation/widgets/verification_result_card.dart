import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/verification_result_entity.dart';

/// Displays the verification result in a stunning animated card
/// with a semi-circular gauge, gradient background, and icon effects.
class VerificationResultCard extends StatelessWidget {
  final VerificationResultEntity result;

  const VerificationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isGenuine = result.isGenuine;
    final Color themeColor = isGenuine ? AppColors.success : AppColors.error;
    final LinearGradient bgGradient =
        isGenuine ? AppColors.successGradient : AppColors.errorGradient;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with pulse/shake animation
          _buildAnimatedIcon(isGenuine, themeColor),
          const SizedBox(height: 14),

          // Label
          Text(
            isGenuine ? 'GENUINE' : 'FORGED',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Gauge + percentage
          _buildGauge(context, result.confidencePercentage, Colors.white),
          const SizedBox(height: 8),

          Text(
            'Confidence ${result.confidencePercentage.toStringAsFixed(1)}%',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scaleXY(
          begin: 0.92,
          end: 1.0,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAnimatedIcon(bool isGenuine, Color color) {
    final icon = isGenuine ? Icons.verified_rounded : Icons.warning_amber_rounded;

    Widget child = Icon(icon, size: 56, color: Colors.white);

    if (isGenuine) {
      // Single dramatic pulse on entry (plays once, ~0.8s total)
      child = child
          .animate()
          .scaleXY(begin: 0.5, end: 1.2, duration: 450.ms, curve: Curves.easeOutBack)
          .then()
          .scaleXY(begin: 1.2, end: 1.0, duration: 350.ms, curve: Curves.easeOutCubic);
    } else {
      // Single shake on entry (plays once, ~0.6s)
      child = child
          .animate()
          .shakeX(duration: 600.ms, amount: 4);
    }

    return child;
  }

  Widget _buildGauge(BuildContext context, double percentage, Color foreground) {
    final double clamped = percentage.clamp(0.0, 100.0) / 100.0;

    return SizedBox(
      width: 140,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(140, 80),
            painter: _SemiCircleGaugePainter(
              progress: clamped,
              trackColor: Colors.white.withValues(alpha: 0.25),
              progressColor: foreground,
              strokeWidth: 10,
            ),
          ),
          Positioned(
            bottom: 6,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 28,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _SemiCircleGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, size.height - size.width / 2, size.width, size.width);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
