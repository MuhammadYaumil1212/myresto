import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/values/colors/colors.dart';
import '../data/dataSources/running_time_local_datasource.dart';
import '../data/repository/running_time_repository.dart';
import '../data/models/search_log.dart';

class RunningTimePage extends StatefulWidget {
  const RunningTimePage({super.key});

  @override
  State<RunningTimePage> createState() => _RunningTimePageState();
}

class _runningStats {
  final int count;
  final double avg;
  final int min;
  final int max;

  const _runningStats({
    required this.count,
    required this.avg,
    required this.min,
    required this.max,
  });
}

class _RunningTimePageState extends State<RunningTimePage> {
  late final RunningTimeRepository _runningTimeRepository;

  @override
  void initState() {
    super.initState();
    _runningTimeRepository = RunningTimeRepository(
      datasource: RunningTimeLocalDatasource(),
    );
  }

  _runningStats _stats(List<SearchLog> items) {
    if (items.isEmpty) {
      return const _runningStats(count: 0, avg: 0, min: 0, max: 0);
    }

    final times = items.map((e) => e.executionTimeUs).toList()..sort();
    final sum = times.fold<int>(0, (p, e) => p + e);
    final avg = sum / times.length;

    return _runningStats(
      count: times.length,
      avg: avg.toDouble(),
      min: times.first,
      max: times.last,
    );
  }

  String _winnerLabel(_runningStats it, _runningStats rec) {
    if (it.count == 0 && rec.count == 0) return "-";
    if (it.count == 0) return "Rekursif (Iteratif kosong)";
    if (rec.count == 0) return "Iteratif (Rekursif kosong)";
    if (it.avg == rec.avg) return "Imbang";
    return it.avg < rec.avg ? "Iteratif lebih cepat" : "Rekursif lebih cepat";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text("Analisis Performa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _runningTimeRepository.clearHistory();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SearchLog>>(
        future: _runningTimeRepository.getSearchHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data history."));
          }

          final logs = snapshot.data!;

          double maxExecutionTime = 0;
          for (var log in logs) {
            if (log.executionTimeUs > maxExecutionTime) {
              maxExecutionTime = log.executionTimeUs.toDouble();
            }
          }

          final List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < logs.length; i++) {
            final log = logs[i];
            final isIterative = log.method == "Iteratif";

            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: log.executionTimeUs.toDouble(),
                    color: isIterative ? Colors.blue : Colors.orange,
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedLogs = [...logs]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final Map<int, List<SearchLog>> groupedByPrice = {};
          for (final log in sortedLogs) {
            groupedByPrice.putIfAbsent(log.price, () => []);
            groupedByPrice[log.price]!.add(log);
          }

          final prices = groupedByPrice.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final price = prices[index];
                      final items = groupedByPrice[price]!;

                      final iterative = items
                          .where((e) => e.method == "Iteratif")
                          .toList();
                      final recursive = items
                          .where((e) => e.method == "Rekursif")
                          .toList();

                      final itStats = _stats(iterative);
                      final recStats = _stats(recursive);

                      final maxAvg = (itStats.avg > recStats.avg
                          ? itStats.avg
                          : recStats.avg);
                      final miniMaxY = maxAvg == 0 ? 10.0 : maxAvg * 1.2;

                      return Card(
                        color: Colors.white,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(20),
                          side: const BorderSide(
                            color: MyColors.brown200,
                            width: 1.5,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          backgroundColor: Colors.white,
                          splashColor: Colors.transparent,
                          leading: const Icon(Icons.payments_outlined),
                          title: Text("Input Price: Rp $price"),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            12,
                          ),
                          children: [
                            const SizedBox(height: 12),

                            _MiniComparisonChart(
                              maxY: miniMaxY,
                              iterAvg: itStats.avg,
                              recAvg: recStats.avg,
                            ),

                            const SizedBox(height: 12),

                            _MethodSection(
                              title: "Iteratif",
                              color: Colors.blue,
                              logs: iterative,
                            ),
                            const SizedBox(height: 10),
                            _MethodSection(
                              title: "Rekursif",
                              color: Colors.orange,
                              logs: recursive,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniComparisonChart extends StatelessWidget {
  final double maxY;
  final double iterAvg;
  final double recAvg;

  const _MiniComparisonChart({
    required this.maxY,
    required this.iterAvg,
    required this.recAvg,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: iterAvg,
            color: Colors.blue,
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: recAvg,
            color: Colors.orange,
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: groups,
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 && meta.min == 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '${value.toInt()} ms',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    final label = idx == 0 ? "Iteratif" : "Rekursif";
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final title = group.x == 0 ? "Iteratif" : "Rekursif";
                  return BarTooltipItem(
                    "$title\n",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "${rod.toY.toStringAsFixed(2)} ms",
                        style: const TextStyle(color: Colors.yellowAccent),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<SearchLog> logs;

  const _MethodSection({
    required this.title,
    required this.color,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Belum ada history untuk metode ini."),
              ),
            )
          else
            ...logs.map(
              (log) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    title[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text("Steps: ${log.steps}"),
                subtitle: Text("Time: ${log.timestamp.substring(11, 19)}"),
                trailing: Text(
                  "${log.executionTimeUs} ms",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
