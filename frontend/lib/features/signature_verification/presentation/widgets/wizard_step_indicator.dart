import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Elegant step indicator for the wizard flow.
/// Shows numbered steps with connecting lines and active/completed states.
class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const WizardStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return _buildConnector(isCompleted);
        } else {
          // Step circle
          final stepIndex = index ~/ 2;
          return _buildStep(stepIndex);
        }
      }),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: -0.2,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStep(int stepIndex) {
    final bool isActive = stepIndex == currentStep;
    final bool isCompleted = stepIndex < currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: isActive ? 40 : 32,
      height: isActive ? 40 : 32,
      decoration: BoxDecoration(
        gradient: isActive || isCompleted ? AppColors.primaryGradient : null,
        color: isActive || isCompleted ? null : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive || isCompleted
              ? Colors.transparent
              : AppColors.border,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '${stepIndex + 1}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: isCompleted ? AppColors.primaryGradient : null,
        color: isCompleted ? null : AppColors.borderLight,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
