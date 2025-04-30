import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class CameraService {
  static final CameraService _instance = CameraService._internal();

  factory CameraService() => _instance;

  CameraService._internal();

  List<CameraDescription>? cameras;
  CameraController? controller;
  bool _isInitialized = false;

  Future<bool> initializeCamera() async {
    if (_isInitialized) return true;

    try {
      // Request camera permission
      final status = await ph.Permission.camera.request();
      if (!status.isGranted) {
        if (kDebugMode) {
          print('Camera permission not granted: $status');
        }
        return false;
      }

      // Get available cameras
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        if (kDebugMode) {
          print('No cameras available');
        }
        return false;
      }

      // Initialize camera controller
      controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('Camera initialized successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
      return false;
    }
  }

  Future<File?> takePicture() async {
    if (!_isInitialized ||
        controller == null ||
        !controller!.value.isInitialized) {
      if (kDebugMode) {
        print('Attempting to initialize camera first...');
      }
      final success = await initializeCamera();
      if (!success) {
        return null;
      }
    }

    try {
      // Capture the image
      if (kDebugMode) {
        print('Taking picture...');
      }

      final XFile image = await controller!.takePicture();

      if (kDebugMode) {
        print('Picture taken: ${image.path}');
      }

      File imageFile = File(image.path);
      return imageFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
      return null;
    }
  }

  Future<bool> requestImagePickerPermissions() async {
    if (kDebugMode) {
      print('Requesting image picker permissions...');
    }

    // Different permission request strategy based on platform and Android version
    if (Platform.isAndroid) {
      // Android 13+ uses Photos permission
      // Android 14+ uses Photos selected permission
      final sdkInt = await _getAndroidSDKInt();

      if (kDebugMode) {
        print('Android SDK version: $sdkInt');
      }

      if (sdkInt >= 33) {
        // Android 13+
        // Check Photos permission first
        var photosStatus = await ph.Permission.photos.status;
        if (kDebugMode) {
          print('Current photos permission status: $photosStatus');
        }

        // Request Photos permission if not granted
        if (!photosStatus.isGranted) {
          photosStatus = await ph.Permission.photos.request();
          if (kDebugMode) {
            print('Photos permission after request: $photosStatus');
          }
        }

        return photosStatus.isGranted;
      } else {
        // For older Android versions, we need storage permission
        var storageStatus = await ph.Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await ph.Permission.storage.request();
        }

        return storageStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      // For iOS
      var photosStatus = await ph.Permission.photos.status;
      if (!photosStatus.isGranted) {
        photosStatus = await ph.Permission.photos.request();
      }

      return photosStatus.isGranted;
    }

    return false;
  }

  // Helper method to get Android SDK version
  Future<int> _getAndroidSDKInt() async {
    try {
      if (Platform.isAndroid) {
        final String? androidVersion = await _getAndroidVersion();
        if (androidVersion != null) {
          // Parse Android version to get SDK int
          if (androidVersion.startsWith('14')) return 34; // Android 14
          if (androidVersion.startsWith('13')) return 33; // Android 13
          if (androidVersion.startsWith('12')) return 31; // Android 12
          if (androidVersion.startsWith('11')) return 30; // Android 11
          if (androidVersion.startsWith('10')) return 29; // Android 10
          return 28; // Default to Android 9 (API 28)
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Android SDK version: $e');
      }
      return 0;
    }
  }

  // Get Android version
  Future<String?> _getAndroidVersion() async {
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Android version: $e');
      }
      return null;
    }
  }

  Future<File?> pickImage() async {
    try {
      // Request appropriate permissions first
      final bool permissionsGranted = await requestImagePickerPermissions();

      if (!permissionsGranted) {
        if (kDebugMode) {
          print('Image picker permissions not granted');
        }
        return null;
      }

      if (kDebugMode) {
        print('Opening image picker (gallery)...');
      }

      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (kDebugMode) {
          print('No image selected');
        }
        return null;
      }

      if (kDebugMode) {
        print('Image picked: ${pickedFile.path}');
      }

      // Verifikasi file ada dan valid
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('File does not exist: ${pickedFile.path}');
        }
        return null;
      }

      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  Future<String?> saveImage(File imageFile) async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${appDocumentsDir.path}/geocam_$timestamp.jpg';

      if (kDebugMode) {
        print('Saving image to: $filePath');
      }

      await imageFile.copy(filePath);

      if (kDebugMode) {
        print('Image saved successfully');
      }

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image: $e');
      }
      return null;
    }
  }

  void dispose() {
    if (controller != null) {
      controller!.dispose();
      _isInitialized = false;
      if (kDebugMode) {
        print('Camera controller disposed');
      }
    }
  }

  Future<bool> checkCameraPermission() async {
    return await ph.Permission.camera.isGranted;
  }

  Future<bool> checkPhotosPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSDKInt();

      if (sdkInt >= 33) {
        // Android 13+
        return await ph.Permission.photos.isGranted;
      } else {
        return await ph.Permission.storage.isGranted;
      }
    } else {
      return await ph.Permission.photos.isGranted;
    }
  }

  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  // Metode tambahan khusus untuk mengambil gambar langsung dengan kamera via ImagePicker (bukan CameraController)
  Future<File?> takeImageWithPicker() async {
    try {
      // Request camera permission
      final status = await ph.Permission.camera.request();
      if (!status.isGranted) {
        if (kDebugMode) {
          print('Camera permission not granted: $status');
        }
        return null;
      }

      if (kDebugMode) {
        print('Opening camera via image picker...');
      }

      // Menggunakan ImagePicker untuk mengambil gambar dari kamera
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) {
        if (kDebugMode) {
          print('No photo taken');
        }
        return null;
      }

      if (kDebugMode) {
        print('Photo taken: ${photo.path}');
      }

      final File imageFile = File(photo.path);
      return imageFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error taking photo with image picker: $e');
      }
      return null;
    }
  }
}
