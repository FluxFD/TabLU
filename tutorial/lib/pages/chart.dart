import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChartData extends StatefulWidget {
  ChartData({
    Key? key,
    required this.title,
    required this.eventId,
    required Map eventData,
    required List judges,
  }) : super(key: key);

  final String title;
  final String eventId;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ChartData> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  late Timer _timer;

  @override
  void initState() {
    chartData = getChartData();
    fetchScoreCards();
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        fetchScoreCards();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                series: <BarSeries<LiveData, int>>[
                  BarSeries<LiveData, int>(
                    onRendererCreated: (ChartSeriesController controller) {
                      _chartSeriesController = controller;
                    },
                    dataSource: chartData,
                    color: Color.fromARGB(255, 16, 172, 55),
                    xValueMapper: (LiveData sales, _) => sales.time,
                    yValueMapper: (LiveData sales, _) => sales.speed,
                  )
                ],
                primaryXAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1, // Set the interval according to your data
                  title: AxisTitle(text: 'Data Points'),
                ),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  title: AxisTitle(text: 'Live Score'),
                ),
              ),
            ),
            // Display the fetched data in a ListView for testing
            Expanded(
              child: ListView.builder(
                itemCount: chartData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        'Contestant: ${chartData[index].name}, Score: ${chartData[index].speed}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int time = 19;

  void updateDataSource(Timer timer) {
    setState(() {
      chartData.add(
          LiveData(time++, 'New Contestant', (math.Random().nextInt(60) + 30)));
      chartData.removeAt(0);

      // Update the x-values of the remaining data points
      for (int i = 0; i < chartData.length; i++) {
        chartData[i] = LiveData(i, chartData[i].name, chartData[i].speed);
      }

      _chartSeriesController.updateDataSource();
    });
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 'Contestant 1', 42),
      LiveData(1, 'Contestant 2', 47),
      LiveData(2, 'Contestant 3', 43),
    ];
  }

  Future<void> fetchScoreCards() async {
    final eventId = widget.eventId;
    final url = Uri.parse('http://localhost:8080/winners/$eventId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> contestantData =
            jsonDecode(response.body)['contestants'];

        if (mounted) {
          setState(() {
            chartData =
                List<LiveData>.from(contestantData.asMap().entries.map((entry) {
              return LiveData(
                entry.key,
                entry.value['name'].toString(),
                entry.value['averageScore'].toDouble(),
              );
            }));

            chartData.sort((a, b) => b.speed.compareTo(a.speed));
          });
        }
      } else {
        print(
            'Failed to fetch scorecards. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching scorecards: $error');
    }
  }
}

class LiveData {
  LiveData(this.time, this.name, this.speed);
  final int time;
  final String name;
  final num speed;
}
