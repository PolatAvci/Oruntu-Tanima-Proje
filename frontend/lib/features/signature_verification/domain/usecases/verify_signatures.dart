import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification_result_entity.dart';
import '../repositories/signature_repository.dart';

/// Use case that orchestrates the verification of two signature images.
class VerifySignatures implements UseCase<VerificationResultEntity, VerifySignaturesParams> {
  final SignatureRepository repository;

  const VerifySignatures(this.repository);

  @override
  Future<Either<Failure, VerificationResultEntity>> call(VerifySignaturesParams params) async {
    return await repository.verifySignatures(params.reference, params.test);
  }
}

/// Parameters required to verify two signatures.
class VerifySignaturesParams {
  final File reference;
  final File test;

  const VerifySignaturesParams({
    required this.reference,
    required this.test,
  });
}
