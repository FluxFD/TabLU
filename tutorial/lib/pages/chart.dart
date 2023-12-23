import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  // late Timer _timer;
  List<String> contestantNames = [];
  final io.Socket socket = io.io('http://10.0.2.2:8080', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  @override
  void initState() {
    super.initState();
    chartData = getChartData();
    fetchScoreCards();
    // _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
    //   if (mounted) {
    //     fetchScoreCards();
    //   }
    // });
    socket.connect();
    socket.onConnect((_) {
      print('Socket connected');
      socket.on('chartUpdate', (data) {
        // Handle the updated data and update the chart
        fetchScoreCards();
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });
    // Listen for the 'chartUpdate' event

  }

  @override
  void dispose() {
    // _timer.cancel();  // If you have a timer, you might cancel it here.
    super.dispose();  // Call the superclass dispose method.
    // Disconnect the socket and execute code after disconnection.
      socket.disconnect();
      socket.clearListeners();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Live Scores Update'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                isTransposed: true,
                series: <BarSeries<LiveData, String>>[
                  BarSeries<LiveData, String>(
                    onRendererCreated: (ChartSeriesController controller) {
                      _chartSeriesController = controller;
                    },
                    dataSource: chartData,
                    color: Color.fromARGB(255, 16, 172, 55),
                    xValueMapper: (LiveData sales, _) => sales.name,
                    yValueMapper: (LiveData sales, _) => sales.speed,
                    // Add data labels
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      alignment: ChartAlignment.center,
                    ),
                  )
                ],
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  title: AxisTitle(text: 'Contestants'),
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
                      'Contestant: ${chartData[index].name}, Score: ${chartData[index].speed}',
                      textAlign: TextAlign.center,
                  ),
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
        LiveData(chartData.length, 'New Contestant', (math.Random().nextInt(60) + 30)),
      );
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
    final url = Uri.parse('http://10.0.2.2:8080/winners/$eventId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> contestantData =
        jsonDecode(response.body)['contestants'];
        // print("Contestant Data: ${jsonDecode(response.body)['contestants']}");

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
