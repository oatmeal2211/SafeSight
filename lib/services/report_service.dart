import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_models.dart';

class ReportService {
  static const String _key = 'reports';
  final SharedPreferences _prefs;

  ReportService(this._prefs);

  Future<List<Report>> getReports() async {
    final String? reportsJson = _prefs.getString(_key);
    if (reportsJson == null) return [];

    final List<dynamic> reportsList = json.decode(reportsJson);
    return reportsList.map((json) => Report.fromJson(json)).toList();
  }

  Future<void> addReport(Report report) async {
    final reports = await getReports();
    reports.add(report);
    
    final reportsJson = json.encode(reports.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, reportsJson);
  }

  Future<void> clearReports() async {
    await _prefs.remove(_key);
  }
}
