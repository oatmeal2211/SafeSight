import '../models/report_models.dart';
import 'location_service.dart';

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
      location: locationData,
      privacy: PrivacyMode.anonymous,
    );

    _cases[caseId] = reportCase;
    
    // TODO: Implement map pin logic
    
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
        note: note,
        privacy: privacy,
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
      location: locationData,
      note: description,
      privacy: privacyMode,
      incidentCategory: category,
      mediaFiles: mediaFiles,
    );

    _cases[caseId] = reportCase;
    
    // TODO: Implement map pin logic
    
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
      location: locationData,
      note: description,
      quickReportCategory: category,
      privacy: PrivacyMode.anonymous,
    );

    _cases[caseId] = reportCase;
    
    // TODO: Implement map pin logic
    
    return caseId;
  }

  static ReportCase? getCase(String caseId) {
    return _cases[caseId];
  }

  static List<ReportCase> getAllCases() {
    return _cases.values.toList();
  }
}
