import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/report_models.dart';
import '../services/case_service.dart';
import '../constants/app_theme.dart';
import 'package:flutter/services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  ReportCase? _selectedReport;
  bool _isDetailVisible = false;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  static const double _defaultZoom = 19.0;
  Set<Marker> _markers = {};
  Timer? _reportUpdateTimer;
  final GlobalKey<_ReportDetailWindowState> _detailWindowKey = GlobalKey<_ReportDetailWindowState>();

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
    // Refresh markers frequently to ensure UI is up-to-date when switching tabs.
    _reportUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _loadReports(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh markers immediately when page becomes active
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await CaseService.getAllCases();
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
            onTap: () => _onMarkerTapped(report),
          );
        }).toSet();
      });
    }
  }

  void _onMarkerTapped(ReportCase report) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedReport = report;
      _isDetailVisible = true;
    });
    _adjustCameraForDetail(report);
  }

  void _closeDetail() {
    _detailWindowKey.currentState?.reverseAnimation();
  }

  void _onCloseAnimationCompleted() {
    setState(() {
      _isDetailVisible = false;
      _selectedReport = null;
    });
    // Reset camera position if needed
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
      );
    }
  }

  bool get _isHorizontalOrientation => MediaQuery.of(context).orientation == Orientation.landscape;

  void _adjustCameraForDetail(ReportCase report) async {
    if (_mapController == null) return;

    // Calculate window size percentages
    final windowWidthPercent = _isHorizontalOrientation ? 0.3 : 1.0;  // 30% in landscape
    final windowHeightPercent = _isHorizontalOrientation ? 0.85 : 0.35; // 85% in landscape, 35% in portrait

    // Pan the camera to position the marker in the visible map area.
    final dx = _isHorizontalOrientation ? (MediaQuery.of(context).size.width * windowWidthPercent) / 2.5 : 0.0;
    final dy = _isHorizontalOrientation ? 0.0 : (MediaQuery.of(context).size.height * windowHeightPercent) / 2;

    _mapController?.animateCamera(
      CameraUpdate.scrollBy(dx, dy),
    );
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
          // Map control buttons
          Positioned(
            left: 32.0,
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
          // Detail window
          if (_isDetailVisible && _selectedReport != null)
            Padding(
              padding: EdgeInsets.only(
                right: _isHorizontalOrientation ? 32.0 : 16.0,
                bottom: _isHorizontalOrientation ? 5.0 : 21.0,
                left: _isHorizontalOrientation ? 32.0 : 16.0,
              ),
              child: Align(
                alignment: _isHorizontalOrientation ? Alignment.centerRight : Alignment.bottomCenter,
                child: _ReportDetailWindow(
                key: _detailWindowKey,
                report: _selectedReport!,
                onClose: _closeDetail,
                onCloseAnimationCompleted: _onCloseAnimationCompleted,
                isLargeScreen: _isHorizontalOrientation,
              ),
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

class _ReportDetailWindow extends StatefulWidget {
  final ReportCase report;
  final VoidCallback onClose;
  final VoidCallback onCloseAnimationCompleted;
  final bool isLargeScreen;

  const _ReportDetailWindow({
    Key? key,
    required this.report,
    required this.onClose,
    required this.onCloseAnimationCompleted,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  State<_ReportDetailWindow> createState() => _ReportDetailWindowState();
}

class _ReportDetailWindowState extends State<_ReportDetailWindow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _ensureAnimationsInitialized(BuildContext context) {
    if (_slideAnimation == null || _fadeAnimation == null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.onCloseAnimationCompleted();
        }
      });
      final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
      
      _slideAnimation = Tween<Offset>(
        begin: isLandscape ? const Offset(1.0, 0.0) : const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));

      if (_isFirstBuild) {
        _controller.forward();
        _isFirstBuild = false;
      }
    }
  }

  void reverseAnimation() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _themeColor {
    switch (widget.report.type) {
      case ReportType.amber:
        return AppColors.neonRed;
      case ReportType.witness:
        return AppColors.neonAmber;
      case ReportType.quickPin:
        return AppColors.neonGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Calculate dimensions based on orientation
    final width = isHorizontal ? screenSize.width * 0.3 : screenSize.width * 0.88; // 30% in horizontal, 75% in portrait
    final height = isHorizontal ? screenSize.height * 0.70 : screenSize.height * 0.40; // 70% in horizontal, 40% in portrait

    _ensureAnimationsInitialized(context);
    
    return SlideTransition(
      position: _slideAnimation!,
      child: FadeTransition(
        opacity: _fadeAnimation!,
        child: SizedBox(
          width: width,
          height: height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: _themeColor,
                width: 1.0,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  color: _themeColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _themeColor.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getReportIcon(widget.report.type),
                        color: _themeColor,
                        size: 24.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          _getReportTitle(widget.report.type),
                          style: AppTextStyles.neonTitle(color: _themeColor).copyWith(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: Icon(
                          Icons.close,
                          color: _themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time and Location
                        _DetailItem(
                          icon: Icons.access_time,
                          title: 'Time',
                          content: widget.report.timestamp.toString(),
                          color: _themeColor,
                        ),
                        const SizedBox(height: 16.0),
                        _DetailItem(
                          icon: Icons.location_on,
                          title: 'Location',
                          content: '${widget.report.location['latitude']}, ${widget.report.location['longitude']}',
                          color: _themeColor,
                        ),
                        if (widget.report.note != null) ...[
                          const SizedBox(height: 16.0),
                          _DetailItem(
                            icon: Icons.description,
                            title: 'Description',
                            content: widget.report.note!,
                            color: _themeColor,
                          ),
                        ],
                        // TODO: Add media gallery here
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.amber:
        return Icons.emergency;
      case ReportType.witness:
        return Icons.report_problem;
      case ReportType.quickPin:
        return Icons.location_on;
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
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color.withOpacity(0.7),
              size: 16.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: AppTextStyles.neonSubtitle(color: color).copyWith(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            content,
            style: AppTextStyles.bodyText(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
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