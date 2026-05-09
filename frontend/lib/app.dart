import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/signature_verification/presentation/pages/signature_capture_page.dart';

/// Root widget of the application.
/// Configures the theme and sets the first screen of the wizard flow.
class SignatureVerificationApp extends StatelessWidget {
  const SignatureVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SignatureCapturePage(),
    );
  }
}
