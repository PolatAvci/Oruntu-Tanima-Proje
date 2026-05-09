import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Reusable widget that displays an image slot for a signature.
/// Shows a dashed-border placeholder when no image is selected,
/// and refined action buttons to capture from camera or gallery.
class SignatureImagePicker extends StatelessWidget {
  final String label;
  final File? imageFile;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const SignatureImagePicker({
    super.key,
    required this.label,
    required this.imageFile,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFile != null;

    return Card(
      elevation: hasImage ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Label
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Image preview or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: hasImage
                    ? _buildImagePreview()
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: onCameraTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: onGalleryTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildImagePreview() {
    return Image.file(
      imageFile!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.95, end: 1.0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _DashedBorderPainter(
            color: AppColors.border,
            strokeWidth: 1.5,
            dashLength: 8,
            dashGap: 6,
            borderRadius: 16,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 40,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to upload',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
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
        final extractLength = (distance + segmentLength).clamp(0.0, metric.length) - distance;
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
