import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/report_models.dart';
import '../services/case_service.dart';
import '../constants/app_theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  static const double _defaultZoom = 15.0;
  Set<Marker> _markers = {};
  Timer? _reportUpdateTimer;

  @override
  void initState() {
    super.initState();
    _handleLocationPermission().then((granted) {
      if (granted) {
        _getCurrentLocation();
      }
    });
    // Load initial reports
    _loadReports();
    // Update markers every 30 seconds
    _reportUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadReports(),
    );
  }

  Future<void> _loadReports() async {
    final reports = CaseService.getAllCases();
    if (mounted) {
      setState(() {
        _markers = reports.map((report) {
          final location = report.location;
          return Marker(
            markerId: MarkerId(report.id),
            position: LatLng(
              location['latitude'] as double,
              location['longitude'] as double,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(report.type)),
            infoWindow: InfoWindow(
              title: _getReportTitle(report.type),
              snippet: report.note ?? 'No description provided',
            ),
          );
        }).toSet();
      });
    }
  }

  double _getMarkerHue(ReportType type) {
    switch (type) {
      case ReportType.amber:
        return BitmapDescriptor.hueRed;
      case ReportType.witness:
        return BitmapDescriptor.hueOrange;
      case ReportType.quickPin:
        return BitmapDescriptor.hueGreen;
    }
  }

  String _getReportTitle(ReportType type) {
    switch (type) {
      case ReportType.amber:
        return 'AMBER ALERT';
      case ReportType.witness:
        return 'SERIOUS INCIDENT';
      case ReportType.quickPin:
        return 'QUICK PIN';
    }
  }

  Future<bool> _handleLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (!mounted) return false; // Add this check
      final v = await showDialog<bool>(
        context: context,
        builder: (context) => _LocationPermissionDialog(),
      );
      if (v == true) {
        if (await Permission.location.request().isGranted) {
          return true;
        }
      }
    } else if (status.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _reportUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MAP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF000000),
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: _currentPosition == null
                ? const Center(
                    child: Text(
                      'Loading map...',
                      style: TextStyle(
                        color: Color(0xFF39FF14),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: _defaultZoom,
                    ),
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                  ),
            ),
          ),
          Positioned(
            right: 32.0,
            bottom: 32.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CustomMapButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                _CustomMapButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                _CustomMapButton(
                  icon: Icons.my_location,
                  onPressed: () async {
                    await _getCurrentLocation();
                    if (_currentPosition != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CustomMapButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: const Color(0xFF39FF14),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: const Color(0xFF39FF14),
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPermissionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFF39FF14), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Color(0xFF39FF14),
              size: 48.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Location Permission',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'SafeSight needs access to your location to show you on the map and provide safety features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Deny',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}