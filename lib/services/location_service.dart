import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  // Singleton instance
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  // Metode untuk memeriksa izin lokasi
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi diaktifkan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak diaktifkan, tidak dapat mengambil lokasi
      return false;
    }

    // Periksa izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Izin lokasi ditolak, minta izin
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak oleh pengguna
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak secara permanen, tidak dapat meminta izin
      return false;
    }

    // Izin diberikan
    return true;
  }

  // Metode untuk mengambil lokasi saat ini
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Dapatkan lokasi saat ini
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      return null;
    }
  }

  // Metode untuk membuka pengaturan lokasi
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Metode untuk membuka pengaturan aplikasi
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
