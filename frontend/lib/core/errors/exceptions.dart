/// Base exception class for data layer errors.
class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when a server API call fails.
class ServerException extends AppException {
  const ServerException({super.message = 'Server error occurred.'});
}

/// Thrown when a local data operation fails.
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred.'});
}

/// Thrown when a permission is denied by the user or system.
class PermissionException extends AppException {
  const PermissionException({super.message = 'Permission denied.'});
}

/// Thrown when image picking fails or is cancelled.
class ImagePickException extends AppException {
  const ImagePickException({super.message = 'Image picking failed or was cancelled.'});
}
