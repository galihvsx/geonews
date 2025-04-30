import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../view_models/geocam_view_model.dart';
import '../widgets/loading_indicator.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class GeoCamScreen extends StatelessWidget {
  const GeoCamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeoCamViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const LoadingIndicator(message: AppConstants.loading);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                duration: AppConstants.animationDuration,
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Lokasi
                  _buildLocationSection(context, viewModel),

                  const SizedBox(height: 20),

                  // Foto
                  _buildImageSection(context, viewModel),

                  const SizedBox(height: 20),

                  // Tombol aksi
                  _buildActionButtons(context, viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationSection(
      BuildContext context, GeoCamViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppConstants.yourLocation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.gps_fixed),
                  onPressed: () async {
                    final result = await viewModel.getLocation();

                    if (!result && context.mounted) {
                      _showPermissionDialog(
                          context, AppConstants.locationPermissionDenied);
                    }
                  },
                  tooltip: AppConstants.getLocation,
                ),
              ],
            ),
            const SizedBox(height: 10),
            viewModel.hasLocation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoordinateItem(
                          AppConstants.latitude, viewModel.geoCamData.latitude),
                      const SizedBox(height: 8),
                      _buildCoordinateItem(AppConstants.longitude,
                          viewModel.geoCamData.longitude),
                      if (viewModel.geoCamData.timestamp != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Diambil: ${DateFormatter.formatDate(viewModel.geoCamData.timestamp!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        AppConstants.locationNotAvailable,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateItem(String label, double? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          TextFormatter.formatCoordinate(value),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, GeoCamViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        final hasPermission =
                            await viewModel.checkCameraPermission();

                        if (!hasPermission && context.mounted) {
                          _showPermissionDialog(
                              context, AppConstants.cameraPermissionDenied);
                          return;
                        }

                        if (context.mounted) {
                          _showCameraOptions(context, viewModel);
                        }
                      },
                      tooltip: AppConstants.takePhoto,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () async {
                        final result = await viewModel.pickImage(context);

                        if (!result && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text(AppConstants.storagePermissionDenied),
                            ),
                          );
                        }
                      },
                      tooltip: AppConstants.pickFromGallery,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            viewModel.hasImage
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(viewModel.geoCamData.imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (viewModel.geoCamData.timestamp != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Diambil: ${DateFormatter.formatDate(viewModel.geoCamData.timestamp!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        AppConstants.noPhoto,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context, GeoCamViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Metode Kamera',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera Android (Simple)'),
              subtitle: const Text('Menggunakan kamera bawaan Android'),
              onTap: () async {
                Navigator.pop(context);
                final result = await viewModel.takeImageWithPicker(context);
                if (!result && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppConstants.errorCapturingPhoto),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_enhance),
              title: const Text('Kamera Custom (Advanced)'),
              subtitle: const Text('Menggunakan tampilan kamera kustom'),
              onTap: () {
                Navigator.pop(context);
                viewModel.openCameraScreen(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GeoCamViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.hasData
                ? () async {
                    final result = await viewModel.saveData();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? AppConstants.dataSaved
                                : AppConstants.errorSavingData,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.save),
            label: Text(AppConstants.save),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.hasData
                ? () async {
                    final result = await viewModel.resetData();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? AppConstants.dataReset
                                : AppConstants.errorResettingData,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.delete),
            label: Text(AppConstants.reset),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.permissionRequired),
        content: Text(AppConstants.permissionRequiredMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(AppConstants.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final viewModel =
                  Provider.of<GeoCamViewModel>(context, listen: false);
              await viewModel.openAppSettings();
            },
            child: const Text(AppConstants.openSettings),
          ),
        ],
      ),
    );
  }
}
