import '../models/report_models.dart';
import 'location_service.dart';

enum PinType { amber, red, gray }

class CaseService {
  static final Map<String, ReportCase> _cases = {};
  static int _caseCounter = 1000;

  static String _generateCaseId() {
    _caseCounter++;
    return 'CASE-$_caseCounter';
  }

  static Future<String> createAmberCase() async {
    final locationData = await LocationService.getLocationData();
    final caseId = _generateCaseId();
    
    final reportCase = ReportCase(
      id: caseId,
      type: ReportType.amber,
      timestamp: DateTime.now(),
      latitude: locationData['latitude'],
      longitude: locationData['longitude'],
      nearestLandmark: locationData['landmark'],
      privacyMode: PrivacyMode.anonymous,
    );

    _cases[caseId] = reportCase;
    
    // Drop amber pin on map (stub)
    MapPins.dropPin(PinType.amber, reportCase.latitude!, reportCase.longitude!);
    
    return caseId;
  }

  static Future<void> updateAmberCase(
    String caseId, {
    String? note,
    PrivacyMode? privacy,
    List<String>? mediaFiles,
  }) async {
    final existingCase = _cases[caseId];
    if (existingCase != null) {
      _cases[caseId] = existingCase.copyWith(
        description: note,
        privacyMode: privacy,
        mediaFiles: mediaFiles,
      );
    }
  }

  static Future<String> createWitnessCase({
    required IncidentCategory category,
    String? description,
    PrivacyMode privacyMode = PrivacyMode.anonymous,
    List<String> mediaFiles = const [],
  }) async {
    final locationData = await LocationService.getLocationData();
    final caseId = _generateCaseId();
    
    final reportCase = ReportCase(
      id: caseId,
      type: ReportType.witness,
      timestamp: DateTime.now(),
      latitude: locationData['latitude'],
      longitude: locationData['longitude'],
      nearestLandmark: locationData['landmark'],
      description: description,
      privacyMode: privacyMode,
      incidentCategory: category,
      mediaFiles: mediaFiles,
    );

    _cases[caseId] = reportCase;
    
    // Drop red pin on map (stub)
    MapPins.dropPin(PinType.red, reportCase.latitude!, reportCase.longitude!);
    
    return caseId;
  }

  static Future<String> createQuickPin({
    required QuickReportCategory category,
    String? description,
  }) async {
    final locationData = await LocationService.getLocationData();
    final caseId = _generateCaseId();
    
    final reportCase = ReportCase(
      id: caseId,
      type: ReportType.quickPin,
      timestamp: DateTime.now(),
      latitude: locationData['latitude'],
      longitude: locationData['longitude'],
      nearestLandmark: locationData['landmark'],
      description: description,
      quickCategory: category,
      privacyMode: PrivacyMode.anonymous,
    );

    _cases[caseId] = reportCase;
    
    // Drop gray pin on map (stub)
    MapPins.dropPin(PinType.gray, reportCase.latitude!, reportCase.longitude!);
    
    return caseId;
  }

  static ReportCase? getCase(String caseId) {
    return _cases[caseId];
  }

  static List<ReportCase> getAllCases() {
    return _cases.values.toList();
  }
}

// Mock map pins service
class MapPins {
  static final List<Map<String, dynamic>> _pins = [];

  static void dropPin(PinType type, double latitude, double longitude) {
    final pin = {
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now(),
    };
    
    _pins.add(pin);
    
    // Log for debugging
    print('📍 Dropped ${type.name} pin at $latitude, $longitude');
  }

  static List<Map<String, dynamic>> getAllPins() {
    return List.from(_pins);
  }

  static void clearPins() {
    _pins.clear();
  }
}
