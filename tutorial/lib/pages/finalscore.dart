import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

class ScoreCard {
  final String eventId;
  final String contestantName;
  final double score;

  ScoreCard({
    required this.eventId,
    required this.contestantName,
    required this.score,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) {
    return ScoreCard(
      eventId: json['eventId'],
      contestantName: json['contestantName'],
      score: json['score'].toDouble(), // Assuming score is a double in JSON
    );
  }
}

class Winner extends StatefulWidget {
  final String eventId;

  const Winner({required this.eventId, Key? key}) : super(key: key);

  @override
  State<Winner> createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<ScoreCard> scoreCards = [];

  @override
  void initState() {
    super.initState();
    scoreCards = List.generate(
      3,
      (index) => ScoreCard(
        eventId: widget.eventId,
        contestantName: 'Default Name ${index + 1}',
        score: 50.0,
      ),
    );
    fetchScoreCards();
  }

  void showSuccessToast() {
    Fluttertoast.showToast(
      msg: 'Screenshot successful!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> fetchScoreCards() async {
    final eventId = widget.eventId;
    print(eventId);
    final url = Uri.parse('http://localhost:8080/winners/$eventId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          // Clear existing scoreCards and add new ones
          scoreCards = List<ScoreCard>.from(data['contestants'].map((item) {
            return ScoreCard(
              eventId: eventId,
              contestantName: item['name'],
              score: item['averageScore'].toDouble(),
            );
          }));

          // Sort scoreCards by score in descending order
          scoreCards.sort((a, b) => b.score.compareTo(a.score));

          // Debugging: Print the size of the scoreCards list
          print('ScoreCards size: ${scoreCards.length}');

          for (var scorecard in scoreCards) {
            print(scorecard.contestantName);
          }
        });
      } else {
        print(
            'Failed to fetch scorecards. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching scorecards: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Score Ranking',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF054E07),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Uint8List? imageBytes = await screenshotController.capture();
              showSuccessToast();
            },
            icon: Icon(Icons.camera),
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  child: Center(
                      child: Image.asset(
                    'assets/icons/trophy.png',
                    height: 300,
                    width: 300,
                  )),
                ),
              ),
              const Text(
                'Congratulation to the Winners!',
                style: TextStyle(
                    color: Color(0xFF054E07),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 75, right: 25, top: 25),
                child: Column(
                  children: [
                    Container(
                      child: Center(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/1st.png',
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            Text(scoreCards[0].contestantName),
                            const SizedBox(
                              width: 25,
                            ),
                            Text("${scoreCards[0].score.toString()} %"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Center(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/2nd.png',
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            Text(scoreCards[1].contestantName),
                            const SizedBox(
                              width: 25,
                            ),
                            Text("${scoreCards[1].score.toString()} %"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Center(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/3rd.png',
                              height: 50,
                              width: 50,
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            Text(scoreCards[2].contestantName),
                            const SizedBox(
                              width: 25,
                            ),
                            Text("${scoreCards[2].score.toString()} %"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 5,
                width: 350,
                child: const Divider(
                  color: Colors.black,
                  thickness: 0.5,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'Better luck next time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF054E07),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120, top: 16, bottom: 30),
                child: Container(
                    child: Column(children: [
                  // Display additional contestants dynamically starting from index 2
                  for (var i = 3; i < scoreCards.length; i++)
                    Row(
                      children: [
                        Text(scoreCards[i].contestantName),
                        SizedBox(height: 20, width: 25),
                        Text("${scoreCards[i].score.toString()}%"),
                      ],
                    ),
                ])),
              )
            ],
          ),
        ),
      ),
    );
  }
}
