import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/signature_verification_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/signature_crop_dialog.dart';
import '../widgets/signature_image_area.dart';
import '../widgets/wizard_step_indicator.dart';
import 'test_signature_page.dart';

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

  /// Picks an image using the domain layer, then presents the crop dialog.
  Future<void> _pickAndCropImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final provider = context.read<SignatureVerificationProvider>();

    await provider.pickReferenceSignature(fromCamera: fromCamera);

    if (!context.mounted) return;

    final pickedFile = provider.referenceFile;
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!context.mounted) return;

    final croppedBytes = await showSignatureCropDialog(context, imageBytes: bytes);
    if (croppedBytes == null || !context.mounted) return;

    await provider.saveCroppedReference(croppedBytes);
  }

  // --- UI Widget'ları ---
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
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
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
    ).animate().scaleXY(begin: 0.0, end: 1.0, curve: Curves.easeOutBack);
  }

  Widget _buildContent(
    BuildContext context,
    File? referenceFile,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignatureImageArea(
          imageFile: referenceFile,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: isLoading
                    ? null
                    : () => _pickAndCropImage(context, fromCamera: true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: isLoading
                    ? null
                    : () => _pickAndCropImage(context, fromCamera: false),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 28),
        GradientButton(
          label: 'Next Step',
          icon: Icons.arrow_forward,
          isLoading: isLoading,
          onPressed: referenceFile != null && !isLoading
              ? () => _goToNextStep(context)
              : null,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  void _goToNextStep(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TestSignaturePage()));
  }
}

// Yardımcı Buton Widget'ı
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }
}
