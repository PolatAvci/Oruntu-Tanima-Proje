import 'dart:io';
import 'dart:math';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/verification_result_model.dart';

/// Contract for remote verification operations.
abstract class SignatureRemoteDataSource {
  /// Sends two signature images to the verification backend.
  Future<VerificationResultModel> verifySignatures(File reference, File test);
}

/// Simulates a remote API call for signature verification.
class SignatureRemoteDataSourceImpl implements SignatureRemoteDataSource {
  final Random _random;

  SignatureRemoteDataSourceImpl({Random? random}) : _random = random ?? Random();

  @override
  Future<VerificationResultModel> verifySignatures(File reference, File test) async {
    try {
      // Simulate network latency.
      await Future.delayed(
        const Duration(seconds: AppConstants.apiSimulationDelaySeconds),
      );

      // Simulate a random API response.
      final bool isGenuine = _random.nextBool();
      final double confidence = 85.0 + _random.nextDouble() * 14.0;

      return VerificationResultModel(
        isGenuine: isGenuine,
        confidencePercentage: double.parse(confidence.toStringAsFixed(2)),
      );
    } catch (e) {
      throw ServerException(message: 'Verification service error: ${e.toString()}');
    }
  }
}
