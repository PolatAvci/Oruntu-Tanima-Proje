import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
/// Failures represent expected error states that the UI should handle gracefully.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Failure returned when a server or remote API call fails.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred. Please try again.'});
}

/// Failure returned when a local cache operation fails.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred.'});
}

/// Failure returned when the user denies a required permission (camera/storage).
class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied. Please enable it in settings.'});
}

/// Failure returned when an image could not be picked or processed.
class ImagePickFailure extends Failure {
  const ImagePickFailure({super.message = 'Failed to pick image. Please try again.'});
}

/// Failure returned when validation fails (e.g., missing signatures before verification).
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed. Please provide all required inputs.'});
}
