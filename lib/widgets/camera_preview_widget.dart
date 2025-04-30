import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import 'loading_indicator.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraPreviewWidget({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Menangani app lifecycle untuk kamera
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final success = await _cameraService.initializeCamera();

      if (!success) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Gagal menginisialisasi kamera. Pastikan izin kamera telah diberikan.';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final imageFile = await _cameraService.takePicture();
      if (imageFile != null) {
        final savedPath = await _cameraService.saveImage(imageFile);
        if (savedPath != null && mounted) {
          widget.onImageCaptured(savedPath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengambil gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const LoadingIndicator(message: 'Menginisialisasi kamera...');
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return const Center(
        child: Text('Kamera tidak tersedia'),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraService.controller!),
        ),

        // Tombol capture
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),

        // Tombol tutup
        Positioned(
          top: 24,
          right: 24,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
