import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/signature_repository.dart';

/// Use case for picking the reference (original) signature image.
class PickReferenceSignature implements UseCase<File, PickSignatureParams> {
  final SignatureRepository repository;

  const PickReferenceSignature(this.repository);

  @override
  Future<Either<Failure, File>> call(PickSignatureParams params) async {
    return await repository.pickReferenceSignature(fromCamera: params.fromCamera);
  }
}

/// Parameters shared across signature image picking use cases.
class PickSignatureParams {
  final bool fromCamera;

  const PickSignatureParams({required this.fromCamera});
}
