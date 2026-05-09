import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/signature_verification/presentation/providers/signature_verification_provider.dart';
import 'injection_container.dart';

/// Application entry point.
/// Initializes the service locator and injects the top-level provider.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();

  runApp(
    ChangeNotifierProvider<SignatureVerificationProvider>(
      create: (_) => sl<SignatureVerificationProvider>(),
      child: const SignatureVerificationApp(),
    ),
  );
}
