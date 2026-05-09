import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/verification_result_entity.dart';
import '../providers/signature_verification_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/gradient_button.dart';
import '../widgets/signature_image_picker.dart';
import '../widgets/verification_result_card.dart';

/// Main screen for the Signature Verification application.
/// Features a gradient header, scrollable content, staggered animations,
/// and Selector-based performance isolation via context.select.
class SignatureVerificationPage extends StatelessWidget {
  const SignatureVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final referenceFile = context.select<SignatureVerificationProvider, File?>(
      (p) => p.referenceFile,
    );
    final testFile = context.select<SignatureVerificationProvider, File?>(
      (p) => p.testFile,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Signature A
                SignatureImagePicker(
                  label: AppConstants.signatureA,
                  imageFile: referenceFile,
                  onCameraTap: () => _pickReference(context, fromCamera: true),
                  onGalleryTap: () => _pickReference(context, fromCamera: false),
                ),
                const SizedBox(height: 16),

                // Signature B
                SignatureImagePicker(
                  label: AppConstants.signatureB,
                  imageFile: testFile,
                  onCameraTap: () => _pickTest(context, fromCamera: true),
                  onGalleryTap: () => _pickTest(context, fromCamera: false),
                ),
                const SizedBox(height: 24),

                // Verify Button
                _buildVerifyButton(context),
                const SizedBox(height: 20),

                // Result / Error Section
                _buildResultSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 32,
          ),
        )
            .animate()
            .scaleXY(begin: 0.0, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 14),
        Text(
          AppConstants.appTitle,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.onBackground,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 6),
        Text(
          'Select two signatures to compare authenticity',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
              begin: 0.15,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    final isLoading = context.select<SignatureVerificationProvider, bool>(
      (p) => p.isLoading,
    );
    final canVerify = context.select<SignatureVerificationProvider, bool>(
      (p) => p.canVerify,
    );

    return GradientButton(
      label: isLoading ? 'Analyzing...' : AppConstants.verifyButtonLabel,
      icon: isLoading ? null : Icons.fingerprint,
      isLoading: isLoading,
      onPressed: canVerify
          ? () => context.read<SignatureVerificationProvider>().verifySignatures()
          : null,
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final error = context.select<SignatureVerificationProvider, String?>(
      (p) => p.errorMessage,
    );
    final result = context.select<SignatureVerificationProvider, VerificationResultEntity?>(
      (p) => p.result,
    );

    if (error != null) {
      return ErrorBanner(
        message: error,
        onDismiss: () => context.read<SignatureVerificationProvider>().clearError(),
      );
    }

    if (result != null) {
      return VerificationResultCard(result: result);
    }

    return const SizedBox(height: 60);
  }

  void _pickReference(BuildContext context, {required bool fromCamera}) {
    context.read<SignatureVerificationProvider>().pickReferenceSignature(
      fromCamera: fromCamera,
    );
  }

  void _pickTest(BuildContext context, {required bool fromCamera}) {
    context.read<SignatureVerificationProvider>().pickTestSignature(
      fromCamera: fromCamera,
    );
  }
}
