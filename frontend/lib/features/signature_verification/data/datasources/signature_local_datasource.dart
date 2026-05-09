import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';

/// Contract for local image picking operations.
abstract class SignatureLocalDataSource {
  /// Picks an image from the camera or gallery.
  /// [fromCamera] determines the source.
  Future<File> pickImage({required bool fromCamera});
}

/// Concrete implementation using the `image_picker` plugin.
class SignatureLocalDataSourceImpl implements SignatureLocalDataSource {
  final ImagePicker _picker;

  SignatureLocalDataSourceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<File> pickImage({required bool fromCamera}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User cancelled the picker.
        throw const ImagePickException(message: 'No image selected.');
      }

      return File(pickedFile.path);
    } on ImagePickException {
      rethrow;
    } catch (e) {
      throw ImagePickException(message: 'Failed to pick image: ${e.toString()}');
    }
  }
}
