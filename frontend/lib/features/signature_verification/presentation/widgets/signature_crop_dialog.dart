import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

/// Displays a full-screen crop dialog for signature images.
///
/// Returns the cropped [Uint8List] bytes, or `null` if the user cancels.
Future<Uint8List?> showSignatureCropDialog(
  BuildContext context, {
  required Uint8List imageBytes,
}) async {
  return showDialog<Uint8List?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _CropDialog(imageBytes: imageBytes),
  );
}

class _CropDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const _CropDialog({required this.imageBytes});

  @override
  State<_CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<_CropDialog> {
  final _cropController = CropController();

  void _onCropped(CropResult result) {
    if (result is CropSuccess) {
      Navigator.of(context).pop(result.croppedImage);
    } else if (result is CropFailure) {
      debugPrint('Crop failed: ${result.cause}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Crop Signature',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => _cropController.crop(),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              onCropped: _onCropped,
              maskColor: Colors.black.withValues(alpha: 0.6),
              baseColor: Colors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.black,
            child: const Text(
              'Center your signature inside the frame',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
