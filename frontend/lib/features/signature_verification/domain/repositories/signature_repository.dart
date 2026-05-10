import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_result_entity.dart';

/// Contract for signature-related operations.
/// The data layer provides the concrete implementation.
abstract class SignatureRepository {
  /// Picks a reference signature image from the device.
  /// [fromCamera] true uses the camera, false uses the gallery.
  Future<Either<Failure, File>> pickReferenceSignature({required bool fromCamera});

  /// Picks a test signature image from the device.
  /// [fromCamera] true uses the camera, false uses the gallery.
  Future<Either<Failure, File>> pickTestSignature({required bool fromCamera});

  /// Saves cropped image bytes to a temporary file.
  Future<Either<Failure, File>> saveCroppedSignature(Uint8List bytes);

  /// Sends both signatures to the verification service and returns the result.
  Future<Either<Failure, VerificationResultEntity>> verifySignatures(File reference, File test);
}
