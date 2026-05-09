import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/verification_result_entity.dart';
import '../providers/signature_verification_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/gradient_button.dart';
import '../widgets/verification_result_card.dart';
import '../widgets/wizard_step_indicator.dart';
import 'signature_capture_page.dart';

/// STEP 3 — Verification Result
///
/// Displays the outcome of the signature comparison:
///   • Loading state with a spinner
///   • Success state with a dynamic result card
///   • Error state with a banner
///
/// A "Start Over" button resets the flow and returns to Step 1.
class SignatureVerificationResultPage extends StatelessWidget {
  const SignatureVerificationResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SignatureVerificationProvider, bool>(
      (p) => p.isLoading,
    );
    final result = context.select<SignatureVerificationProvider, VerificationResultEntity?>(
      (p) => p.result,
    );
    final error = context.select<SignatureVerificationProvider, String?>(
      (p) => p.errorMessage,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _buildBody(context, isLoading, result, error),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isLoading,
    VerificationResultEntity? result,
    String? error,
  ) {
    if (isLoading && result == null && error == null) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildResultLayout(
        context,
        header: _buildHeader('Verification Failed', Icons.error_outline),
        child: ErrorBanner(
          message: error,
          onDismiss: () => context.read<SignatureVerificationProvider>().clearError(),
        ),
      );
    }

    if (result != null) {
      return _buildResultLayout(
        context,
        header: _buildHeader('Result', Icons.verified_user_rounded),
        child: VerificationResultCard(result: result),
      );
    }

    return _buildLoadingState();
  }

  Widget _buildResultLayout(
    BuildContext context, {
    required Widget header,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const Spacer(),
        child.animate().scaleXY(
              begin: 0.92,
              end: 1.0,
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
        const Spacer(),
        const SizedBox(height: 32),
        GradientButton(
          label: 'Start New Verification',
          icon: Icons.restart_alt,
          onPressed: () => _startOver(context),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Column(
      children: [
        WizardStepIndicator(currentStep: 2),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        )
            .animate()
            .scaleXY(begin: 0.0, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        Text(
          title,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.onBackground,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        WizardStepIndicator(currentStep: 2),
        const Spacer(),
        SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        Text(
          'Analyzing signatures...',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onBackground,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 12),
        Text(
          'Comparing reference against test signature',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        const Spacer(),
      ],
    );
  }

  void _startOver(BuildContext context) {
    context.read<SignatureVerificationProvider>().reset();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignatureCapturePage()),
      (route) => false,
    );
  }
}
