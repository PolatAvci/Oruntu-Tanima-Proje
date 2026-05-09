import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shared image area widget that displays either a dashed-border placeholder
/// or an animated image preview with a "Selected" badge.
class SignatureImageArea extends StatelessWidget {
  final File? imageFile;
  final double height;

  const SignatureImageArea({
    super.key,
    required this.imageFile,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFile != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: hasImage
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2)
              : null,
          boxShadow: hasImage
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: hasImage ? _buildImagePreview(imageFile!) : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildImagePreview(File file) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(file, fit: BoxFit.contain)
            .animate()
            .fadeIn(duration: 500.ms)
            .scaleXY(begin: 0.92, end: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Selected',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _DashedBorderPainter(
            color: AppColors.border,
            strokeWidth: 2,
            dashLength: 10,
            dashGap: 8,
            borderRadius: 24,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No image selected',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Camera or Gallery below',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().toList();
    double distance = 0;
    bool draw = true;

    for (final metric in metrics) {
      while (distance < metric.length) {
        final segmentLength = draw ? dashLength : dashGap;
        final extractLength =
            (distance + segmentLength).clamp(0.0, metric.length) - distance;
        if (extractLength > 0 && draw) {
          final extract = metric.extractPath(distance, distance + extractLength);
          canvas.drawPath(extract, paint);
        }
        distance += segmentLength;
        draw = !draw;
      }
      distance = 0;
      draw = true;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
