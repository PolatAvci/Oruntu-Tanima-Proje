import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable animation presets for consistent page entrance effects.
class AnimationPresets {
  AnimationPresets._();

  /// Standard fade + slide-up used for most cards and sections.
  static List<Effect<dynamic>> fadeSlideUp({double delayMs = 0}) {
    return [
      FadeEffect(duration: 400.ms, delay: delayMs.ms),
      SlideEffect(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
        duration: 500.ms,
        delay: delayMs.ms,
        curve: Curves.easeOutCubic,
      ),
    ];
  }

  /// Scale + fade for result cards and impactful reveals.
  static List<Effect<dynamic>> scaleFade({double delayMs = 0}) {
    return [
      ScaleEffect(
        begin: const Offset(0.92, 0.92),
        end: const Offset(1.0, 1.0),
        duration: 500.ms,
        delay: delayMs.ms,
        curve: Curves.easeOutBack,
      ),
      FadeEffect(duration: 400.ms, delay: delayMs.ms),
    ];
  }

  /// Staggered children preset for lists or column contents.
  static List<Effect<dynamic>> staggered({double baseDelayMs = 100}) {
    return [
      FadeEffect(duration: 400.ms),
      SlideEffect(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      ),
    ];
  }
}
