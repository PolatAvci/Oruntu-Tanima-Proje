import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result_entity.dart';
import '../../domain/repositories/signature_repository.dart';
import '../datasources/signature_local_datasource.dart';
import '../datasources/signature_remote_datasource.dart';

/// Concrete implementation of [SignatureRepository].
/// Bridges data sources with the domain layer, mapping exceptions to failures.
class SignatureRepositoryImpl implements SignatureRepository {
  final SignatureLocalDataSource localDataSource;
  final SignatureRemoteDataSource remoteDataSource;

  SignatureRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, File>> pickReferenceSignature({required bool fromCamera}) async {
    return await _pickImage(fromCamera: fromCamera);
  }

  @override
  Future<Either<Failure, File>> pickTestSignature({required bool fromCamera}) async {
    return await _pickImage(fromCamera: fromCamera);
  }

  /// Shared image picking logic with exception-to-failure mapping.
  Future<Either<Failure, File>> _pickImage({required bool fromCamera}) async {
    try {
      final file = await localDataSource.pickImage(fromCamera: fromCamera);
      return Right(file);
    } on ImagePickException catch (e) {
      return Left(ImagePickFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } catch (e) {
      return Left(ImagePickFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationResultEntity>> verifySignatures(
    File reference,
    File test,
  ) async {
    try {
      final result = await remoteDataSource.verifySignatures(reference, test);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
