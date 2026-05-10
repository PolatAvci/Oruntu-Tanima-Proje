import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result_entity.dart';
import '../../domain/usecases/pick_reference_signature.dart';
import '../../domain/usecases/pick_test_signature.dart';
import '../../domain/usecases/save_cropped_signature.dart';
import '../../domain/usecases/verify_signatures.dart';

/// Provider that manages the state for the signature verification flow.
///
/// Holds the selected images, loading state, verification result, and any errors.
/// Communicates with the domain layer via use cases.
class SignatureVerificationProvider extends ChangeNotifier {
  final PickReferenceSignature _pickReferenceSignature;
  final PickTestSignature _pickTestSignature;
  final VerifySignatures _verifySignatures;
  final SaveCroppedSignature _saveCroppedSignature;

  SignatureVerificationProvider({
    required PickReferenceSignature pickReferenceSignature,
    required PickTestSignature pickTestSignature,
    required VerifySignatures verifySignatures,
    required SaveCroppedSignature saveCroppedSignature,
  }) : _pickReferenceSignature = pickReferenceSignature,
       _pickTestSignature = pickTestSignature,
       _verifySignatures = verifySignatures,
       _saveCroppedSignature = saveCroppedSignature;

  // State
  File? _referenceFile;
  File? _testFile;
  bool _isLoading = false;
  VerificationResultEntity? _result;
  String? _errorMessage;

  // Getters
  File? get referenceFile => _referenceFile;
  File? get testFile => _testFile;
  bool get isLoading => _isLoading;
  VerificationResultEntity? get result => _result;
  String? get errorMessage => _errorMessage;

  bool get canVerify => _referenceFile != null && _testFile != null;

  /// Picks the reference (Signature A) image.
  Future<void> pickReferenceSignature({required bool fromCamera}) async {
    _setLoading(true);
    _clearError();

    final result = await _pickReferenceSignature(
      PickSignatureParams(fromCamera: fromCamera),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (file) => _referenceFile = file,
    );

    _setLoading(false);
  }

  /// Picks the test (Signature B) image.
  Future<void> pickTestSignature({required bool fromCamera}) async {
    _setLoading(true);
    _clearError();

    final result = await _pickTestSignature(
      PickSignatureParams(fromCamera: fromCamera),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (file) => _testFile = file,
    );

    _setLoading(false);
  }

  /// Saves cropped bytes as the reference signature file.
  Future<void> saveCroppedReference(Uint8List bytes) async {
    _setLoading(true);
    _clearError();

    final result = await _saveCroppedSignature(
      SaveCroppedSignatureParams(bytes: bytes),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (file) => _referenceFile = file,
    );

    _setLoading(false);
  }

  /// Saves cropped bytes as the test signature file.
  Future<void> saveCroppedTest(Uint8List bytes) async {
    _setLoading(true);
    _clearError();

    final result = await _saveCroppedSignature(
      SaveCroppedSignatureParams(bytes: bytes),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (file) => _testFile = file,
    );

    _setLoading(false);
  }

  /// Verifies the two selected signatures.
  Future<void> verifySignatures() async {
    if (_referenceFile == null || _testFile == null) {
      _setError(AppConstants.missingSignaturesError);
      return;
    }

    _setLoading(true);
    _clearError();
    _clearResult();

    final result = await _verifySignatures(
      VerifySignaturesParams(reference: _referenceFile!, test: _testFile!),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (verificationResult) => _result = verificationResult,
    );

    _setLoading(false);
  }

  /// Clears the current verification result.
  void clearResult() {
    _clearResult();
    notifyListeners();
  }

  /// Clears the error message.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Resets all state for a fresh verification flow.
  void reset() {
    _referenceFile = null;
    _testFile = null;
    _isLoading = false;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Private helpers

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearResult() {
    _result = null;
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
