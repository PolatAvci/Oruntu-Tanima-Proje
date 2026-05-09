import 'package:equatable/equatable.dart';

/// Domain entity representing the result of a signature verification.
class VerificationResultEntity extends Equatable {
  /// Whether the signature is genuine or forged.
  final bool isGenuine;

  /// Confidence percentage (0.0 to 100.0).
  final double confidencePercentage;

  const VerificationResultEntity({
    required this.isGenuine,
    required this.confidencePercentage,
  });

  @override
  List<Object?> get props => [isGenuine, confidencePercentage];
}
