import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  // Metode untuk meminta semua izin yang diperlukan
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    // Minta izin lokasi, kamera, dan penyimpanan sekaligus
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.photos,
      Permission.videos,
      Permission.mediaLibrary,
    ].request();

    return statuses;
  }

  // Metode untuk memeriksa status izin
  Future<bool> checkPermissionStatus(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Metode untuk membuka pengaturan aplikasi
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // Metode untuk menampilkan dialog ketika izin ditolak
  void showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Diperlukan'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Buka Pengaturan'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
