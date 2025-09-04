import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Position? _lastKnownPosition;

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location permission is granted
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      // Return last known position if available
      return _lastKnownPosition;
    }
  }

  static Future<String> getLandmark(double latitude, double longitude) async {
    // Mock landmark detection based on campus locations
    final landmarks = [
      {'name': 'Library Entrance', 'lat': 40.7306, 'lng': -73.9352, 'radius': 0.001},
      {'name': 'Student Center', 'lat': 40.7308, 'lng': -73.9355, 'radius': 0.001},
      {'name': 'Science Building', 'lat': 40.7304, 'lng': -73.9349, 'radius': 0.001},
      {'name': 'Dormitory A', 'lat': 40.7310, 'lng': -73.9358, 'radius': 0.001},
      {'name': 'Cafeteria', 'lat': 40.7302, 'lng': -73.9346, 'radius': 0.001},
      {'name': 'Gymnasium', 'lat': 40.7312, 'lng': -73.9361, 'radius': 0.001},
      {'name': 'Parking Lot B', 'lat': 40.7300, 'lng': -73.9343, 'radius': 0.001},
      {'name': 'Campus Plaza', 'lat': 40.7307, 'lng': -73.9353, 'radius': 0.001},
    ];

    // Find nearest landmark
    double minDistance = double.infinity;
    String nearestLandmark = 'Campus Area';

    for (final landmark in landmarks) {
      final landmarkLat = landmark['lat'] as double;
      final landmarkLng = landmark['lng'] as double;

      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        landmarkLat,
        landmarkLng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestLandmark = landmark['name'] as String;
      }
    }

    // If within 100 meters of a landmark, return it
    if (minDistance <= 100) {
      return nearestLandmark;
    }

    return 'Campus Area';
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}°N, ${longitude.abs().toStringAsFixed(4)}°W';
  }

  static String getCurrentTimestamp() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static Future<Map<String, dynamic>> getLocationData() async {
    final position = await getCurrentLocation();
    
    if (position == null) {
      return {
        'latitude': 40.7306,  // Default campus location
        'longitude': -73.9352,
        'landmark': 'Campus Area',
        'coordinates': '40.7306°N, 73.9352°W',
        'timestamp': getCurrentTimestamp(),
      };
    }

    final landmark = await getLandmark(position.latitude, position.longitude);
    
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'landmark': landmark,
      'coordinates': formatCoordinates(position.latitude, position.longitude),
      'timestamp': getCurrentTimestamp(),
    };
  }
}
