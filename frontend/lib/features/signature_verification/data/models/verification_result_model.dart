import '../../domain/entities/verification_result_entity.dart';

/// Data layer model for the verification result.
/// Mirrors the structure of the API response.
class VerificationResultModel extends VerificationResultEntity {
  const VerificationResultModel({
    required super.isGenuine,
    required super.confidencePercentage,
  });

  /// Creates a model from a JSON map (useful if a real API is introduced later).
  factory VerificationResultModel.fromJson(Map<String, dynamic> json) {
    return VerificationResultModel(
      isGenuine: json['isGenuine'] as bool,
      confidencePercentage: (json['confidencePercentage'] as num).toDouble(),
    );
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'isGenuine': isGenuine,
      'confidencePercentage': confidencePercentage,
    };
  }
}
