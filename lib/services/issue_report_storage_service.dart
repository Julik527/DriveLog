import 'package:shared_preferences/shared_preferences.dart';

import '../models/issue_report.dart';

class IssueReportStorageService {
  static const String _storageKey = 'drivelog_issue_reports_v2';

  Future<List<IssueReport>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    return data.map(IssueReport.decode).toList();
  }

  Future<void> saveReports(List<IssueReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, reports.map((report) => report.encode()).toList());
  }

  Future<void> addReport(IssueReport report) async {
    final reports = await loadReports();
    reports.add(report);
    await saveReports(reports);
  }

  Future<void> updateReport(IssueReport updatedReport) async {
    final reports = await loadReports();
    final index = reports.indexWhere((report) => report.id == updatedReport.id);
    if (index == -1) {
      reports.add(updatedReport);
    } else {
      reports[index] = updatedReport;
    }
    await saveReports(reports);
  }

  Future<void> deleteReport(String id) async {
    final reports = await loadReports();
    reports.removeWhere((report) => report.id == id);
    await saveReports(reports);
  }
}
