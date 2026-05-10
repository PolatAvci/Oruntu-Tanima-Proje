import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/verification_result_model.dart';

/// Contract for remote verification operations.
abstract class SignatureRemoteDataSource {
  /// Sends two signature images to the verification backend.
  Future<VerificationResultModel> verifySignatures(File reference, File test);
}

/// Concrete implementation that calls the FastAPI verification backend.
class SignatureRemoteDataSourceImpl implements SignatureRemoteDataSource {
  @override
  Future<VerificationResultModel> verifySignatures(File reference, File test) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/v1/verify-signature/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('reference_img', reference.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('query_img', test.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Verification failed with status ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(message: 'Invalid response: missing data field');
      }

      final bool isGenuine = data['is_genuine'] as bool;
      final double distance = (data['distance'] as num).toDouble();

      final double confidencePercentage =
          ((1.0 - distance.clamp(0.0, 1.0)) * 100.0);

      return VerificationResultModel(
        isGenuine: isGenuine,
        confidencePercentage: double.parse(
          confidencePercentage.toStringAsFixed(2),
        ),
      );
    } catch (e) {
      throw ServerException(message: 'Verification service error: ${e.toString()}');
    }
  }
}
