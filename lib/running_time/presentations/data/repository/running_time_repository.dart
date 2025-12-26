import 'package:myresto/running_time/presentations/data/dataSources/running_time_local_datasource.dart';

import '../models/search_log.dart';

class RunningTimeRepository {
  final RunningTimeLocalDatasource datasource;
  RunningTimeRepository({required this.datasource});

  Future<void> saveSearchLog({
    required String method,
    required int price,
    required int timeUs,
    required int steps,
  }) async {
    final log = SearchLog(
      method: method,
      price: price,
      executionTimeUs: timeUs,
      steps: steps,
      timestamp: DateTime.now().toIso8601String(),
    );
    await datasource.insertLog(log);
  }

  Future<List<SearchLog>> getSearchHistory() async {
    return await datasource.getAllLogs();
  }

  Future<void> clearHistory() async {
    await datasource.clearLogs();
  }
}
