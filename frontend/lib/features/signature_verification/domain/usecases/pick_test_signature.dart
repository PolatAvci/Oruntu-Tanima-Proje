import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/signature_repository.dart';
import 'pick_reference_signature.dart';

/// Use case for picking the test (to-be-verified) signature image.
class PickTestSignature implements UseCase<File, PickSignatureParams> {
  final SignatureRepository repository;

  const PickTestSignature(this.repository);

  @override
  Future<Either<Failure, File>> call(PickSignatureParams params) async {
    return await repository.pickTestSignature(fromCamera: params.fromCamera);
  }
}
