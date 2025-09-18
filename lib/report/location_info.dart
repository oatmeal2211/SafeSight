import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/location_service.dart';

class LocationInfo extends StatefulWidget {
  final Color color;

  const LocationInfo({
    super.key,
    required this.color,
  });

  @override
  State<LocationInfo> createState() => _LocationInfoState();
}

class _LocationInfoState extends State<LocationInfo> {
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final data = await LocationService.getLocationData();
    if (mounted) {
      setState(() {
        _locationData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.color.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.videocam,
              color: widget.color.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _locationData != null
                ? '${_locationData!['landmark']} • ${_locationData!['coordinates']}'
                : 'Loading location...',
              style: AppTextStyles.cctvText(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
