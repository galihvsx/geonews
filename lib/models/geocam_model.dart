class GeoCamModel {
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final String? timestamp;

  GeoCamModel({
    this.latitude,
    this.longitude,
    this.imagePath,
    this.timestamp,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasData => hasLocation || hasImage;

  factory GeoCamModel.fromJson(Map<String, dynamic> json) {
    return GeoCamModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'timestamp': timestamp,
    };
  }

  GeoCamModel copyWith({
    double? latitude,
    double? longitude,
    String? imagePath,
    String? timestamp,
  }) {
    return GeoCamModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
