import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=150'
        '&key=\${GOOGLE_MAPS_API_KEY}'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return 'Near ${data['results'][0]['name']}';
        }
      }
      return 'Campus Area';
    } catch (e) {
      debugPrint('Error fetching landmark: $e');
      return 'Campus Area';
    }
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
