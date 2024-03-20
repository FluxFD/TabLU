import 'dart:convert';
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

import 'criteria.dart';

class EventData {
  final String eventName;
  final DateTime eventStartDate;
  final String eventStartTime;
  final List<Criteria> criterias;
  final List<aJudge> judges;

  EventData({
    required this.eventName,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.criterias,
    required this.judges,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventName: json['eventName'],
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
  final double criteriaPercentage;
  final List<dynamic> subCriteriaList;

  Criteria({
    required this.criteriaName,
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
  final String contestantName;
  final String criteriaName;
  final double judgeRawScore;
  final double judgeCalculatedScore;

  Contestant({
    required this.contestantName,
    required this.criteriaName,
    required this.judgeRawScore,
    required this.judgeCalculatedScore,
  });

  factory Contestant.fromJson(Map<String, dynamic> json) {
    return Contestant(
      contestantName: json['contestantName'],
      criteriaName: json['criteriaName'],
      judgeRawScore: json['judgeRawScore'].toDouble(),
      judgeCalculatedScore: json['judgeCalculatedScore'].toDouble(),
    );
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
  late EventData eventData;
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
    final url = Uri.parse('https://tab-lu.onrender.com/winners/$eventId');

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

          print('ScoreCards size: ${scoreCards}');

          for (var scorecard in scoreCards) {
            print(scorecard.score);
          }
          print("eventData ${data['response']}");
          eventData = EventData.fromJson(data['response']);

          // Now, eventData contains all the information needed for PDF generation
          // print('Event Name: ${eventData.eventName}');
          // print('Start Date: ${eventData.eventStartDate}');
          // print('Start Time: ${eventData.eventStartTime}');
          // print('Criterias: ${eventData.criterias}');
          // print('Judges: ${eventData.judges}');

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
                      child: Container(
                          child: Column(
                            children: [
                              // Display additional contestants dynamically starting from index 2
                              for (var i = 3; i < scoreCards.length; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(scoreCards[i].contestantName),
                                    SizedBox(height: 20, width: 25),
                                    Text("${scoreCards[i].score.toString()}%"),
                                  ],
                                ),
                            ],
                          ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildScoreCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Center(
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/1st.png',
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 25),
                  Text(scoreCards.length > 0
                      ? scoreCards[0].contestantName
                      : "No Scores"),
                  const SizedBox(width: 25),
                  Text(scoreCards.length > 0
                      ? scoreCards[0].score.toStringAsFixed(2)
                      : ""),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/2nd.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 25),
                    Text(scoreCards.length > 1
                        ? scoreCards[1].contestantName
                        : "No Scores"),
                    const SizedBox(width: 25),
                    Text(scoreCards.length > 1
                        ? scoreCards[1].score.toStringAsFixed(2)
                        : ""),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/3rd.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 25),
                    Text(scoreCards.length > 2
                        ? scoreCards[2].contestantName
                        : "No Scores"),
                    const SizedBox(width: 25),
                    Text(scoreCards.length > 2
                        ? scoreCards[2].score.toStringAsFixed(2)
                        : ""),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScoreCardForPageants() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Center(
        // Center widget added here
        child: Column(
          children: [
            for (int i = 0; i < pageantScoreCards.length; i++)
              Container(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center crossAxisAlignment
                  children: [
                    Text(
                      "${pageantScoreCards[i].criteriaName}",
                      style: TextStyle(
                          color: Color(0xFF054E07),
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    // Contestant and score details
                    for (int j = 0;
                        j < pageantScoreCards[i].topThreeContestants.length;
                        j++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center mainAxisAlignment
                        children: [
                          Image.asset(
                            'assets/icons/${_getOrdinalForImage(j)}.png', // Adjusted the index to start from 1
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${_getOrdinal(j, pageantScoreCards[i].topThreeContestants)} ${pageantScoreCards[i].topThreeContestants[j].contestantName}",
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${pageantScoreCards[i].topThreeContestants[j].score.toStringAsFixed(2)}",
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getOrdinal(int index, List<TopContestant> contestants) {
      if (index == 0 || contestants[index].score != contestants[index - 1].score) {
        // Return "1st", "2nd", or "3rd" if it's the highest score or not tied with the previous
        return "${index + 1}${_getSuffix(index + 1)}";
      } else {
        // If tied with the previous, return "Tie"
        return "${3}${_getSuffix(3)}";
      }
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
          Uri.parse('https://tab-lu.onrender.com/winners-pageants/$eventId'));

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
          // Sort scoreCards by score in descending order
          // Sort pageantScoreCards by the score of the top contestant in each card
          pageantScoreCards.sort((a, b) {
            // Get the top score of each card
            double scoreA = a.topThreeContestants.isNotEmpty
                ? a.topThreeContestants[0].score
                : 0.0;
            double scoreB = b.topThreeContestants.isNotEmpty
                ? b.topThreeContestants[0].score
                : 0.0;
            // Compare the scores
            return scoreB.compareTo(scoreA); // Sort in descending order
          });

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

    // Load the logo image
    final ByteData data = await rootBundle.load('assets/icons/tablut222.png');
    final Uint8List bytesData =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final PdfBitmap image = PdfBitmap(bytesData);

    // Draw the logo at top-left
    const double logoWidth = 100;
    const double logoHeight = 70;
    graphics.drawImage(image, Rect.fromLTWH(0, 0, logoWidth, logoHeight));

    // Create a font for the title
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18);

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

    final PdfFont eventDetailsFont =
        PdfStandardFont(PdfFontFamily.helvetica, 14);
    String eventDetails =
        'Event name: ${eventData.eventName}\nDate: ${eventData.eventStartDate.toString().split(' ')[0]}\nTime: ${eventData.eventStartTime}';
    Size eventDetailsSize = eventDetailsFont.measureString(eventDetails);
    graphics.drawString(eventDetails, eventDetailsFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, contentYPosition, page.getClientSize().width,
            eventDetailsSize.height));
    contentYPosition +=
        eventDetailsSize.height + 20; // Adjust spacing after event details

    if (widget.event_category == "Pageants") {
      // Create a font for the content
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

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

        // Draw contestant details
        for (int j = 0;
            j < scoreCard.topThreeContestants.length;
            j++) {
          final contestant = scoreCard.topThreeContestants[j];

          // Check if drawing this contestant will exceed the available space
          if (contentYPosition + 30 > page.getClientSize().height) {
            // If drawing this contestant would exceed the available space, start a new page
            document.pages.add(); // Add a new page
            page = document
                .pages[document.pages.count - 1]; // Switch to the new page
            graphics = page.graphics; // Update graphics object
            contentYPosition = 0; // Reset contentYPosition for the new page
          }

          // Draw contestant information
          graphics.drawString(
            '${_getOrdinal(j, scoreCard.topThreeContestants)} ${contestant.contestantName}',
            contentFont,
            bounds: Rect.fromLTWH(25, contentYPosition, 300, 20),
          );

          // Draw contestant score
          graphics.drawString(
            contestant.score.toStringAsFixed(2),
            contentFont,
            bounds: Rect.fromLTWH(325, contentYPosition, 100, 20),
          );

          contentYPosition += 10; // Adjust vertical spacing
        }

        contentYPosition += 10; // Adjust spacing between criteria
      }
    } else {
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

      // Draw the content with rankings for the first three contestants
      for (int i = 0; i < scoreCards.length; i++) {
        var scoreCard = scoreCards[i];
        String ranking = '';

        // Assign rankings to the first three contestants
        if (i == 0) {
          ranking = '1st';
        } else if (i == 1) {
          ranking = '2nd';
        } else if (i == 2) {
          ranking = '3rd';
        }

        // Line to be drawn on the PDF
        String line =
            '${ranking.isNotEmpty ? "$ranking - " : ""}${scoreCard.contestantName}: ${scoreCard.score.toStringAsFixed(2)}%';
        graphics.drawString(line, contentFont,
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(
                0, contentYPosition, page.getClientSize().width, 20));
        contentYPosition += 20; // Adjust line spacing
      }
    }

    // Create a PDF grid and add the headers
    final PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );
    contentYPosition += 50;
    // Add column headers
    grid.columns.add(count: 2 + eventData.criterias.length * 2);
    PdfGridRow header = grid.headers.add(1)[0];
    header.cells[0].value = 'Judge';
    header.cells[1].value = 'Contestant';

    // Add criteria names as headers
    for (int i = 0; i < eventData.criterias.length; i++) {
      header.cells[2 + i * 2].value =
          "Criteria\n " + eventData.criterias[i].criteriaName;
      header.cells[3 + i * 2].value =
          'Calculated Score (${eventData.criterias[i].criteriaPercentage}%)';
    }

    Map<String, PdfGridRow> judgeContestantMap = {};
    // Add data to the table
    // Populate data in the grid
    for (var judge in eventData.judges) {
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
          row.cells[0].value = judge.judgeName;
          row.cells[1].value = contestant.contestantName;
        }

        // Fill or update criteria scores
        for (int i = 0; i < eventData.criterias.length; i++) {
          if (contestant.criteriaName == eventData.criterias[i].criteriaName) {
            row?.cells[2 + i * 2].value = contestant.judgeRawScore.toString();
            row?.cells[3 + i * 2].value =
                contestant.judgeCalculatedScore.toStringAsFixed(2);
          }
        }
      }
    }
    grid.draw(page: page, bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));

    // Calculate the position for the second grid
    double secondGridContentYPosition =
        contentYPosition + 200; // Adjust as needed

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
        print("Criteriaaa ${criteria.subCriteriaList[j].subCriteriaName}");
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
    secondGrid.draw(
        page: secondPage,
        bounds: Rect.fromLTWH(0, 0, secondPage.getClientSize().width,
            secondPage.getClientSize().height));

    // Save the document
    List<int> documentBytes = await document.save();
    // Dispose the document
    document.dispose();

    // Get the external storage directory
    final Directory directory = await getApplicationDocumentsDirectory();
    // Get the file path
    final String path = directory.path + '/score_rankings.pdf';
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
