import 'package:flutter/material.dart';
import '../widgets/camera_preview_widget.dart';

class CameraScreen extends StatelessWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CameraPreviewWidget(
          onImageCaptured: (String imagePath) {
            // Panggil callback dan kembali ke layar sebelumnya
            onImageCaptured(imagePath);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
