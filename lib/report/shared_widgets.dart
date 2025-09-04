import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';

// MetaStrip - Unified details UI for all report screens
class MetaStrip extends StatefulWidget {
  final bool showRecording;

  const MetaStrip({
    super.key,
    this.showRecording = false,
  });

  @override
  State<MetaStrip> createState() => _MetaStripState();
}

class _MetaStripState extends State<MetaStrip> {
  Timer? _timeTimer;
  Timer? _blinkTimer;
  StreamSubscription<Position>? _positionStream;
  String _currentTime = '';
  String _coordinates = '—';
  String _accuracy = '—';
  String _landmark = 'Near Student Center';
  bool _recBlinking = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _startTimeUpdates();
    _requestLocationPermission();
    if (widget.showRecording) {
      _startBlinking();
    }
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _blinkTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  void _startTimeUpdates() {
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    setState(() {
      _currentTime = formatter.format(now);
    });
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      setState(() {
        _recBlinking = !_recBlinking;
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _startLocationUpdates();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission needed',
              style: AppTextStyles.bodyText(color: AppColors.neonRed),
            ),
            backgroundColor: AppColors.background,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.neonRed.withValues(alpha: 0.3)),
            ),
          ),
        );
      }
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen(
      (Position position) {
        setState(() {
          _coordinates = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          _accuracy = '${position.accuracy.round()}m';
          _landmark = _generateLandmark(position);
        });
      },
      onError: (error) {
        setState(() {
          _coordinates = '—';
          _accuracy = '—';
        });
      },
    );
  }

  String _generateLandmark(Position position) {
    // Mock landmark generation based on coordinates
    final buildings = [
      'Student Center',
      'Engineering Hall',
      'Library Building',
      'Science Complex',
      'Arts Building',
      'Administration Building',
      'Gymnasium',
      'Dining Hall',
      'Dormitory Block A',
      'Parking Structure'
    ];
    final random = Random(position.latitude.hashCode + position.longitude.hashCode);
    return 'Near ${buildings[random.nextInt(buildings.length)]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildMetaRow('TIME', _currentTime, widget.showRecording ? _buildRecIndicator() : null),
          _buildDivider(),
          _buildMetaRow('COORDINATES', _coordinates),
          _buildDivider(),
          _buildMetaRow('ACCURACY', _accuracy),
          _buildDivider(),
          _buildMetaRow('NEAREST LANDMARK', _landmark),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, [Widget? trailing]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyText(color: AppColors.neonGreen),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.neonGreen.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildRecIndicator() {
    return AnimatedOpacity(
      opacity: _recBlinking ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.neonRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'REC',
            style: AppTextStyles.cctvText(color: AppColors.neonRed),
          ),
        ],
      ),
    );
  }
}

// Updated NeonButton with improved typography
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final bool filled;
  final double? width;
  final double? height;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.neonGreen,
    this.filled = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: filled ? AppColors.background : color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text.toUpperCase(),
                  style: AppTextStyles.neonButton(
                    color: filled ? AppColors.background : color,
                  ).copyWith(
                    shadows: filled ? null : neonGlow(color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Updated NeonTile with improved typography
class NeonTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const NeonTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color = AppColors.neonGreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.neonSubtitle(color: color),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodyText(color: AppColors.inactiveGray),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Updated NeonDropdown with improved typography
class NeonDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemToString;
  final Color color;

  const NeonDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    required this.itemToString,
    this.color = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyText(color: color),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: AppColors.background,
        style: AppTextStyles.bodyText(color: AppColors.white),
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemToString(item),
            style: AppTextStyles.bodyText(color: AppColors.white),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// Updated NeonSegmented with improved typography
class NeonSegmented<T> extends StatelessWidget {
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T) optionToString;
  final Color color;

  const NeonSegmented({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.optionToString,
    this.color = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    optionToString(option).toUpperCase(),
                    style: AppTextStyles.neonButton(
                      color: isSelected ? color : AppColors.inactiveGray,
                    ).copyWith(
                      shadows: isSelected ? neonGlow(color) : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Updated NeonTextField with improved typography
class NeonTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final Color color;

  const NeonTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.color = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: AppTextStyles.bodyText(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.bodyText(color: color),
          hintStyle: AppTextStyles.bodyText(color: AppColors.inactiveGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Media picker row widget
class MediaRow extends StatelessWidget {
  final List<String> mediaFiles;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddVideo;
  final Function(int)? onRemove;

  const MediaRow({
    super.key,
    required this.mediaFiles,
    this.onAddPhoto,
    this.onAddVideo,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonButton(
                text: 'Add Photo',
                onPressed: onAddPhoto,
                color: AppColors.neonBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeonButton(
                text: 'Add Video',
                onPressed: onAddVideo,
                color: AppColors.neonOrange,
              ),
            ),
          ],
        ),
        if (mediaFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...mediaFiles.asMap().entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  entry.value.contains('video') ? Icons.videocam : Icons.photo,
                  color: AppColors.neonGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.bodyText(color: AppColors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove?.call(entry.key),
                  icon: const Icon(Icons.close, color: AppColors.neonRed, size: 20),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }
}
