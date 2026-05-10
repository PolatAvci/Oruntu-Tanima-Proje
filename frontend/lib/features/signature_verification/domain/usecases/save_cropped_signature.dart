import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/signature_repository.dart';

/// Use case for saving cropped signature bytes to a temporary file.
class SaveCroppedSignature implements UseCase<File, SaveCroppedSignatureParams> {
  final SignatureRepository repository;

  const SaveCroppedSignature(this.repository);

  @override
  Future<Either<Failure, File>> call(SaveCroppedSignatureParams params) async {
    return await repository.saveCroppedSignature(params.bytes);
  }
}

/// Parameters for [SaveCroppedSignature].
class SaveCroppedSignatureParams {
  final Uint8List bytes;

  const SaveCroppedSignatureParams({required this.bytes});
}
