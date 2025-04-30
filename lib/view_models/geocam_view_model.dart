import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/geocam_model.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../views/camera_screen.dart';

class GeoCamViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();
  final StorageService _storageService = StorageService();

  GeoCamModel _geoCamData = GeoCamModel();
  bool _isLoading = false;

  GeoCamModel get geoCamData => _geoCamData;
  bool get isLoading => _isLoading;
  bool get hasData => _geoCamData.hasData;
  bool get hasLocation => _geoCamData.hasLocation;
  bool get hasImage => _geoCamData.hasImage;

  GeoCamViewModel() {
    _loadData();
  }

  Future<void> _loadData() async {
    _setLoading(true);

    try {
      final GeoCamModel? storedData = await _storageService.getGeoCamData();

      if (storedData != null) {
        _geoCamData = storedData;
      }
    } catch (e) {
      debugPrint('Error loading GeoCam data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> getLocation() async {
    _setLoading(true);

    try {
      final Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        _geoCamData = _geoCamData.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now().toIso8601String(),
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Method untuk membuka layar kamera
  void openCameraScreen(BuildContext context) async {
    final hasPermission = await checkCameraPermission();
    if (!hasPermission) {
      // Jika tidak mendapatkan izin, tampilkan dialog atau pesan
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Izin kamera diperlukan untuk menggunakan fitur ini')),
        );
      }
      return;
    }

    // Navigasi ke layar kamera jika izin sudah diberikan
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            onImageCaptured: (String imagePath) {
              _geoCamData = _geoCamData.copyWith(
                imagePath: imagePath,
                timestamp: DateTime.now().toIso8601String(),
              );
              notifyListeners();
            },
          ),
        ),
      );
    }
  }

  // take picture (now used via camera screen)
  Future<bool> takePicture() async {
    _setLoading(true);

    try {
      final File? imageFile = await _cameraService.takePicture();

      if (imageFile != null) {
        final String? savedPath = await _cameraService.saveImage(imageFile);

        if (savedPath != null) {
          _geoCamData = _geoCamData.copyWith(
            imagePath: savedPath,
            timestamp: DateTime.now().toIso8601String(),
          );

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // pick image
  Future<bool> pickImage(BuildContext context) async {
    _setLoading(true);

    try {
      // Check photo permission first
      final hasPhotoPermission = await _cameraService.checkPhotosPermission();

      if (!hasPhotoPermission && context.mounted) {
        // Show dialog for photo permission
        _showPhotoPermissionDialog(context);
        _setLoading(false);
        return false;
      }

      // Try to pick image
      final File? imageFile = await _cameraService.pickImage();

      if (imageFile != null) {
        final String? savedPath = await _cameraService.saveImage(imageFile);

        if (savedPath != null) {
          _geoCamData = _geoCamData.copyWith(
            imagePath: savedPath,
            timestamp: DateTime.now().toIso8601String(),
          );

          _setLoading(false);
          return true;
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error picking image: $e');
      _setLoading(false);
      return false;
    }
  }

  // Show photo permission dialog
  void _showPhotoPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Galeri Foto'),
        content: const Text(
            'Aplikasi memerlukan izin untuk mengakses galeri foto Android. '
            'Silakan berikan izin di pengaturan untuk memilih foto dari galeri.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cameraService.openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  // save data
  Future<bool> saveData() async {
    _setLoading(true);

    try {
      return await _storageService.saveGeoCamData(_geoCamData);
    } catch (e) {
      debugPrint('Error saving GeoCam data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // reset data
  Future<bool> resetData() async {
    _setLoading(true);

    try {
      final bool success = await _storageService.clearGeoCamData();

      if (success) {
        _geoCamData = GeoCamModel();
      }

      return success;
    } catch (e) {
      debugPrint('Error resetting GeoCam data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // camera permission
  Future<bool> checkCameraPermission() async {
    return await _cameraService.checkCameraPermission();
  }

  // check permission
  Future<bool> checkLocationPermission() async {
    return await _locationService.checkLocationPermission();
  }

  // appsetting
  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  // loading status
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Metode alternatif untuk mengambil gambar dengan ImagePicker (bukan CameraController)
  Future<bool> takeImageWithPicker(BuildContext context) async {
    _setLoading(true);

    try {
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        // Jika tidak mendapatkan izin, tampilkan dialog atau pesan
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Izin kamera diperlukan untuk menggunakan fitur ini')),
          );
        }
        _setLoading(false);
        return false;
      }

      // Menggunakan image picker untuk ambil gambar via kamera
      final File? imageFile = await _cameraService.takeImageWithPicker();

      if (imageFile != null) {
        final String? savedPath = await _cameraService.saveImage(imageFile);

        if (savedPath != null) {
          _geoCamData = _geoCamData.copyWith(
            imagePath: savedPath,
            timestamp: DateTime.now().toIso8601String(),
          );

          _setLoading(false);
          notifyListeners();
          return true;
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Error taking picture with image picker: $e');
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
