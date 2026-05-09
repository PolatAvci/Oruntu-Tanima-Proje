import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/signature_verification_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/signature_image_area.dart';
import '../widgets/wizard_step_indicator.dart';
import 'test_signature_page.dart';

/// STEP 1 — Reference Signature
///
/// The user selects or captures the original (reference) signature image.
/// The "Next Step" button remains disabled until an image is picked.
class SignatureCapturePage extends StatelessWidget {
  const SignatureCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final referenceFile = context.select<SignatureVerificationProvider, File?>(
      (p) => p.referenceFile,
    );
    final isLoading = context.select<SignatureVerificationProvider, bool>(
      (p) => p.isLoading,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildContent(context, referenceFile, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        WizardStepIndicator(currentStep: 0),
        const SizedBox(height: 28),
        _buildGradientIcon(),
        const SizedBox(height: 20),
        Text(
          'Reference Signature',
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
        const SizedBox(height: 8),
        Text(
          'Capture the authentic signature we will compare against.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
              begin: 0.15,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildGradientIcon() {
    return Container(
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
      child: const Icon(
        Icons.document_scanner_rounded,
        color: Colors.white,
        size: 36,
      ),
    )
        .animate()
        .scaleXY(begin: 0.0, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildContent(BuildContext context, File? referenceFile, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignatureImageArea(imageFile: referenceFile)
            .animate()
            .fadeIn(duration: 500.ms, delay: 200.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: isLoading ? null : () => _pickImage(context, fromCamera: true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: isLoading ? null : () => _pickImage(context, fromCamera: false),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 28),
        GradientButton(
          label: 'Next Step',
          icon: Icons.arrow_forward,
          isLoading: isLoading,
          onPressed: referenceFile != null && !isLoading
              ? () => _goToNextStep(context)
              : null,
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  void _pickImage(BuildContext context, {required bool fromCamera}) {
    context.read<SignatureVerificationProvider>().pickReferenceSignature(
      fromCamera: fromCamera,
    );
  }

  void _goToNextStep(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TestSignaturePage()),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }
}
