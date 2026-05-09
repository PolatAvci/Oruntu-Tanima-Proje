/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appTitle = 'Signature Verification';

  // UI Strings
  static const String signatureA = 'Signature A';
  static const String signatureB = 'Signature B';
  static const String verifyButtonLabel = 'Verify Signatures';
  static const String takePhotoLabel = 'Take Photo';
  static const String pickFromGalleryLabel = 'Pick from Gallery';
  static const String resultGenuine = 'Genuine';
  static const String resultForged = 'Forged';

  // Durations
  static const int apiSimulationDelaySeconds = 2;

  // Validation Messages
  static const String missingSignaturesError = 'Please select both signatures before verifying.';
}
