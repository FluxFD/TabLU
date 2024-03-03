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
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Criteria({
    required this.criteriaName,
    required this.criteriaPercentage,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criteriaName: json['criteriaName'],
      criteriaPercentage: double.parse(json['criteriaPercentage']),
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
  final int judgeRawScore;
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
      judgeRawScore: json['judgeRawScore'],
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

  const Winner({required this.eventId, Key? key}) : super(key: key);

  @override
  State<Winner> createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<ScoreCard> scoreCards = [];
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
    fetchScoreCards();
  }

  double getCriteriaScore(Contestant contestant, String criteriaName) {
    // Implement this function to return the score for a given criteria.
    // This will depend on how you are storing the scores in the Contestant class.
    return 0.0; // Placeholder return
  }

  Future<String> generatePdf(
      List<ScoreCard> scoreCards, EventData eventData) async {
    // Request storage permission (make sure to handle permissions)

    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    // Add a page to the document
    final PdfPage page = document.pages.add();
    // Get page graphics for the page
    final PdfGraphics graphics = page.graphics;

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

    // Create a font for the content
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
      header.cells[2 + i * 2].value = eventData.criterias[i].criteriaName;
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

    // Draw the grid on the PDF page
    grid.draw(page: page, bounds: Rect.fromLTWH(0, contentYPosition, 0, 0));

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
        print("Data ${data['response']}");
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

          print('ScoreCards size: ${scoreCards.length}');

          for (var scorecard in scoreCards) {
            print(scorecard.contestantName);
          }
          eventData = EventData.fromJson(data['response']);

          // Now, eventData contains all the information needed for PDF generation
          print('Event Name: ${eventData.eventName}');
          print('Start Date: ${eventData.eventStartDate}');
          print('Start Time: ${eventData.eventStartTime}');
          print('Criterias: ${eventData.criterias}');
          print('Judges: ${eventData.judges}');

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
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 75, right: 25, top: 25),
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
                                  const SizedBox(width: 25),
                                  Text(scoreCards.length > 2
                                      ? scoreCards[1].contestantName
                                      : "No Scores"),
                                  const SizedBox(width: 25),
                                  Text(scoreCards.length > 2
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
                      padding:
                          const EdgeInsets.only(left: 120, top: 16, bottom: 30),
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
