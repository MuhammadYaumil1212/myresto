import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/dataSources/running_time_local_datasource.dart';
import '../data/repository/running_time_repository.dart';
import '../data/models/search_log.dart';

class RunningTimePage extends StatefulWidget {
  const RunningTimePage({super.key});

  @override
  State<RunningTimePage> createState() => _RunningTimePageState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
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

          List<FlSpot> iterativeSpots = [];
          List<FlSpot> recursiveSpots = [];

          for (int i = 0; i < logs.length; i++) {
            final log = logs[i];
            final spot = FlSpot(i.toDouble(), log.executionTimeUs.toDouble());

            if (log.method == "Iteratif") {
              iterativeSpots.add(spot);
            } else {
              recursiveSpots.add(spot);
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Grafik Waktu Eksekusi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color(0xff37434d).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  (value.toInt() + 1).toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final index = barSpot.x.toInt();
                              final log = logs[index];
                              return LineTooltipItem(
                                '${log.method}\n${log.executionTimeUs} ms',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: iterativeSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: recursiveSpots,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.blue),
                        const SizedBox(width: 5),
                        const Text("Iteratif"),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.orange),
                        const SizedBox(width: 5),
                        const Text("Rekursif"),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = logs.length - 1 - index;
                      final log = logs[reversedIndex];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: log.method == "Iteratif"
                              ? Colors.blue
                              : Colors.orange,
                          child: Text(
                            log.method[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text("${log.method} - Rp ${log.price}"),
                        subtitle: Text(
                          "Steps: ${log.steps} | Time: ${log.timestamp.substring(11, 19)}",
                        ),
                        trailing: Text(
                          "${log.executionTimeUs} ms",
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
