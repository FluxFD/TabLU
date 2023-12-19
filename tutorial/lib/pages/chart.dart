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
        body: SfCartesianChart(
          series: <ColumnSeries<LiveData, int>>[
            ColumnSeries<LiveData, int>(
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
              dataSource: chartData,
              color: const Color.fromRGBO(192, 108, 132, 1),
              xValueMapper: (LiveData sales, _) => sales.time,
              yValueMapper: (LiveData sales, _) => sales.speed,
            )
          ],
          primaryXAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 3,
            title: AxisTitle(text: 'Time (seconds)'),
          ),
          primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            title: AxisTitle(text: 'Live Score'),
          ),
          annotations: <CartesianChartAnnotation>[
            for (int i = 0; i < chartData.length; i++)
              CartesianChartAnnotation(
                widget: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    chartData[i].speed.toStringAsFixed(2),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                region: AnnotationRegion.chart,
                x: chartData[i].time.toDouble(),
                y: chartData[i].speed.toDouble(),
              ),
          ],
        ),
      ),
    );
  }

  int time = 19;

  void updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
      addedDataIndex: chartData.length - 1,
      removedDataIndex: 0,
    );
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 42),
      LiveData(1, 47),
      LiveData(2, 43),
    ];
  }

  Future<void> fetchScoreCards() async {
    final eventId = widget.eventId;
    final url = Uri.parse('http://localhost:8080/winners/$eventId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            chartData = List<LiveData>.from(data['contestants'].map((item) {
              return LiveData(
                chartData.length,
                item['averageScore'].toDouble(),
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
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}
