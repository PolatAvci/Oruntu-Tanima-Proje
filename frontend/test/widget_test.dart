import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';
import 'package:frontend/features/signature_verification/presentation/providers/signature_verification_provider.dart';
import 'package:frontend/injection_container.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() {
    initDependencies();
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('App renders wizard Step 1', (WidgetTester tester) async {
    // Set a realistic device size to avoid layout overflows in the test.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Build our app wrapped with the provider, mirroring main.dart.
    await tester.pumpWidget(
      ChangeNotifierProvider<SignatureVerificationProvider>(
        create: (_) => sl<SignatureVerificationProvider>(),
        child: const SignatureVerificationApp(),
      ),
    );

    // Allow entrance animations (flutter_animate) to complete.
    await tester.pumpAndSettle();

    // Verify that the Step 1 headline is displayed.
    expect(find.text('Reference Signature'), findsOneWidget);

    // Verify that Camera and Gallery buttons are present.
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    // Verify that the Next Step button is present (disabled initially).
    expect(find.text('Next Step'), findsOneWidget);
  });
}
