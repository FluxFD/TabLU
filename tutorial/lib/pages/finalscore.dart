import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tutorial/pages/judgescoresheet.dart';

import 'criteria.dart';

class EventData {
  final String eventName;
  final String eventOrganizer;
  final DateTime eventStartDate;
  final String eventStartTime;
  final List<Criteria> criterias;
  final List<aJudge> judges;

  EventData({
    required this.eventName,
    required this.eventOrganizer,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.criterias,
    required this.judges,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventName: json['eventName'],
      eventOrganizer: json['eventOrganizer'],
      eventStartDate: DateTime.parse(json['eventStartDate']),
      eventStartTime: json['eventStartTime'],
      criterias: List<Criteria>.from(
          json['criterias'].map((criteria) => Criteria.fromJson(criteria))),
      judges: List<aJudge>.from(
          json['judges'].map((judge) => aJudge.fromJson(judge))),
    );
  }
}

class Criteria {
  final String criteriaName;
  final bool isSpecialAwards;
  final double criteriaPercentage;
  final List<dynamic> subCriteriaList;

  Criteria({
    required this.criteriaName,
    required this.isSpecialAwards,
    required this.criteriaPercentage,
    required this.subCriteriaList,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    var subCriteriaJsonList = json['subCriteriaList'] ?? [];
    var parsedSubCriteriaList = subCriteriaJsonList
        .map((subJson) => SubCriteria.fromJson(subJson))
        .toList();

    return Criteria(
      criteriaName: json['criteriaName'] ?? "",
      isSpecialAwards: json['isSpecialAwards'],
      criteriaPercentage:
          double.parse(json['criteriaPercentage'].toString()) ?? 0,
      subCriteriaList: parsedSubCriteriaList,
    );
  }
}

class PageantScoreCard {
  final String criteriaId;
  final String criteriaName;
  final List<TopContestant> topThreeContestants;

  PageantScoreCard({
    required this.criteriaId,
    required this.criteriaName,
    required this.topThreeContestants,
  });

  factory PageantScoreCard.fromJson(Map<String, dynamic> json) {
    List<dynamic> contestantsJson = json['topThreeContestants'];
    List<TopContestant> contestants = contestantsJson
        .map((contestantJson) => TopContestant.fromJson(contestantJson))
        .toList();

    return PageantScoreCard(
      criteriaId: json['criteriaId'],
      criteriaName: json['criteriaName'],
      topThreeContestants: contestants,
    );
  }
}

class TopContestant {
  final String contestantId;
  final String contestantName;
  final double score;

  TopContestant({
    required this.contestantId,
    required this.contestantName,
    required this.score,
  });

  factory TopContestant.fromJson(Map<String, dynamic> json) {
    return TopContestant(
      contestantId: json['contestantId'],
      contestantName: json['contestantName'],
      score: json['score'].toDouble(),
    );
  }
}

class aJudge {
  final String judgeName;
  final List<Contestant> contestants;

  aJudge({
    required this.judgeName,
    required this.contestants,
  });

  factory aJudge.fromJson(Map<String, dynamic> json) {
    return aJudge(
      judgeName: json['judgeName'],
      contestants: List<Contestant>.from(json['contestants']
          .map((contestant) => Contestant.fromJson(contestant))),
    );
  }
}

class Contestant {
  final int contestantNumber;
  final String contestantName;
  final String criteriaName;
  final bool isSpecialAwards;
  final double judgeRawScore;
  final double judgeCalculatedScore;

  Contestant({
    required this.contestantNumber,
    required this.contestantName,
    required this.criteriaName,
    required this.isSpecialAwards,
    required this.judgeRawScore,
    required this.judgeCalculatedScore,
  });

  factory Contestant.fromJson(Map<String, dynamic> json) {
    Contestant contestant = Contestant(
      contestantNumber: json['contestantNumber'] ?? 0,
      contestantName: json['contestantName'],
      criteriaName: json['criteriaName'],
      isSpecialAwards: json['isSpecialAwards'],
      judgeRawScore: json['judgeRawScore'].toDouble(),
      judgeCalculatedScore: json['judgeCalculatedScore'].toDouble(),
    );

    // print(contestant.contestantNumber);

    return contestant;
  }
}

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
      score: (json['score'] != null && json['score'] != '')
          ? double.parse(json['score'].toString())
          : 0.0, // Assuming score is a double in JSON
    );
  }
}

class Winner extends StatefulWidget {
  final String eventId;
  final String event_category;

  const Winner({required this.eventId, required this.event_category, Key? key})
      : super(key: key);

  @override
  State<Winner> createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<ScoreCard> scoreCards = [];
  List<PageantScoreCard> pageantScoreCards = [];
  late EventData eventData = EventData(
    eventName: '',
    eventOrganizer: '',
    eventStartDate: DateTime.now(),
    eventStartTime: '',
    criterias: [],
    judges: [],
  );

  bool isLoading = true;

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
    fetchScoreCardsPageants(widget.eventId);
    fetchScoreCards();
  }

  Map<double, Map<String, dynamic>> calculateSortedContestants(
      List<aJudge> judges) {
    List<Contestant> allContestants = [];
    Map<String, dynamic> contestantData = {};

    for (var judge in judges) {
      allContestants.addAll(
          judge.contestants.where((contestant) => !contestant.isSpecialAwards));
    }

    for (Contestant contestant in allContestants) {
      if (!contestantData.containsKey(contestant.contestantName)) {
        contestantData[contestant.contestantName] = {
          'totalScore': contestant.judgeCalculatedScore,
          'count': 1
        };
      } else {
        contestantData[contestant.contestantName]['totalScore'] +=
            contestant.judgeCalculatedScore;
        contestantData[contestant.contestantName]['count'] += 1;
      }
    }

    List<Map<String, dynamic>> sortedContestants =
        contestantData.entries.map((entry) {
      return {
        'contestantName': entry.key,
        'score': entry.value['totalScore'] / judges.length
      };
    }).toList();

    sortedContestants.sort((a, b) => b['score'].compareTo(a['score']));

    // Create a new map where the keys are the ranks and the values are the contestant data
    Map<double, Map<String, dynamic>> rankedContestants = {};

    // Add rank to each contestant
    for (int i = 0; i < sortedContestants.length; i++) {
      double rank = i + 1; // Adding 1 because rank starts from 1
      rankedContestants[rank] = sortedContestants[i];
    }

    return rankedContestants;
  }

  String getOrdinal(int index) {
    if (index == 1) {
      return '1st';
    } else if (index == 2) {
      return '2nd';
    } else if (index == 3) {
      return '3rd';
    } else {
      return '$index th';
    }
  }

  List<Map<String, dynamic>> mapScoreCards(List<ScoreCard> scoreCards) {
    return scoreCards.map((scoreCard) {
      double newRank = scoreCard.score / scoreCards.length;
      return {
        "rank": newRank,
        "contestantName": scoreCard.contestantName,
        "score": scoreCard.score,
      };
    }).toList();
  }

  double getCriteriaScore(Contestant contestant, String criteriaName) {
    // Implement this function to return the score for a given criteria.
    // This will depend on how you are storing the scores in the Contestant class.
    return 0.0; // Placeholder return
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
    final url = Uri.parse('https://tabluprod.onrender.com/winners/$eventId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          scoreCards = List<ScoreCard>.from(data['contestants'].map((item) {
            return ScoreCard(
              eventId: eventId,
              contestantName: item['name'],
              score: item['averageScore'].toDouble(),
            );
          }));
          // Sort scoreCards by score in descending order
          scoreCards.sort((a, b) => b.score.compareTo(a.score));

          List<Map<String, dynamic>> rankScores = mapScoreCards(scoreCards);

          // print("eventData ${data['response']['judges']}");
          eventData = EventData.fromJson(data['response']);
          // print("eventData ${eventData.judges[0].contestants[0].contestantNumber}");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Failed to fetch scorecards. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching scorecards: $error');
    }
  }

  void saveScreenshot(Uint8List? imageBytes) async {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/screenshot.png');
    await file.writeAsBytes(imageBytes!);
    showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    Map<double, Map<String, dynamic>> nonPageantOverallScores = {};
    for (int i = 0; i < scoreCards.length; i++) {
      double rank = i + 1.0;
      nonPageantOverallScores[rank] = {
        'score': scoreCards[i].score,
        'contestantName': scoreCards[i].contestantName
      };
    }

    List<Map<double, dynamic>> updatedRankScores =
        calculateUpdatedRankScoresWithContestantName(nonPageantOverallScores);

    print(updatedRankScores);
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
          // IconButton(
          //   onPressed: () async {
          //     Uint8List? imageBytes = await screenshotController.capture();
          //     saveScreenshot(imageBytes);
          //   },
          //   icon: Icon(Icons.camera),
          // ),
          IconButton(
            icon: Icon(Icons.document_scanner),
            onPressed: () async {
              try {
                final String path = await generatePdf(scoreCards, eventData);
                // Navigate to a new screen to view the PDF
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(filePath: path),
                  ),
                );
              } catch (e) {
                // Handle exception
                print('Error generating PDF: $e');
              }
            },
          ),
        ],
      ),
      body: isLoading // Check if it is loading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Screenshot(
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
                    const SizedBox(
                      height: 20,
                    ),
                    (widget.event_category == "Pageants")
                        ? buildScoreCardForPageants()
                        : buildScoreCard(),
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
                    if (widget.event_category != "Pageants")
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
                    if (widget.event_category != "Pageants")
                      Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 30),
                          child: Column(
                            children: updatedRankScores
                                .asMap()
                                .entries
                                .where((entry) => entry.key >= 3)
                                .map((entry) {
                              var scoreData = entry.value;
                              var rank = scoreData.keys.first;
                              var contestantData = scoreData[rank];
                              var contestantName =
                                  contestantData['contestantName'];
                              var score = roundUp(contestantData['score'], 2);

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        rank % 1 == 0
                                            ? rank.toStringAsFixed(0)
                                            : rank.toStringAsFixed(1),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        contestantName,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        "${score.toStringAsFixed(2)}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildScoreCard() {
    Map<double, Map<String, dynamic>> nonPageantOverallScores = {};
    for (int i = 0; i < scoreCards.length; i++) {
      double rank = i + 1.0;
      nonPageantOverallScores[rank] = {
        'score': scoreCards[i].score,
        'contestantName': scoreCards[i].contestantName
      };
    }

    List<Map<double, dynamic>> updatedRankScores =
        calculateUpdatedRankScoresWithContestantName(nonPageantOverallScores);

    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: List.generate(
            3, (index) => buildScoreRow(updatedRankScores, index)),
      ),
    );
  }

  Widget buildScoreRow(
      List<Map<double, dynamic>> updatedRankScores, int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(

                  updatedRankScores.isNotEmpty
                      ? (updatedRankScores[index].keys.toList()[0] % 1 != 0
                      ? roundUp(updatedRankScores[index]
                      .keys
                      .toList()[0], 1)
                      .toStringAsFixed(1)
                      : roundUp(updatedRankScores[index]
                      .keys
                      .toList()[0], 0)
                      .toInt()
                      .toString())
                      : "",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  updatedRankScores.length > 0
                      ? updatedRankScores[index]
                                  [updatedRankScores[index].keys.toList()[0]]
                              ['contestantName']
                          .toString()
                      : "No Scores",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  updatedRankScores.length > 0
                      ? updatedRankScores[index]
                                  [updatedRankScores[index].keys.toList()[0]]
                              ['score']
                          .toStringAsFixed(2)
                      : "",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget buildScoreCardForPageants() {
    Map<double, Map<String, dynamic>> sortedContestants = {};
    if (eventData.judges.isNotEmpty) {
      sortedContestants = calculateSortedContestants(eventData.judges);
      List<Map<double, dynamic>> updatedRankScores =
          calculateUpdatedRankScoresWithContestantName(sortedContestants);

      List<Widget> winnerWidgets = [];
      List<Widget> criteriaWidgets = [];

      for (var i = 0; i < updatedRankScores.length; i++) {
        double rank = updatedRankScores[i].keys.first;
        String contestantName = updatedRankScores[i][rank]['contestantName'];
        double averageScore = roundUp(updatedRankScores[i][rank]['score'], 2);
        winnerWidgets.add(
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        rank % 1 == 0
                            ? rank.toStringAsFixed(0)
                            : rank.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        contestantName,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        averageScore.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      }

      Map<double, Map<String, dynamic>> allConvertedContestants = {};

      for (int i = 0; i < pageantScoreCards.length; i++) {
        final scoreCard = pageantScoreCards[i];
        Map<double, Map<String, dynamic>> convertedContestants =
            convertTopContestantsToMap(scoreCard.topThreeContestants);
        allConvertedContestants.addAll(convertedContestants);
        List<Map<double, dynamic>> individualCriteriaRankings =
            calculateUpdatedRankScoresWithContestantName(
                allConvertedContestants);

        criteriaWidgets.add(
          Column(
            children: [
              Text(
                "${scoreCard.criteriaName}",
                style: TextStyle(
                    color: Color(0xFF054E07),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );

        for (Map<double, dynamic> contestant in individualCriteriaRankings) {
          double rank = contestant.keys.first;
          Map<String, dynamic> contestantDetails = contestant[rank];

          criteriaWidgets.add(
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          rank % 1 == 0
                              ? rank.toStringAsFixed(0)
                              : rank.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          contestantDetails['contestantName'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          roundUp(contestantDetails['score'], 2).toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        }
      }

      return Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
        child: Center(
          child: Column(
            children: [
              Text(
                "OVERALL WINNERS",
                style: TextStyle(
                    color: Color(0xFF054E07),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              ...winnerWidgets,
              const SizedBox(height: 20),
              ...criteriaWidgets,
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  String _getOrdinal(int index, List<TopContestant> contestants) {
    return "${index + 1}${_getSuffix(index + 1)}";
  }

  String _getSuffix(int number) {
    switch (number) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  String _getOrdinalForImage(int index) {
    if (index == 0) {
      return "1st";
    } else if (index == 1) {
      return "2nd";
    } else {
      return "3rd";
    }
  }

  Future<void> fetchScoreCardsPageants(String eventId) async {
    try {
      final response = await http.get(
          Uri.parse('https://tabluprod.onrender.com/winners-pageants/$eventId'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // Map each score card data to create instances of PageantScoreCard
          pageantScoreCards = data.map((item) {
            return PageantScoreCard(
              criteriaId: item['criteriaId'],
              criteriaName: item['criteriaName'],
              topThreeContestants: List<TopContestant>.from(
                  item['topThreeContestants'].map((contestantJson) =>
                      TopContestant.fromJson(contestantJson))),
            );
          }).toList();



          isLoading = false; // Set loading to false when data is fetched
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch score cards');
      }
    } catch (error) {
      // Handle errors here
      print(error);
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  Future<double> drawLogoAndEventDetails(
      PdfGraphics graphics, EventData eventData, PdfPage page) async {
    // Load the logo image
    final ByteData data = await rootBundle.load('assets/icons/tablut222.png');
    final Uint8List bytesData =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final PdfBitmap image = PdfBitmap(bytesData);

    // Draw the logo at top-left
    const double logoWidth = 100;
    const double logoHeight = 70;
    graphics.drawImage(image, Rect.fromLTWH(0, 0, logoWidth, logoHeight));

    final PdfFont eventDetailsFont =
        PdfStandardFont(PdfFontFamily.helvetica, 14);
    String eventDetails =
        'Event name: ${eventData.eventName}\nDate: ${eventData.eventStartDate.toString().split(' ')[0]}\nTime: ${eventData.eventStartTime}';
    Size eventDetailsSize = eventDetailsFont.measureString(eventDetails);
    graphics.drawString(eventDetails, eventDetailsFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, logoHeight, page.getClientSize().width,
            eventDetailsSize.height));
    return eventDetailsSize.height + 80; // Adjust spacing after event details
  }

  void updateOverallScoreRow(
      List<Map<double, double>> updatedRankScores, PdfGrid overAllScoreGrid) {
    for (var i = 0; i < updatedRankScores.length; i++) {
      var data = updatedRankScores[i];
      var overAllScoreRow = overAllScoreGrid.rows[i];
      if (data.keys.first % 1 == 0) {
        overAllScoreRow.cells[overAllScoreRow.cells.count - 1].value =
            data.keys.first.toStringAsFixed(0);
      } else {
        overAllScoreRow.cells[overAllScoreRow.cells.count - 1].value =
            data.keys.first.toStringAsFixed(1);
      }
    }
  }

  List<Map<double, double>> calculateUpdatedRankScores(
      Map<double, Map<String, dynamic>> rankScores) {
    Map<double, List<double>> scoreRanks = {};
    for (var entry in rankScores.entries) {
      if (!scoreRanks.containsKey(entry.value['score'])) {
        scoreRanks[entry.value['score']] = [entry.key];
      } else {
        scoreRanks[entry.value['score']]!.add(entry.key);
      }
    }

    List<Map<double, double>> updatedRankScores = [];
    for (var entry in scoreRanks.entries) {
      double newRank = entry.value.reduce((a, b) => a + b) / entry.value.length;
      for (var i = 0; i < entry.value.length; i++) {
        updatedRankScores.add({newRank: entry.key});
      }
    }
    return updatedRankScores;
  }

  List<Map<double, dynamic>> calculateUpdatedRankScoresWithContestantName(
      Map<double, Map<String, dynamic>> rankScores) {
    Map<double, List<double>> scoreRanks = {};
    for (var entry in rankScores.entries) {
      if (!scoreRanks.containsKey(entry.value['score'])) {
        scoreRanks[entry.value['score']] = [entry.key];
      } else {
        scoreRanks[entry.value['score']]!.add(entry.key);
      }
    }
    // print("scoreRanks $scoreRanks");
    List<Map<double, dynamic>> updatedRankScores = [];
    for (var entry in scoreRanks.entries) {
      double newRank = entry.value.reduce((a, b) => a + b) / entry.value.length;
      for (var i = 0; i < entry.value.length; i++) {
        updatedRankScores.add({
          newRank: {
            'score': entry.key,
            'contestantName': rankScores[entry.value[i]]!['contestantName']
          }
        });
      }
    }
    // print("updatedRankScores $updatedRankScores");
    return updatedRankScores;
  }

  Map<double, Map<String, dynamic>> convertTopContestantsToMap(
      List<TopContestant> topContestants) {
    Map<double, Map<String, dynamic>> result = {};
    for (int i = 0; i < topContestants.length; i++) {
      result[i + 1.0] = {
        'contestantName': topContestants[i].contestantName,
        'score': topContestants[i].score,
      };
    }
    return result;
  }

  void drawEventOrganizer(PdfGraphics newPageGraphics, String organizerName,
      PdfFont fontStyle, PdfFont judgesStyle, double contentYPosition) {
    // Draw the event organizer string on the current page
    newPageGraphics.drawString("Event Organizer", fontStyle,
        bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));

    // Adjust the Y position for the next content
    contentYPosition += 40;

    // Draw the event organizer string on the current page
    newPageGraphics.drawString(organizerName, judgesStyle,
        bounds: Rect.fromLTWH(
          0,
          contentYPosition,
          0,
          0,
        ));
  }

  double roundUp(double number, int places) {
    if (number == null || places == null) {
      throw ArgumentError('Both arguments must not be null');
    }

    double factor = pow(10, places).toDouble();
    double rounded = double.parse((number * factor).toStringAsFixed(1));
    num round = rounded.round();
    return round / factor;

  }

  Future<String> generatePdf(
      List<ScoreCard> scoreCards, EventData eventData) async {
    // Request storage permission (make sure to handle permissions)

    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    // Add a page to the document
    PdfPage page = document.pages.add();
    // Get page graphics for the page
    PdfGraphics graphics = page.graphics;

    // Create a font for the title
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18);

    // Create a list of unique judge names
    List<String> judgeNames =
        eventData.judges.map((judge) => judge.judgeName).toList();

    // Draw the main title centered
    final String title = 'Score Rankings';
    final Size titleSize = titleFont.measureString(title);
    final double titleStart =
        (page.getClientSize().width - titleSize.width) / 2;
    graphics.drawString(title, titleFont,
        bounds:
            Rect.fromLTWH(titleStart, 0, titleSize.width, titleSize.height));

    // Adjust the Y position for drawing the content below the title
    double contentYPosition =
        titleSize.height + 50; // Adjust this value as needed

    contentYPosition = await drawLogoAndEventDetails(graphics, eventData, page);

    if (widget.event_category == "Pageants") {
      // Create a font for the content

      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

      // Draw the text "OVERALL WINNER"
      graphics.drawString(
        "Overall Winner",
        titleFont,
        bounds:
            Rect.fromLTWH(0, contentYPosition, page.getClientSize().width, 50),
      );

      // Adjust the Y position for the next content
      contentYPosition += 20;

      Map<double, Map<String, dynamic>> sortedContestants =
          calculateSortedContestants(eventData.judges);
      List<Map<double, dynamic>> updatedRankScores =
          calculateUpdatedRankScoresWithContestantName(sortedContestants);

      for (int i = 0; i < updatedRankScores.length; i++) {
        var contestant = updatedRankScores[i];
        double rank = contestant.keys.first;
        String contestantName = contestant[rank]['contestantName'];
        double score = roundUp(contestant[rank]['score'], 2);


        // Draw the rank
        graphics.drawString(
          rank % 1 == 0 ? rank.toStringAsFixed(0) : rank.toStringAsFixed(1),
          contentFont,
          bounds: Rect.fromLTWH(25, contentYPosition, 300, 20),
        );

        // Draw the contestant name
        graphics.drawString(
          contestantName,
          contentFont,
          bounds: Rect.fromLTWH(
              50, contentYPosition, 300, 20), // Adjust the left position
        );

        // Draw the contestant score
        graphics.drawString(
          score.toStringAsFixed(2),
          contentFont,
          bounds: Rect.fromLTWH(
              325, contentYPosition, 100, 20), // Adjust the left position
        );

        // Adjust the Y position for the next contestant
        contentYPosition += 10; // Increase the vertical spacing
      }
      contentYPosition += 20;

      Map<double, Map<String, dynamic>> allConvertedContestants = {};

      for (int i = 0; i < pageantScoreCards.length; i++) {
        final scoreCard = pageantScoreCards[i];
        // Check if drawing this scoreCard will exceed the available space
        double requiredHeight = 30 +
            (scoreCard.topThreeContestants.length * 30) +
            80; // Height of criteria name + contestant details + spacing between criteria
        if (contentYPosition + requiredHeight > page.getClientSize().height) {
          // If drawing this scoreCard would exceed the available space, start a new page
          document.pages.add(); // Add a new page
          page = document
              .pages[document.pages.count - 1]; // Switch to the new page
          graphics = page.graphics; // Update graphics object
          contentYPosition = 0; // Reset contentYPosition for the new page
        }
        // Draw criteria name
        graphics.drawString(
          scoreCard.criteriaName,
          titleFont,
          bounds: Rect.fromLTWH(
              0, contentYPosition, page.getClientSize().width, 50),
        );
        contentYPosition += 30; // Adjust vertical spacing
        Map<double, Map<String, dynamic>> convertedContestants =
            convertTopContestantsToMap(scoreCard.topThreeContestants);
        allConvertedContestants.addAll(convertedContestants);
        List<Map<double, dynamic>> individualCriteriaRankings =
            calculateUpdatedRankScoresWithContestantName(
                allConvertedContestants);
        // Iterate over the map
        for (Map<double, dynamic> contestant in individualCriteriaRankings) {
          double rank = contestant.keys.first;
          Map<String, dynamic> contestantDetails = contestant[rank];
          // Draw the rank
          graphics.drawString(
            rank % 1 == 0 ? rank.toStringAsFixed(0) : rank.toStringAsFixed(1),
            contentFont,
            bounds: Rect.fromLTWH(25, contentYPosition, 300, 20),
          );

          // Draw the contestant name
          graphics.drawString(
            contestantDetails['contestantName'],
            contentFont,
            bounds: Rect.fromLTWH(
                50, contentYPosition, 300, 20), // Adjust the left position
          );

          double contestantScore = contestantDetails['score'];
          // Draw the contestant score
          graphics.drawString(
            (roundUp(contestantScore, 2).toStringAsFixed(2)),
            contentFont,
            bounds: Rect.fromLTWH(
                325, contentYPosition, 100, 20), // Adjust the left position
          );

          // Adjust the Y position for the next contestant
          contentYPosition += 10; // Adjust vertical spacing
        }

        contentYPosition += 10; // Adjust spacing between criteria
      }
    } else {
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

      Map<double, Map<String, dynamic>> nonPageantOverallScores = {};
      for (int i = 0; i < scoreCards.length; i++) {
        double rank = i + 1.0;
        nonPageantOverallScores[rank] = {
          'score': scoreCards[i].score,
          'contestantName': scoreCards[i].contestantName
        };
      }

      List<Map<double, dynamic>> updatedRankScores =
          calculateUpdatedRankScoresWithContestantName(nonPageantOverallScores);

      // print("updatedRankScores: $updatedRankScores");

      // Draw the content with rankings for the first three contestants
      for (int i = 0; i < updatedRankScores.length; i++) {
        var updatedRankScore = updatedRankScores[i];
        double rank = updatedRankScore.keys.first;
        Map<String, dynamic> contestantDetails = updatedRankScore[rank];
        String contestantName = contestantDetails['contestantName'];
        double score = roundUp(contestantDetails['score'], 2);

        // Line to be drawn on the PDF
        String line =
            '${rank % 1 == 0 ? rank.toStringAsFixed(0) : rank.toStringAsFixed(1)}   $contestantName   ${score.toStringAsFixed(2)}';
        graphics.drawString(line, contentFont,
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(
                0, contentYPosition, page.getClientSize().width, 20));
        contentYPosition += 20; // Adjust line spacing
      }
    }

    PdfFont fontStyles =
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    PdfFont judgeFont = PdfStandardFont(PdfFontFamily.helvetica, 14);
    Size judgesTextSize = fontStyles.measureString("Judges");
    PdfFont fontStyle =
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    PdfFont judgesStyle = PdfStandardFont(PdfFontFamily.helvetica, 14);

    contentYPosition += 20;
    graphics.drawString("Judges", fontStyle,
        bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));
    contentYPosition += judgesTextSize.height + 20;

    // New code to display all judge names
    Size judgeNameSize = Size.zero;
    double contentXPosition = 0;

    for (String judgeName in judgeNames) {
      judgeNameSize = judgesStyle.measureString(judgeName);
      graphics.drawString(judgeName, judgesStyle,
          bounds: Rect.fromLTWH(contentXPosition, contentYPosition, 0, 0));
      contentXPosition += judgeNameSize.width + 160;

      // Adjust the Y position for the next judge name
      if (contentXPosition + judgeNameSize.width > page.getClientSize().width) {
        // If it would, move to the next line and reset contentXPosition
        contentYPosition += judgeNameSize.height +
            20; // Adjust the Y position for the next line
        contentXPosition = 0; // Reset the X position for the next line
      }
    }

    drawEventOrganizer(graphics, eventData.eventOrganizer, fontStyles,
        judgeFont, contentYPosition + 20);

    Map<String, PdfGridRow> judgeContestantMap = {};
    // Add data to the table
    // Populate data in the grid
    for (var judge in eventData.judges) {
      // Create a PDF grid and add the headers
      final PdfGrid grid = PdfGrid();

      grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 10),
        cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      );
      contentYPosition += 50;
      // Add column headers
      grid.columns.add(
          count: widget.event_category == 'Pageants'
              ? 2 + eventData.criterias.length
              : 3 + eventData.criterias.length);
      PdfGridRow header = grid.headers.add(1)[0];
      // header.cells[0].value = 'Judge';
      header.cells[0].value = 'Candidate #';
      header.cells[1].value = 'Candidate Name';
      // Add criteria names as headers
      for (int i = 0; i < eventData.criterias.length; i++) {
        // header.cells[2 + i * 2].value =
        //     "Criteria\n " + eventData.criterias[i].criteriaName;
        header.cells[2 + i].value =
            '${eventData.criterias[i].criteriaName} (${eventData.criterias[i].criteriaPercentage}%)';
      }
      if (widget.event_category != 'Pageants') {
        header.cells[header.cells.count - 1].value = 'Total';
      }

      page = document.pages.add();

      contentYPosition = 0; // Reset contentYPosition for the new page
      double totalScore = 0.0; // Initialize total score for each contestant
      for (var contestant in judge.contestants) {
        String key = '${judge.judgeName}_${contestant.contestantName}';
        PdfGridRow? row;

        if (judgeContestantMap.containsKey(key)) {
          // Update existing row
          row = judgeContestantMap[key];
        } else {
          // Add new row and store it in the map
          row = grid.rows.add();
          judgeContestantMap[key] = row;
          row.cells[0].value = contestant.contestantNumber.toString();
          row.cells[1].value = contestant.contestantName;
          totalScore = 0;
        }

        // Fill or update criteria scores
        for (int i = 0; i < eventData.criterias.length; i++) {
          if (contestant.criteriaName == eventData.criterias[i].criteriaName) {
            row?.cells[2 + i].value =
                contestant.judgeCalculatedScore.toStringAsFixed(2);
            totalScore += contestant.judgeCalculatedScore;
          }
        }

        if (widget.event_category != 'Pageants') {
          row?.cells[row.cells.count - 1].value = totalScore.toStringAsFixed(2);
        }
      }
      PdfGraphics graphics = page.graphics;

      contentYPosition =
          await drawLogoAndEventDetails(graphics, eventData, page);

      // Draw the grid on the current page
      final PdfLayoutResult? gridResult = grid.draw(
          page: page, bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));
      contentYPosition = gridResult!.bounds.bottom + 30;

      // Add a row for the judge's name
      PdfFont fontStyle = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.bold);
      PdfFont judgeFont = PdfStandardFont(PdfFontFamily.helvetica, 14);
      String judgeText = "Judge";
      String judgeName = judge.judgeName;
      Size judgeTextSize = judgeFont.measureString(judgeText);

// Get the graphics of the current page

// Draw the string on the current page
      graphics.drawString(judgeText, fontStyle,
          bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));
      contentYPosition += 40;
      graphics.drawString(judgeName, judgeFont,
          bounds: Rect.fromLTWH(0, contentYPosition, 0, judgeTextSize.height));
      contentYPosition += 20;
      drawEventOrganizer(graphics, eventData.eventOrganizer, fontStyle,
          judgeFont, contentYPosition + 20);
    }



    Map<String, Map<String, double>> overAllNotPageant = {};
    for (var judge in eventData.judges) {
      double totalScore = 0.0;
      for (var contestant in judge.contestants) {
        String key =
            '${contestant.contestantNumber}_${contestant.contestantName}';
        if (overAllNotPageant.containsKey(key)) {
          totalScore = overAllNotPageant[key]![judge.judgeName] ?? 0.0;
        } else {
          totalScore = 0.0;
        }
        for (int i = 0; i < eventData.criterias.length; i++) {
          if (contestant.criteriaName == eventData.criterias[i].criteriaName) {
            totalScore += contestant.judgeCalculatedScore;
          }
        }
        overAllNotPageant[key] = overAllNotPageant[key] ?? {};
        overAllNotPageant[key]![judge.judgeName] = totalScore;
      }
    }
    //Over All Scores for Non Pageant
    // Create a new PDF grid
    final PdfGrid newGrid = PdfGrid();

    // Set the style for the grid
    newGrid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5),
    );

    // Add the required number of columns to the grid
    newGrid.columns.add(count: 4 + judgeNames.length);

    // Add a header row to the grid
    PdfGridRow newHeader = newGrid.headers.add(1)[0];

    // Set the values for the cells in the header row
    newHeader.cells[0].value = 'Contestant #';
    newHeader.cells[1].value = 'Contestant Name';

    // Add judge names as headers
    for (int i = 0; i < judgeNames.length; i++) {
      newHeader.cells[2 + i].value = judgeNames[i];
    }

    newHeader.cells[newHeader.cells.count - 2].value = 'Average';
    newHeader.cells[newHeader.cells.count - 1].value = 'Rank';

    // Iterate over the overAllNotPageant map
    // Create a list of maps where each map represents a row
    List<Map<String, dynamic>> rows = overAllNotPageant.entries.map((entry) {
      String key = entry.key;
      Map<String, double> judgeScores = entry.value;
      List<String> keyParts = key.split('_');
      String contestantNumber = keyParts[0];
      String contestantName = keyParts[1];

      // Calculate the average score
      double totalScore = judgeScores.values.reduce((a, b) => a + b);
      double averageScore = totalScore / judgeScores.length;

      // Create a map for the row
      Map<String, dynamic> row = {
        'contestantNumber': contestantNumber,
        'contestantName': contestantName,
        'judgeScores': judgeScores,
        'averageScore': averageScore,
      };

      return row;
    }).toList();

// Sort the list based on the average score
    rows.sort((a, b) => b['averageScore'].compareTo(a['averageScore']));

// Iterate over the sorted list and add each map as a row to the newGrid
    for (Map<String, dynamic> rowMap in rows) {
      PdfGridRow row = newGrid.rows.add();
      row.cells[0].value = rowMap['contestantNumber'];
      row.cells[1].value = rowMap['contestantName'];

      // Add scores from each judge
      for (int i = 0; i < judgeNames.length; i++) {
        String judgeName = judgeNames[i];
        double score = rowMap['judgeScores'][judgeName] ?? 0.0;
        row.cells[2 + i].value = score.toStringAsFixed(2);
      }

      // Add the average score
      row.cells[row.cells.count - 2].value =
          rowMap['averageScore'].toStringAsFixed(2);
    }

    // Create a list of average scores
    List<double> averageScores = overAllNotPageant.values.map((judgeScores) {
      double totalScore = judgeScores.values.reduce((a, b) => a + b);
      return totalScore / judgeScores.length;
    }).toList();

    // Sort the list in descending order
    averageScores.sort((a, b) => b.compareTo(a));

    // Iterate over the rows of the newGrid
    Map<double, Map<String, dynamic>> NonPageantRankScores =
    {}; // Initialize an empty map of ranks
    for (int i = 0; i < newGrid.rows.count; i++) {
      // Get the current row
      PdfGridRow row = newGrid.rows[i];
      double averageScore = averageScores[i];
      row.cells[newHeader.cells.count - 2].value =
          averageScore.toStringAsFixed(2);
      row.cells[newHeader.cells.count - 1].value = (i + 1).toString();

      // Get the contestant name from the row
      String contestantName = row.cells[1].value.toString();

      // Store the average score and the contestant in the map
      NonPageantRankScores[i + 1] = {
        'score': averageScore,
        'contestantName': contestantName
      };
    }

    List<Map<double, double>> NonPageantUpdatedRankScores =
    calculateUpdatedRankScores(NonPageantRankScores);
    updateOverallScoreRow(NonPageantUpdatedRankScores, newGrid);



    final PdfGrid overAllScoreGrid = PdfGrid();
    overAllScoreGrid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );
    overAllScoreGrid.columns.add(count: eventData.criterias.length + 4);
    // Add the headers
    PdfGridRow header = overAllScoreGrid.headers.add(1)[0];
    header.cells[0].value = 'Candidate #';
    header.cells[1].value = 'Candidate Name';

// Add criteria names as headers
    for (int i = 0; i < eventData.criterias.length; i++) {
      header.cells[i + 2].value =
      '${eventData.criterias[i].criteriaName} (${eventData.criterias[i].criteriaPercentage}%)';
    }
    header.cells[header.cells.count - 2].value = 'Total';
    header.cells[header.cells.count - 1].value = 'Rank';

    Map<String, Map<String, dynamic>> overAllScoreGroupData = {};

    for (var judge in eventData.judges) {
      for (var contestant in judge.contestants) {
        String key = contestant.contestantNumber.toString();

        if (!overAllScoreGroupData.containsKey(key)) {
          overAllScoreGroupData[key] = {
            'contestantName': contestant.contestantName,
            'criteriaScores': {}
          };
        }

        String criteriaKey = contestant.criteriaName;

        if (!overAllScoreGroupData[key]!['criteriaScores']
            .containsKey(criteriaKey)) {
          overAllScoreGroupData[key]!['criteriaScores']
          [criteriaKey] = {'totalScore': 0.0, 'judgeCount': 0};
        }

        overAllScoreGroupData[key]!['criteriaScores'][criteriaKey]
        ['totalScore'] += contestant.judgeCalculatedScore;
        overAllScoreGroupData[key]!['criteriaScores'][criteriaKey]
        ['judgeCount'] += 1;
      }
    }

    // Calculate the average score for each criteria
    overAllScoreGroupData.forEach((contestantNumber, data) {
      data['criteriaScores'].forEach((criteriaName, scoreData) {
        double totalScore = scoreData['totalScore'];
        int judgeCount = scoreData['judgeCount'];
        double averageScore = totalScore / judgeCount;

        // Replace the score data with the average score
        data['criteriaScores'][criteriaName] = averageScore;
      });
    });

    // Iterate over the overAllScoreGroupData map and add the data to the grid
    // Convert the overAllScoreGroupData map to a list of maps
    List<Map<String, dynamic>> contestantsList =
    overAllScoreGroupData.entries.map((entry) {
      return {
        'contestantNumber': entry.key,
        'contestantName': entry.value['contestantName'],
        'criteriaScores': entry.value['criteriaScores'],
      };
    }).toList();

    // Sort the list based on the total score
    contestantsList.sort((a, b) {
      double totalScoreA = 0.0;
      double totalScoreB = 0.0;
      a['criteriaScores'].forEach((_, score) {
        totalScoreA += score;
      });
      b['criteriaScores'].forEach((_, score) {
        totalScoreB += score;
      });
      return totalScoreB.compareTo(totalScoreA); // Sort in descending order
    });

    PdfGridRow? overAllScoreRow;
    Map<double, Map<String, dynamic>> rankScores =
    {}; // Initialize an empty map of ranks

// Iterate over the sorted list and add the data to the grid
    for (var i = 0; i < contestantsList.length; i++) {
      var data = contestantsList[i];
      overAllScoreRow = overAllScoreGrid.rows.add();
      overAllScoreRow.cells[0].value = data['contestantNumber'];
      overAllScoreRow.cells[1].value = data['contestantName'];

      double totalScore = 0.0; // Initialize total score for each contestant
      // Add the average scores for each criteria
      for (int j = 0; j < eventData.criterias.length; j++) {
        String criteriaName = eventData.criterias[j].criteriaName;
        double averageScore = data['criteriaScores'][criteriaName];
        overAllScoreRow.cells[j + 2].value = averageScore.toStringAsFixed(2);
        if (!eventData.criterias[j].isSpecialAwards) {
          totalScore += averageScore;
        }
      }
      overAllScoreRow.cells[overAllScoreRow.cells.count - 2].value =
          totalScore.toStringAsFixed(2); // Set the total score in the new cell

      // Calculate rank without handling ties
      double rank = i + 1; // Initialize rank as current index + 1
      rankScores[rank] = {
        'score': totalScore,
        'contestantName': data['contestantName']
      };
    }

    print("Rank Scores: $rankScores");
    // Map<double, List<double>> scoreRanks = {};
    // for (var entry in rankScores.entries) {
    //   if (!scoreRanks.containsKey(entry.value)) {
    //     scoreRanks[entry.value] = [entry.key];
    //   } else {
    //     scoreRanks[entry.value]!.add(entry.key);
    //   }
    // }

    List<Map<double, double>> updatedRankScores =
    calculateUpdatedRankScores(rankScores);
    print(updatedRankScores);
    updateOverallScoreRow(updatedRankScores, overAllScoreGrid);

    // Create a new page in the document
    PdfPage newPage = document.pages.add();

    // Get the graphics of the new page
    PdfGraphics newPageGraphics = newPage.graphics;

    String textToAdd = "Overall Scores";
    PdfFont textFont =
    PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    Size textSize = textFont.measureString(textToAdd);
    double textStartX = (newPage.getClientSize().width - textSize.width) / 2;

    contentYPosition = 0;
    newPageGraphics.drawString(textToAdd, textFont,
        bounds: Rect.fromLTWH(
            textStartX, contentYPosition, textSize.width, textSize.height));

    if (widget.event_category == "Pageants") {
// Draw the overAllScoreGrid on the new page
      double contentYYPosition =
      await drawLogoAndEventDetails(newPageGraphics, eventData, newPage);

      // Draw the overAllScoreGrid on the new page
      final PdfLayoutResult? overAllScoreLayoutResult = overAllScoreGrid.draw(
        page: newPage,
        bounds: Rect.fromLTWH(
          0,
          contentYYPosition,
          newPage.getClientSize().width,
          newPage.getClientSize().height,
        ),
      );
      contentYPosition += overAllScoreLayoutResult!.bounds.bottom + 20;
    } else {
      double contentYYPosition =
      await drawLogoAndEventDetails(newPageGraphics, eventData, newPage);

      final PdfLayoutResult? overAllScoreLayoutResult = newGrid.draw(
        page: newPage,
        bounds: Rect.fromLTWH(0, contentYYPosition,
            newPage.getClientSize().width, newPage.getClientSize().height),
      );
      contentYPosition += overAllScoreLayoutResult!.bounds.bottom + 20;
    }

    contentXPosition = 0;
    newPageGraphics.drawString("Judges", fontStyle,
        bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));
    contentYPosition += judgesTextSize.height + 20;

    for (String judgeName in judgeNames) {
      judgeNameSize = judgesStyle.measureString(judgeName);
      newPageGraphics.drawString(judgeName, judgesStyle,
          bounds: Rect.fromLTWH(contentXPosition, contentYPosition, 0, 0));
      contentXPosition += judgeNameSize.width + 120;

      // Adjust the Y position for the next judge name
      if (contentXPosition + judgeNameSize.width > page.getClientSize().width) {
        // If it would, move to the next line and reset contentXPosition
        contentXPosition = 0; // Reset the X position for the next line
        contentYPosition += judgeNameSize.height + 20; // Move to the next line
      }
    }
    contentYPosition += 20;
    // Draw the event organizer string on the current page
    drawEventOrganizer(newPageGraphics, eventData.eventOrganizer, fontStyle,
        judgesStyle, contentYPosition);

    if (widget.event_category == 'Pageants') {
      Map<String, Map<String, Map<String, dynamic>>> groupCriteriaData = {};

      for (var judge in eventData.judges) {
        for (var contestant in judge.contestants) {
          String key = contestant.criteriaName;
          String contestantKey = contestant.contestantNumber.toString();

          if (!groupCriteriaData.containsKey(key)) {
            groupCriteriaData[key] = {};
          }

          if (!groupCriteriaData[key]!.containsKey(contestantKey)) {
            groupCriteriaData[key]![contestantKey] = {
              'contestantName': contestant.contestantName,
              'judges': []
            };
          }

          groupCriteriaData[key]![contestantKey]?['judges'].add({
            'judgeName': judge.judgeName,
            'judgeCalculatedScore': contestant.judgeCalculatedScore,
          });
        }
      }

      for (var criteria in groupCriteriaData.keys) {
        var contestants = groupCriteriaData[criteria];
        // Create a new PDF grid
        // Add a new page to the document
        PdfPage page = document.pages.add();
        // Draw the criteria name
        PdfGraphics graphics = page.graphics;
        contentYPosition =
            await drawLogoAndEventDetails(graphics, eventData, page);

        PdfFont CriteriaTitleStyle = PdfStandardFont(
            PdfFontFamily.helvetica, 20,
            style: PdfFontStyle.bold);
        String criteriaName = criteria;
        Size criteriaNameSize = CriteriaTitleStyle.measureString(criteriaName);
        double startX =
            (page.getClientSize().width - criteriaNameSize.width) / 2;

        // Draw the string on the current page
        graphics.drawString(criteriaName, CriteriaTitleStyle,
            bounds: Rect.fromLTWH(startX, 0, 0, 0));
        contentYPosition = criteriaNameSize.height +
            20; // Adjust the Y position for the content

        final PdfGrid grid = PdfGrid();
        grid.style = PdfGridStyle(
          font: PdfStandardFont(PdfFontFamily.helvetica, 10),
          cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
        );

        // Add the headers
        grid.columns.add(count: judgeNames.length + 4);
        PdfGridRow header = grid.headers.add(1)[0];
        header.cells[0].value = 'Contestant Number';
        header.cells[1].value = 'Contestant Name';
        for (int i = 0; i < judgeNames.length; i++) {
          header.cells[i + 2].value = judgeNames[i];
        }
        header.cells[header.cells.count - 2].value = 'Average';
        header.cells[header.cells.count - 1].value = 'Rank';

        // Get the contestant keys
        List<String> contestantNumbers = contestants!.keys.toList();

// Sort the contestant numbers based on total score
        contestantNumbers.sort((a, b) {
          // Get the total scores for each contestant
          double totalScoreA = 0.0;
          double totalScoreB = 0.0;

          for (int i = 0; i < judgeNames.length; i++) {
            totalScoreA +=
                contestants![a]!['judges'][i]['judgeCalculatedScore'];
            totalScoreB +=
                contestants![b]!['judges'][i]['judgeCalculatedScore'];
          }

          // Sort in descending order based on total score
          return totalScoreB.compareTo(totalScoreA);
        });

        // Iterate over the sorted contestant numbers and add data to the grid
        for (var contestantNumber in contestantNumbers) {
          var data = contestants![contestantNumber];
          PdfGridRow row = grid.rows.add();
          row.cells[0].value = contestantNumber;
          row.cells[1].value = data?['contestantName'];

          // Add the scores for each judge
          double totalScore = 0.0;
          for (int i = 0; i < judgeNames.length; i++) {
            double score = data?['judges'][i]['judgeCalculatedScore'];
            row.cells[i + 2].value = score.toStringAsFixed(2);
            totalScore += score;
          }

          // Calculate average score
          double averageScore = totalScore / judgeNames.length;
          row.cells[row.cells.count - 2].value =
              averageScore.toStringAsFixed(2);

          // Find the index of the contestant in the sorted list to get the rank
          // int rank = contestantNumbers.indexOf(contestantNumber) + 1;
          // row.cells[row.cells.count - 1].value = rank.toString();
        }
        Map<double, Map<String, dynamic>> individualCriteriaContestantRank = {};

        for (var contestantNumber in contestantNumbers) {
          var data = contestants![contestantNumber];

          // Add the scores for each judge
          double totalScore = 0.0;
          for (int i = 0; i < judgeNames.length; i++) {
            double score = data?['judges'][i]['judgeCalculatedScore'];
            totalScore += score;
          }

          // Calculate average score
          double averageScore = totalScore / judgeNames.length;

          // Find the index of the contestant in the sorted list to get the rank
          int rank = contestantNumbers.indexOf(contestantNumber) + 1;

          // Add the contestant's data to the result map
          individualCriteriaContestantRank[rank.toDouble()] = {
            'score': averageScore,
            'contestantName': data?['contestantName'],
          };
        }

        List<Map<double, double>> updatedRankScores =
            calculateUpdatedRankScores(individualCriteriaContestantRank);

        updateOverallScoreRow(updatedRankScores, grid);

        // Draw the grid on the new page
        // Draw the grid on the current page
        final PdfLayoutResult? gridResult = grid.draw(
            page: page, bounds: Rect.fromLTWH(0, contentYPosition + 80, 0, 0));
        contentYPosition = gridResult!.bounds.bottom + 30;

        contentYPosition = gridResult!.bounds.bottom + 30;

        // New code to add "Judges" text
        Size judgesTextSize = CriteriaTitleStyle.measureString("Judges");
        PdfFont fontStyle = PdfStandardFont(PdfFontFamily.helvetica, 14,
            style: PdfFontStyle.bold);
        PdfFont judgesStyle = PdfStandardFont(PdfFontFamily.helvetica, 14);

        graphics.drawString("Judges", fontStyle,
            bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));
        contentYPosition += judgesTextSize.height + 20;

        // New code to display all judge names
        Size judgeNameSize = Size.zero;
        double contentXPosition = 0;

        for (String judgeName in judgeNames) {
          judgeNameSize = judgesStyle.measureString(judgeName);
          graphics.drawString(judgeName, judgesStyle,
              bounds: Rect.fromLTWH(contentXPosition, contentYPosition, 0, 0));
          contentXPosition += judgeNameSize.width + 160;

          // Adjust the Y position for the next judge name
          if (contentXPosition + judgeNameSize.width >
              page.getClientSize().width) {
            // If it would, move to the next line and reset contentXPosition
            contentYPosition +=
                judgeNameSize.height; // Adjust the Y position for the next line
            contentXPosition = 0; // Reset the X position for the next line
          }
        }
        contentYPosition += 20;

        drawEventOrganizer(graphics, eventData.eventOrganizer, fontStyle,
            judgesStyle, contentYPosition);
      }
    }



    // Add another grid with headers and data
    final PdfGrid secondGrid = PdfGrid();
    secondGrid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );
    int columnLength = 0;
    for (int i = 0; i < eventData.criterias.length; i++) {
      var criteria = eventData.criterias[i];
      for (int j = 0; j < criteria.subCriteriaList.length; j++) {
        columnLength++;
      }
    }
    secondGrid.columns.add(count: 2 + columnLength);
    PdfGridRow secondHeader = secondGrid.headers.add(1)[0];
    secondHeader.cells[0].value = 'Criteria Name';
    secondHeader.cells[1].value = 'Calculated Percentage';

    int c = 0;
    // Add headers for subcriteria names
    for (int i = 0; i < eventData.criterias.length; i++) {
      Criteria criteria = eventData.criterias[i];
      for (int j = 0; j < criteria.subCriteriaList.length; j++) {
        // print("Criteriaaa ${criteria.subCriteriaList[j].subCriteriaName}");
        secondHeader.cells[2 + c].value =
            'Subcriteria \n ${criteria.subCriteriaList[j].subCriteriaName}';
        c++;
      }
    }

    c = 0;
    for (int i = 0; i < eventData.criterias.length; i++) {
      PdfGridRow dataRow = secondGrid.rows.add();
      dataRow.cells[0].value = eventData.criterias[i].criteriaName;
      dataRow.cells[1].value =
          '(${eventData.criterias[i].criteriaPercentage}%)';

      var criteria = eventData.criterias[i];
      for (int j = 0; j < criteria.subCriteriaList.length; j++) {
        dataRow.cells[2 + c].value =
            '${criteria.subCriteriaList[j].percentage}%';
        c++;
      }
    }

    final PdfPage secondPage = document.pages.add();
    PdfGraphics secondGraphics = secondPage.graphics;
    contentYPosition =
        await drawLogoAndEventDetails(secondGraphics, eventData, secondPage);

    PdfLayoutResult? secondGridResult = secondGrid.draw(
        page: secondPage,
        bounds: Rect.fromLTWH(
            0,
            contentYPosition,
            secondPage.getClientSize().width,
            secondPage.getClientSize().height));

    contentYPosition = secondGridResult!.bounds.bottom;

    // Save the document
    List<int> documentBytes = await document.save();
    // Dispose the document
    document.dispose();

    // Get the external storage directory
    final Directory directory = await getApplicationDocumentsDirectory();
    // Get the file path
    final String path = directory.path + '/${widget.eventId}.pdf';
    // Write as a file
    final File file = File(path);
    await file.writeAsBytes(documentBytes);

    return path;
  }
}

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  const PdfViewerPage({Key? key, required this.filePath}) : super(key: key);

  void _downloadAndSharePdf() async {
    try {
      final XFile path = XFile(filePath);
      Share.shareXFiles([path], text: 'Here is the PDF file.');
    } catch (e) {
      // Handle exception
      print('Error in generating/sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          // Other actions...
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadAndSharePdf,
          ),
        ],
      ),
      body: SfPdfViewer.file(File(filePath)),
    );
  }
}
