import '../models/report_models.dart';
import 'location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CaseService {
  static const String _storageKey = 'report_cases';
  static Map<String, ReportCase> _cases = {};
  static int _caseCounter = 1000;
  static bool _isInitialized = false;

  static Future<void> _initializeFromStorage() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? casesJson = prefs.getString(_storageKey);
    
    if (casesJson != null) {
      final List<dynamic> casesList = jsonDecode(casesJson);
      _cases = {
        for (var caseData in casesList)
          caseData['id']: ReportCase.fromJson(caseData)
      };
      
      // Update counter based on existing cases
      for (var id in _cases.keys) {
        final caseNumber = int.tryParse(id.replaceAll('CASE-', '')) ?? 1000;
        _caseCounter = _caseCounter > caseNumber ? _caseCounter : caseNumber;
      }
    }
    
    _isInitialized = true;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final casesList = _cases.values.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(casesList));
  }

  static String _generateCaseId() {
    _caseCounter++;
    return 'CASE-$_caseCounter';
  }

  static Future<String> createAmberCase() async {
    await _initializeFromStorage();
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
    await _saveToStorage();
    return caseId;
  }

  static Future<void> updateAmberCase(
    String caseId, {
    String? note,
    PrivacyMode? privacy,
    List<String>? mediaFiles,
  }) async {
    await _initializeFromStorage();
    final existingCase = _cases[caseId];
    if (existingCase != null) {
      _cases[caseId] = existingCase.copyWith(
        note: note,
        privacy: privacy,
        mediaFiles: mediaFiles,
      );
      await _saveToStorage();
    }
  }

  static Future<String> createWitnessCase({
    required IncidentCategory category,
    String? description,
    PrivacyMode privacyMode = PrivacyMode.anonymous,
    List<String> mediaFiles = const [],
  }) async {
    await _initializeFromStorage();
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
    await _saveToStorage();
    return caseId;
  }

  static Future<String> createQuickPin({
    required QuickReportCategory category,
    String? description,
  }) async {
    await _initializeFromStorage();
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
    await _saveToStorage();
    return caseId;
  }

  static Future<String> createSOSCase() async {
    await _initializeFromStorage();
    final locationData = await LocationService.getLocationData();
    final caseId = _generateCaseId();
    
    final reportCase = ReportCase(
      id: caseId,
      type: ReportType.sos,
      timestamp: DateTime.now(),
      location: locationData,
      note: 'Emergency SOS activated',
      privacy: PrivacyMode.identified, // SOS should be identified for emergency response
    );

    _cases[caseId] = reportCase;
    await _saveToStorage();
    return caseId;
  }

  static Future<ReportCase?> getCase(String caseId) async {
    await _initializeFromStorage();
    return _cases[caseId];
  }

  static Future<List<ReportCase>> getAllCases() async {
    await _initializeFromStorage();
    return _cases.values.toList();
  }

  static Future<List<ReportCase>> getRecentCases({int days = 7}) async {
    await _initializeFromStorage();
    final now = DateTime.now();
    return _cases.values
        .where((report) => now.difference(report.timestamp).inDays <= days)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
