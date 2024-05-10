import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/pages/finalscore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:tutorial/refresher.dart';
import 'package:tutorial/utility/sharedPref.dart';

import 'criteria.dart';

class Event {
  String eventId;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
  final String accessCode;
  final String? userId;
  final String eventTime;
  final List<Contestant> contestants;
  final List<Criteria> criterias;
  Event({
    required this.eventId,
    required this.eventName,
    required this.eventCategory,
    required this.eventVenue,
    required this.eventOrganizer,
    required this.eventDate,
    required this.accessCode,
    this.userId,
    required this.eventTime,
    required this.contestants,
    required this.criterias,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      eventName: json['eventName'] != null ? json['eventName'].toString() : '',
      eventCategory:
          json['eventCategory'] != null ? json['eventCategory'].toString() : '',
      eventVenue:
          json['eventVenue'] != null ? json['eventVenue'].toString() : '',
      eventOrganizer: json['eventOrganizer'] != null
          ? json['eventOrganizer'].toString()
          : '',
      eventDate: json['eventDate'] != null ? json['eventDate'].toString() : '',
      eventTime: json['eventTime'] != null ? json['eventTime'].toString() : '',
      accessCode:
          json['accessCode'] != null ? json['accessCode'].toString() : '',
      userId: json['user'] != null ? json['user'].toString() : '',
      contestants: (json['contestants'] as List<dynamic>?)
              ?.map((contestant) => Contestant.fromJson(contestant))
              .toList() ??
          [],
      criterias: (json['criterias'] as List<dynamic>?)
              ?.map((criteria) => Criteria.fromJson(criteria))
              .toList() ??
          [],
    );
  }
}

class Contestant {
  String contestantNumber;
  String name;
  String course;
  String department;
  String eventId;
  List<Criteria> criterias;
  String? profilePic;
  String? selectedImage;
  String? id;
  int totalScore;
  List<int?> criteriaScores = [];
  Contestant({
    required this.contestantNumber,
    required this.name,
    required this.course,
    required this.department,
    required this.eventId,
    required this.criterias,
    this.profilePic,
    this.selectedImage,
    this.id,
    required this.totalScore,
    required this.criteriaScores,
  });
  Contestant copyWith({
    String? contestantNumber,
    String? course,
    String? department,
    String? eventId,
    List<Criteria>? criterias,
    String? profilePic,
    String? selectedImage,
    String? id,
    int? totalScore,
    List<int?>? criteriaScores,
  }) {
    return Contestant(
      contestantNumber: contestantNumber ?? this.contestantNumber,
      name: name ?? this.name,
      course: course ?? this.course,
      department: department ?? this.department,
      eventId: eventId ?? this.eventId,
      criterias: criterias ?? List.unmodifiable(this.criterias),
      profilePic: profilePic ?? this.profilePic,
      selectedImage: selectedImage ?? this.selectedImage,
      id: id ?? this.id,
      totalScore: totalScore ?? this.totalScore,
      criteriaScores: criteriaScores ?? List.unmodifiable(this.criteriaScores),
    );
  }

  factory Contestant.fromJson(Map<String, dynamic> json) {
    List<dynamic>? criteriaList = json['criterias'] as List<dynamic>?;
    print('Raw JSON: $json');
    print('criteriaList: $criteriaList');
    return Contestant(
      contestantNumber: json['contestantNumber'].toString() ?? '',
      name: json['name'] != null ? json['name'].toString() : '',
      course: json['course'] != null ? json['course'].toString() : '',
      department:
          json['department'] != null ? json['department'].toString() : '',
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      criterias: criteriaList != null
          ? List.unmodifiable(
              criteriaList.map((criteria) => Criteria.fromJson(criteria)))
          : [],
      profilePic:
          json['profilePic'] != null ? json['profilePic'].toString() : '',
      selectedImage:
          json['selectedImage'] != null ? json['selectedImage'].toString() : '',
      id: json['_id'] != null ? json['_id'].toString() : '',
      totalScore: json['totalScore'] != null ? json['totalScore'] : 0,
      criteriaScores: criteriaList != null && criteriaList.isNotEmpty
          ? List<int?>.from(
              criteriaList.map((criteria) => criteria['score'] as int? ?? 0))
          : List<int?>.filled(criteriaList?.length ?? 0, null, growable: true),
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contestant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Criteria {
  String criteriaId;
  String criterianame;
  String percentage;
  List<SubCriteria> subCriteriaList; // List of subcriteria
  String eventId;
  int score;
  String baseScore;

  Criteria({
    required this.criteriaId,
    required this.criterianame,
    required this.percentage,
    required this.subCriteriaList,
    required this.eventId,
    required this.score,
    required this.baseScore,
  });

  Criteria copyWith({
    String? criteriaId,
    String? criterianame,
    String? percentage,
    List<SubCriteria>? subCriteriaList,
    String? eventId,
    int? score,
    String? baseScore,
  }) {
    return Criteria(
      criteriaId: criteriaId ?? this.criteriaId,
      criterianame: criterianame ?? this.criterianame,
      percentage: percentage ?? this.percentage,
      subCriteriaList: subCriteriaList ?? this.subCriteriaList,
      eventId: eventId ?? this.eventId,
      score: score ?? this.score,
      baseScore: baseScore ?? this.baseScore,
    );
  }

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criteriaId: json['_id'] != null ? json['_id'].toString() : '',
      criterianame:
          json['criterianame'] != null ? json['criterianame'].toString() : '',
      percentage:
          json['percentage'] != null ? json['percentage'].toString() : '',
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      subCriteriaList: (json['subCriteriaList'] as List<dynamic>?)
              ?.map((subCriteriaJson) => SubCriteria.fromJson(subCriteriaJson))
              .toList() ??
          [],
      score: json['score'] != null ? int.parse(json['score'].toString()) : 0,
      baseScore: json['baseScore'] != null ? json['baseScore'].toString() : '',
    );
  }
}

class Judge {
  String id;
  String name;
  bool scoreSubmitted;

  Judge({
    required this.id,
    required this.name,
    required this.scoreSubmitted,
  });

  factory Judge.fromJson(Map<String, dynamic> json) {
    return Judge(
      id: json['_id'] ?? 'No ID', // Fallback to 'No ID' if null
      name: json['userId']?['username'] ??
          'No Name', // Fallback to 'No Name' if null
      scoreSubmitted:
          json['scoreSubmitted'] ?? false, // Fallback to false if null
    );
  }
}

class JudgeScoreSheet extends StatefulWidget {
  late final String eventId;
  final Map<String, dynamic> eventData;
  final judges;

  JudgeScoreSheet({
    required this.eventId,
    required this.eventData,
    required this.judges,
  });

  void updateEventId(String newEventId) {
    JudgeScoreSheet._judgeScoreSheetState.currentState
        ?.updateEventId(newEventId);
  }

  @override
  State<JudgeScoreSheet> createState() => _JudgeScoreSheetState();
  static final GlobalKey<_JudgeScoreSheetState> _judgeScoreSheetState =
      GlobalKey<_JudgeScoreSheetState>();
}

String criterianame = "default_value";

class _JudgeScoreSheetState extends State<JudgeScoreSheet> {
  //----------------------------------------------------------------------
  late List<Contestant> contestants = [];

  late List<Criteria> criteria;
  late Map<String, dynamic> eventData = {};
  Map<String?, TextEditingController> controllers = {};
  Map<String, TextEditingController> judgeControllers = {};
  Map<String?, TextEditingController> subCriteriaControllers = {};

  TextEditingController feedbackController = TextEditingController();
  bool isLoading = false;
  late Event event = Event(
    eventId: '',
    eventName: '',
    eventCategory: '',
    eventVenue: '',
    eventOrganizer: '',
    eventDate: '',
    accessCode: '',
    eventTime: '',
    contestants: [],
    criterias: [],
  );
  bool isCreator = false;
  VoidCallback? onCriteriaFetched;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  void checkCreator(Event event) async {
    // Assuming User has a userId property
    String? token = await SharedPreferencesUtils.retrieveToken();
    String? userId;

    if (token != null && token.isNotEmpty) {
      // Decode the token to extract user information
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId =
          decodedToken['userId']?.toString(); // Ensure userId is of type String
    }
    // 99
    if (userId == event.userId) {
      print('userId: $userId and event.userId: ${event.userId}');
      isCreator = true;
    }
  }

  Future<void> fetchAll() async {
    initializeData();
    fetchEventDetails();
    calculateInitialTotalScores();
    criterianame = "InitialValue";
  }

  // Future<void> initializeControllers() async {
  //   controllers.clear();
  //   for (var contestant in _contestants) {
  //     for (var criteria in criterias) {
  //       String uniqueKey = "${contestant.id}_${criteria.criteriaId}";
  //       print(uniqueKey);
  //       controllers[uniqueKey] = TextEditingController();
  //     }
  //   }
  //   // print("Controllers initialized: ${controllers.length}");
  // }
  void dispose() {
    // Dispose of each controller in the 'controllers' map.
    for (var controller in controllers.values) {
      controller.dispose();
    }
    // Dispose of each controller in the 'judgeControllers' map.
    for (var controller in judgeControllers.values) {
      controller.dispose();
    }
    // Dispose of each subcriteria controller in the 'subCriteriaControllers' map.
    for (var controller in subCriteriaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool areAllFieldsPopulated() {
    for (TextEditingController judgeControllers in judgeControllers.values) {
      if (judgeControllers.text.isEmpty) {
        // If any controller's text is empty, return false
        return false;
      }
    }
    // If all controllers have non-empty text, return true
    return true;
  }

  void showRatingDialog(BuildContext context) {
    double userRating = 0;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('How was your experience?'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40.0,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: feedbackController,
                    maxLines: null, // Allow multiple lines
                    decoration: InputDecoration(
                      hintText: 'Write your feedback here...',
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('No thanks'),
                    ),
                    Spacer(), // Adds space between the buttons
                    TextButton(
                      onPressed: () async {
                        try {
                          String? token =
                              await SharedPreferencesUtils.retrieveToken();
                          String? userId;
                          if (token != null && token.isNotEmpty) {
                            // Decode the token to extract user information
                            Map<String, dynamic> decodedToken =
                                JwtDecoder.decode(token);
                            userId = decodedToken['userId'];
                          }
                          final Map<String, dynamic> requestBody = {
                            'eventId': widget.eventId,
                            'userId': userId,
                            'receiver': "",
                            'body': {
                              'rating': '$userRating',
                              'feedback': '${feedbackController.text}'
                            },
                            'type': 'feedback',
                          };
                          final String requestBodyJson =
                              jsonEncode(requestBody);
                          // Send server notification
                          final response = await http.post(
                            Uri.parse(
                                'https://tabluprod.onrender.com/notifications'),
                            headers: {'Content-Type': 'application/json'},
                            body: requestBodyJson,
                          );

                          if (response.statusCode == 201) {
                            // Notification successfully created on the server
                            print('Server notification sent successfully');
                          } else {
                            // Handle server notification creation failure
                            print(
                                'Failed to send server notification. Status code: ${response.statusCode}');
                          }

                          Navigator.of(context).pop(); // Close the dialog
                        } catch (error) {
                          // Handle any errors that occur during the submission process
                          print('Error during submission: $error');
                          // Display an error message or take appropriate action
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  BorderSide _getBorderSide(TextEditingController controller, Criteria criteria) {
    bool isNotEmptyAndLessThanBaseScore = controller.text.isNotEmpty &&
        double.parse(controller.text) < double.parse(criteria.baseScore);
    Color color = isNotEmptyAndLessThanBaseScore ? Colors.red : Colors.black54;
    double width = isNotEmptyAndLessThanBaseScore ? 2 : 1;

    return BorderSide(
      color: color,
      width: width,
    );
  }

  bool areScoresValid() {
    bool result = true;
    for (var entry in judgeControllers.entries) {
      String uniqueKey = entry.key;
      TextEditingController controller = entry.value;

      // Extract contestantId and criteriaId from the uniqueKey
      var ids = uniqueKey.split('_');
      var contestantId = ids[0];
      var criteriaId = ids[1];

      // Find the corresponding contestant and criteria
      var contestant = _contestants.firstWhere((c) => c.id == contestantId);
      var criteria = criterias.firstWhere((c) => c.criteriaId == criteriaId);

      // Parse the controller's text and baseScore to double
      double score = double.tryParse(controller.text) ?? 0.0;
      double baseScore = double.tryParse(criteria.baseScore) ?? 0.0;
      print("$score $baseScore");
      // If the score is greater than the baseScore, return false

      if (score < baseScore) {
        result = false;
        break;
      }
    }
    return result;
  }

  Future<void> handleSubmit() async {
    try {
      checkCreator(event);

      if (isCreator) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Winner(
              event_category: event.eventCategory,
              eventId: widget.eventId,
            ),
          ),
        );
        return;
      }

      if (!areAllFieldsPopulated()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all the fields before submitting.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!areScoresValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'The score you entered is outside the base range'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;

      if (token != null && token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }

      Map<String, Map<String, double>> contestantScores = {};
      Map<String, Map<String, double>> contestantRawScores = {};
      List<Map<String, dynamic>> subCriteriaData = [];

      judgeControllers.forEach((key, controller) {
        if (key != null && controller.text.isNotEmpty) {
          var ids = key.split('_');
          var contestantId = ids[0];
          var criteriaId = ids[1];
          double score = 0;
          double rawScore = 0;

          if (criteriaId != null && controller.text.isNotEmpty) {
            var parsedValue = double.tryParse(controller.text);

            var criteria = criterias
                .firstWhere((criteria) => criteria.criteriaId == criteriaId);

            if (parsedValue != null &&
                criteria != null &&
                double.tryParse(criteria.percentage) != 0) {
              double percentage = double.parse(criteria.percentage) / 100;
              score = (parsedValue * percentage);
              rawScore = parsedValue;
            }
          }

          if (criterias != null) {
            criterias.forEach((criteriaItem) {
              if (criteriaItem.subCriteriaList != null &&
                  criteriaItem.criteriaId == criteriaId) {
                criteriaItem.subCriteriaList!
                    .asMap()
                    .forEach((subIndex, subCriteria) {
                  TextEditingController? subController =
                      subCriteriaControllers['${key}_${subIndex}'];
                  if (subController != null) {
                    double subScore = double.tryParse(subController.text) ?? 0;
                    subCriteriaData.add({
                      'criteriaId': criteriaId,
                      'contestantId': contestantId,
                      'subCriteriaName': subCriteria.subCriteriaName,
                      'subCriteriaPercentage': subCriteria.percentage,
                      'subScore': subScore,
                    });
                  }
                });
              }
            });
          }

          if (!contestantScores.containsKey(contestantId)) {
            contestantScores[contestantId] = {};
          }
          if (contestantRawScores[contestantId] == null) {
            contestantRawScores[contestantId] = {};
          }

          contestantScores[contestantId]![criteriaId] = score;
          contestantRawScores[contestantId]![criteriaId] = rawScore;
        }
      });

      List<Map<String, dynamic>> submissionData =
          contestantScores.entries.map((entry) {
        var contestantId = entry.key;
        var scores = entry.value;
        var criteriaIds = scores.keys.toList();
        var rawScores = contestantRawScores[contestantId] ?? {};

        List<dynamic> criteriaScores = criteriaIds.map((criteriaId) {
          List<Map<String, dynamic>> subCriteriaDataForCriteria =
              subCriteriaData
                  .where((subData) =>
                      subData['criteriaId'] == criteriaId &&
                      subData['contestantId'] == contestantId)
                  .toList();
          return {
            "criteriaId": criteriaId,
            "scores": scores[criteriaId],
            "rawScore": rawScores[criteriaId],
            "subCriteriaList": subCriteriaDataForCriteria,
          };
        }).toList();

        return {
          "userId": userId,
          "eventId": widget.eventId,
          "contestantId": contestantId,
          "criterias": criteriaScores,
        };
      }).toList();

      print("Datas: ${submissionData}");

      var url = Uri.parse('https://tabluprod.onrender.com/scorecards');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submissionData),
      );

      if (response.statusCode == 201) {
        showRatingDialog(context);
        NotificationApi.sendNotificationScoresSubmitted(
            widget.eventId, userId!);
        print('Scores submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score successfully submitted'),
            backgroundColor: Colors.green,
          ),
        );
        await fetchAll();
      }

      if (response.statusCode == 403) {
        print('Scores already submitted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scores already submitted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while submitting scores'),
        ),
      );
    }
  }

  Future<bool> fetchJudges(String eventId) async {
    final url =
        Uri.parse('https://tabluprod.onrender.com/judges/$eventId/confirmed');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> judgesJson = json.decode(response.body);
      List<Judge> judges =
          judgesJson.map((json) => Judge.fromJson(json)).toList();

      // Check if all judges have submitted scores
      bool allScoresSubmitted =
          judges.every((judge) => judge.scoreSubmitted == true);

      return allScoresSubmitted;
    } else {
      throw Exception('Failed to load judges');
    }
  }

  Future<void> initializeData() async {
    try {
      final fetchedEventData = await fetchEventData(widget.eventId);
      if (fetchedEventData != null) {
        setState(() {
          //  _contestants = extractContestants(fetchedEventData);
          // criterias = extractCriteria(fetchedEventData);
        });
        print('Data initialized successfully');
      } else {
        print('Error: fetchEventData returned null');
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  void calculateInitialTotalScores() {
    for (var contestant in _contestants) {
      calculateTotalScore(contestant);
    }
  }

  late Contestant contestant;
  int? criteriaScore;

  late List<Event> events = [];
  late List<Contestant> _contestants = [];
  late List<Criteria> criterias = [];

  // for scores
  void calculateTotalScore(Contestant contestant) {
    print(contestant.criteriaScores);
    if (contestant == null || contestant.criterias == null) {
      print('Contestant or criterias is null');
      return;
    }

    int totalScore = 0;

    for (Criteria criteria in contestant.criterias) {
      if (criteria.score != null) {
        totalScore += criteria.score;
      }
    }
    List<Contestant> updatedContestants = List.from(_contestants);
    int index = updatedContestants.indexWhere((c) => c.id == contestant.id);
    if (index != -1) {
      updatedContestants[index].totalScore = totalScore;
    }
    setState(() {
      _contestants = updatedContestants;
    });

    print('After calculating total score: $totalScore');
    print('Total score for ${contestant.name}: $totalScore');
  }

  void updateCriterias(List<Criteria> newCriterias) {
    if (newCriterias.isNotEmpty) {
      setState(() {
        criterias = newCriterias;
      });
      print(
          'Updated Criterias List: ${criterias.map((c) => c.criterianame).toList()}');
    }
  }

  int? getCriteriaScore(
      Contestant contestant, String criteriaName, int criteriaScore) {
    print(
        'Calling getCriteriaScore for ${contestant.name}, criteria: $criteriaName, score: $criteriaScore');

    try {
      Criteria matchingCriteria = contestant.criterias.firstWhere(
        (criteria) =>
            criteria.criterianame.trim().toLowerCase() ==
            criteriaName.trim().toLowerCase(),
        orElse: () {
          print('Matching criteria not found for: $criteriaName');
          // Handle the case when no matching criteria is found
          // You can return a default criteria or throw an exception if needed
          return Criteria(
              criteriaId: 'Default Criteria ID',
              criterianame: 'Default Criteria',
              percentage: 'Default Percentage',
              eventId: 'Default Event ID',
              subCriteriaList: [],
              score: 0,
              baseScore: 'Default based score');
        },
      );
      matchingCriteria.score = criteriaScore;

      int index = _contestants.indexWhere((c) => c.id == contestant.id);
      if (index != -1) {
        _contestants[index].criteriaScores = _contestants[index]
            .criterias
            .map((criteria) => criteria.score)
            .toList();
      }

      print(
          'Updated criteria score for ${contestant.name}: ${matchingCriteria.score}');
      return matchingCriteria.score;
    } catch (e) {
      print('Matching criteria not found for: $criteriaName');
      // Handle specific exceptions if needed
      return null;
    }
  }

  void updateTotalScore(Contestant contestant) {
    print(contestant.totalScore);
    print('Before updating total score: ${contestant.criteriaScores}');
    int totalScore = contestant.criteriaScores.isNotEmpty
        ? contestant.criteriaScores.fold(0, (sum, score) => sum + (score ?? 0))
        : 0;

    setState(() {
      contestant.totalScore = 0;
    });

    print('After updating total score: ${contestant.criteriaScores}');
    print('Total score for ${contestant.name}: $totalScore');
    print('Contestant after updating total score: $contestant');
  }

  void updateEventId(String newEventId) {
    setState(() {
      widget.eventId = newEventId;
    });
  }

  void updateContestants(List<Contestant> contestants) {
    setState(() {
      _contestants = contestants;
    });

    // setState(() {
    //   isLoading = false;
    // });
  }

  Future<String?> fetchImagePath(Contestant contestant) async {
    final contestantId = contestant.id;
    final url = Uri.parse(
        'https://tabluprod.onrender.com/uploads/${contestantId}'); // Replace with your server URL
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Find the document that matches the contestant.id
        return data['filePaths'];
      } else {
        print(
            'Failed to fetch image path. Status code: ${response.statusCode}');
        return "";
      }
    } catch (e) {
      print('Error fetching image path: $e');
    }
  }

  void showContestantDetailsDialog(
    BuildContext context,
    Contestant contestant,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Center(
            child: Text(
              'Contestant Details',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 5, 70, 20),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: 300,
                  child: FutureBuilder<String?>(
                    future: fetchImagePath(
                        contestant), // Assuming fetchImagePath returns a String
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError || snapshot.data == null) {
                          // Handle error or missing data, return a placeholder
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors
                                .grey, // Set the color you want for the placeholder
                          );
                        } else {
                          // Check if snapshot.data is a valid URL
                          Uri? imageUrl;
                          try {
                            imageUrl = Uri.parse(snapshot.data!);
                          } catch (e) {
                            imageUrl = null;
                          }

                          if (imageUrl != null && imageUrl.isScheme("http") ||
                              imageUrl != null && imageUrl.isScheme("https")) {
                            // Return the Image.network if there is no error and data is a valid URL
                            return Image.network(
                              snapshot
                                  .data!, // Replace with your server URL and actual filename
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          } else {
                            // Handle invalid URL, return a placeholder
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors
                                  .grey, // Set the color you want for the placeholder
                            );
                          }
                        }
                      } else {
                        // Handle loading state
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 5.0,
                  child: Container(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Fullname: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: '${contestant.name}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text.rich(
                            TextSpan(
                              text: 'Age: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: '${contestant.course}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text.rich(
                            TextSpan(
                              text: 'Address: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: '${contestant.department}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text.rich(
                            TextSpan(
                              text: 'Event ID: ',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: '${contestant.eventId}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DataRow> buildContestantList(
      List<Contestant> contestants, Criteria? criteria) {
    List<DataRow> rows = [];

    if (criteria != null && event.eventCategory == "Pageants") {
      contestants.forEach((contestant) {
        List<DataCell> dataCells = [];

        // Add contestant data cells
        dataCells.add(DataCell(
          Center(child: Text(contestant.contestantNumber)),
        ));
        dataCells.add(DataCell(
          Center(child: Text(contestant.name)),
        ));

        // Add score data cells
        criteria.subCriteriaList.forEach((subCriteria) {
          String uniqueKey = "${contestant.id}_${criteria.criteriaId ?? ''}";
          int subCriteriaIndex = criteria.subCriteriaList.indexOf(subCriteria);
          String subUniqueKey = "${uniqueKey}_${subCriteriaIndex}";

          dataCells.add(DataCell(
            Container(
              height: 30, // Adjust the height as needed
              alignment: Alignment.center,
              child: TextFormField(
                controller: subCriteriaControllers[subUniqueKey],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: false,
                style: TextStyle(fontSize: 16), // Adjust font size as needed
                decoration: InputDecoration(
                  labelText: 'score',
                  isDense: true, // Reduces the height of the input field
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green
                    ),
                  ),
                ),
              ),
            ),
          ));
        });

        // Add view button
        dataCells.add(DataCell(
          IconButton(
            icon: Icon(Icons.remove_red_eye, color: Colors.green),
            onPressed: () {
              showContestantDetailsDialog(context, contestant);
            },
          ),
        ));

        rows.add(DataRow(cells: dataCells));
      });
    } else {
      contestants.forEach((contestant) {
        List<DataCell> dataCells = [];

        // Add contestant data cells
        dataCells.add(DataCell(Text(contestant.contestantNumber)));
        dataCells.add(DataCell(Text(contestant.name)));

        // Add score data cells if criterias are provided
        if (criterias != null && criterias.isNotEmpty) {
          criterias.forEach((criteria) {
            String uniqueKey = "${contestant.id}_${criteria.criteriaId ?? ''}";

            dataCells.add(DataCell(
              Container(
                height: 30,
                alignment: Alignment.center,
                child: TextFormField(
                  controller: controllers[uniqueKey],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'score',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ));
          });
        }

        // Add view button
        dataCells.add(DataCell(
          IconButton(
            icon: Icon(Icons.remove_red_eye, color: Colors.green),
            onPressed: () {
              showContestantDetailsDialog(context, contestant);
            },
          ),
        ));

        rows.add(DataRow(cells: dataCells));
      });
    }

    return rows;
  }

  // List<DataRow> buildJudgesList(
  //   List<Contestant> contestants,
  //   List<Criteria>? criterias,
  // ) {
  //   if (isLoading) {
  //     return [];
  //   } else {
  //     return buildContestantsList(contestants, criterias);
  //   }
  // }
  //
  // Widget buildLoadingWidget() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 150, right: 0),
  //     child: Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }

  Future<String> fetchEventId() async {
    final String url = 'https://tabluprod.onrender.com/latest-event-id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Latest Event ID Response Body: ${response.body}');
        final Map<String, dynamic> eventData = jsonDecode(response.body);
        if (eventData.containsKey('eventData') &&
            eventData['eventData'].containsKey('eventId')) {
          final String eventId =
              eventData['eventData']['eventId']?.toString() ?? '';
          return eventId;
        } else {
          print('Event ID not found in response');
          return '';
        }
      } else {
        print('Failed to load event data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load event data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during network request: $e');
      throw Exception('Error during network request: $e');
    }
  }

  Future<void> fetchEventDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      final String eventId = widget.eventId;
      print('Fetched Event ID: $eventId');
      if (eventId.isNotEmpty) {
        final response = await http
            .get(Uri.parse("https://tabluprod.onrender.com/event/$eventId"));
        print('Event Details Response Status Code: ${response.statusCode}');
        if (response.statusCode == 200) {
          dynamic eventData = jsonDecode(response.body);
          if (eventData != null && eventData is Map<String, dynamic>) {
            event = Event.fromJson(eventData);
            print('Event Details Response Body: $eventData');
            setState(() {
              events = [event];
              eventData = {
                'eventName': event.eventName,
                'eventDate': event.eventDate,
                'eventTime': event.eventTime,
                'accessCode': event.accessCode,
                // Add other data as needed
              };
            });
            widget.updateEventId(eventId);
            await fetchCriteria(eventId, onCriteriaFetched: () {
              print('Criteria fetched successfully');
            });

            await fetchContestants(eventId);
            checkCreator(event);

            setState(() {
              isLoading = false;
            });
          } else {
            print(
                'Invalid event data format. Expected Map, but got: ${eventData.runtimeType}');
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          throw Exception(
              'Failed to load event details. Status code: ${response.statusCode}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Event ID is empty.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error in fetchEventDetails: $e');
    }
  }

  Future<void> fetchContestants(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse("https://tabluprod.onrender.com/events/$eventId/contestants"),
      );
      if (response.statusCode == 200) {
        final dynamic contestantData = jsonDecode(response.body);
        print('Fetched Contestant Data: $contestantData');
        if (contestantData != null && contestantData is List) {
          List<Contestant> fetchedContestants =
              contestantData.map((data) => Contestant.fromJson(data)).toList();
          int index = 0;
          int criteriaIndex = 0;
          int subIndex = 0;

          for (var contestant in fetchedContestants) {
            int contestantIndex = 0;
            try {
              Map<String, List<double>> existingScores =
                  await fetchExistingScoresForContestant(
                      contestant.id, eventId);
              if (existingScores.isNotEmpty) {
                for (var criteria in criterias) {
                  String uniqueKey = "${contestant.id}_${criteria.criteriaId}";
                  // Load existing criteria score
                  List<double>? criteriaScore =
                      existingScores['criteriaScores'];
                  // Load existing raw score
                  List<double>? rawScore = existingScores['rawScores'];
                  List<dynamic>? subScore = existingScores['subScores'];

                  // Set the criteria score and raw score to the respective controllers
                  controllers["${uniqueKey}"] = TextEditingController(
                    text: criteriaScore![index].toStringAsFixed(2) ?? '',
                  );

                  if (rawScore!.isEmpty) {
                    judgeControllers[uniqueKey] = TextEditingController(
                      text: rawScore[index].toStringAsFixed(2) ?? '',
                    );
                  } else {
                    judgeControllers[uniqueKey] = TextEditingController(
                      text: rawScore[index].toStringAsFixed(2) ?? '',
                    );
                  }

                  index++;
                  for (int index = 0;
                      index < criteria.subCriteriaList.length;
                      index++) {
                    String uniqueSubKey = "${uniqueKey}_$index";
                    subCriteriaControllers[uniqueSubKey] =
                        TextEditingController(
                      text: subScore![subIndex].toStringAsFixed(2),
                    );
                    subIndex++;
                  }
                  criteriaIndex++;
                }
                contestantIndex++;
              } else {
                for (var contestant in fetchedContestants) {
                  for (var criteria in criterias) {
                    String uniqueKey =
                        "${contestant.id}_${criteria.criteriaId}"; // Assuming each criteria has a unique id
                    controllers[uniqueKey] = TextEditingController();
                    judgeControllers[uniqueKey] = TextEditingController();
                    // Initialize subcriteria controllers
                    for (int index = 0;
                        index < criteria.subCriteriaList.length;
                        index++) {
                      // var subCriteria = criteria.subCriteriaList[index];
                      String subCriteriaUniqueKey = "${uniqueKey}_${index}";
                      // Create controllers for subcriteria score and judge
                      subCriteriaControllers[subCriteriaUniqueKey] =
                          TextEditingController();
                      // print("length ${subCriteriaControllers.length} ${subCriteriaUniqueKey}");
                    }
                  }
                }
                print(
                    "Controllers populated after fetching contestants: ${controllers.length}");
                // Handle the case where fetch is not successful

                print('Failed to fetch scores for contestant ${contestant.id}');
              }
            } catch (error) {
              print('Error fetching scores: $error');
            }
          }
          setState(() {
            updateContestants(
              fetchedContestants,
            );
          });
        } else {
          print(
              'Invalid contestant data format. Expected List, but got: ${contestantData?.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        print('No contestants found for event with ID: $eventId');
      } else {
        print(
            'Failed to load contestants. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load contestants. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching contestants: $e');
    }
  }

  Future<Map<String, List<double>>> fetchExistingScoresForContestant(
      String? contestantId, String eventId) async {
    try {
      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;
      if (token != null && token.isNotEmpty) {
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      // Make a GET request to your server endpoint with contestantId and eventId as query parameters
      final Uri uri = Uri.parse(
          'https://tabluprod.onrender.com/judge-scorecards'); // Update the URL accordingly
      final response = await http.get(
        uri.replace(queryParameters: {
          'contestantId': contestantId ?? '',
          'eventId': eventId,
          'judgeId': widget.judges.id,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // Extract the scores from the response
        final List<dynamic> scoresData = responseBody['scores'];
        final List<double> rawScores = [];
        final List<double> criteriaScores = [];
        final List<double> subScores = [];

        for (var score in scoresData) {
          // Assuming the criteriascore is the value you want to extract
          double criteriaScore = score['criteria']['criteriascore'].toDouble();
          double rawScore = score['criteria']['rawScore'].toDouble();

          // Add raw score and criteria score to their respective lists
          rawScores.add(rawScore);
          criteriaScores.add(criteriaScore);

          // Extract and add sub-scores if available
          if (score['criteria']['subCriteriaList'] != null) {
            List<dynamic> subCriteriaList =
                score['criteria']['subCriteriaList'];
            for (var subCriteria in subCriteriaList) {
              double subScore = subCriteria['subScore'].toDouble();
              subScores.add(subScore);
            }
          }
        }

        // Organize scores into a map with keys to identify the types of scores
        Map<String, List<double>> organizedScores = {
          'rawScores': rawScores,
          'criteriaScores': criteriaScores,
          'subScores': subScores,
        };

        print("Contestant scores: $organizedScores");

        // Optionally, you might want to update the UI or perform other actions here
        return organizedScores;
      } else {
        // Handle error responses
        print('Failed to fetch scores. Status code: ${response.statusCode}');
        if (response.statusCode == 401 || response.statusCode == 404) {
          return {};
        }
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('error')) {
          final errorMessage = responseBody['error'] as String;

          // You might want to throw an exception or handle the error accordingly
          throw Exception(errorMessage);
        }

        print('Response body: ${response.body}');
        // You might want to throw an exception or handle the error accordingly
        throw Exception('Failed to fetch scores');
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching scores: $e');
      // You might want to throw an exception or handle the error accordingly
      throw Exception('Failed to fetch scores');
    }
  }

  Future<List<Criteria>> fetchCriteria(String eventId,
      {VoidCallback? onCriteriaFetched}) async {
    try {
      final response = await http
          .get(Uri.parse("https://tabluprod.onrender.com/events/$eventId/criteria"));
      print('Fetch Criteria - Status Code: ${response.statusCode}');
      print('Fetch Criteria - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null) {
          if (responseData is List) {
            final List<dynamic> criteriaData = responseData;
            print('Fetched Criteria Data: $criteriaData');
            if (criteriaData.isEmpty) {
              print('Criteria data is empty');
            } else {
              final List<Criteria> criteriaList =
                  criteriaData.map((data) => Criteria.fromJson(data)).toList();
              // Initialize controllers here after contestants are fetched
              // Clear old controllers if any, and create new ones
              setState(() {
                updateCriterias(criteriaList);
              });
              onCriteriaFetched?.call();
              return criteriaList;
            }
          } else {
            print(
                'Invalid criteria data format. Expected List, but got: ${responseData.runtimeType}');
          }
        } else {
          print('Response data is null');
        }
      } else if (response.statusCode == 404) {
        print('No criteria found for event with ID: $eventId');
      } else {
        print('Failed to load criteria. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load criteria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching criteria: $e');

      throw e;
    }
    return [];
  }

  // Function to show the confirmation dialog
  Future<bool> showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure you want to submit?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancelled
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the user dismissed the dialog
  }

  // Future<void> fetchData() async {
  //   try {
  //     final fetchedCriteria = await fetchCriteria(widget.eventId);
  //     if (fetchedCriteria != null && fetchedCriteria.isNotEmpty) {
  //       setState(() {
  //         updateCriterias(fetchedCriteria);
  //       });
  //       onCriteriaFetched?.call();
  //     } else {
  //       print('Error: Criteria data is null or empty');
  //     }
  //   } catch (e) {
  //     print('Error fetching criteria: $e');
  //   }
  // }

  //----------------------------------------------------------------------
// i added this line for the categories
// i have issues here.

  //------------------------------------------------------------

  Future<Map<String, dynamic>> fetchEventData(String eventId) async {
    final response =
        await http.get(Uri.parse('https://tabluprod.onrender.com/events/$eventId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> eventData = json.decode(response.body);
      return eventData;
    } else {
      throw Exception('Failed to load event data');
    }
  }

  int getMaxLength(List<dynamic> criterias) {
    int maxLength = 0;
    for (var criteria in criterias) {
      if (criteria.subCriteriaList != null &&
          criteria.subCriteriaList.length > maxLength) {
        maxLength = criteria.subCriteriaList.length;
      }
    }
    return maxLength;
  }

//------------------------------------------------------------
  /*List<Criteria> extractCriteria(Map<String, dynamic> eventData) {
    final List<dynamic> criteriaData = eventData['criterias'];
    return criteriaData.map((c) => Criteria.fromJson(c)).toList();
  }
  List<Contestant> extractContestants(Map<String, dynamic> eventData) {
    final List<dynamic> contestantsData = eventData['contestant'];
    return contestantsData.map((c) => Contestant.fromJson(c)).toList();
  }
  */
  //----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //--------------------------------------------------
    if (eventData == null) {
      return const CircularProgressIndicator();
    }
    final eventName = eventData['event_name'] ?? '';
    final eventVenue = eventData['event_venue'] ?? '';
    //---------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(),
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
            icon: const Icon(
              Icons.home,
              color: Color(0xFF054E07),
            ),
            onPressed: () async {
              String? token = await SharedPreferencesUtils.retrieveToken();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchEvents(token: token),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          '${widget.judges.name}',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
      ),
      body: Refresher(
          onRefresh: fetchAll, // Provide your refresh logic here
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                ' ${events.isNotEmpty ? events[0]?.eventName.toUpperCase() ?? '' : ''} live at ${events.isNotEmpty ? events[0]?.eventVenue.toUpperCase() ?? '' : ''} ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 5, 70, 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context)
                              .size
                              .width), // Ensure minimum width
                      child: _buildCriteriaColumn(),
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  color: Colors.green,
                  alignment: Alignment.topCenter,
                  child: const Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Instructions: Judges can only enter scores from based score to 100',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                      color: Color.fromARGB(255, 128, 127, 127),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                    child: Container(
                      child: Column(
                        children: [
                          DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.green),
                            columns: buildDataColumns(criterias),
                            rows: buildContestantsList(
                                context, _contestants, criterias),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ])))),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      width: 100,
                      height: 50,
                      child: Container(
                        height: 20,
                        child: AlertDialog(
                          title: const Center(
                              child: Text(
                            'Event Information',
                            style: TextStyle(fontSize: 18),
                          )),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                  child: Text(
                                '${events.isNotEmpty ? events[0]?.eventName ?? '' : ''}'
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 20),
                              )),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ACCESS CODE: ${events.isNotEmpty ? events[0]?.accessCode ?? '' : ''}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(new ClipboardData(
                                          text:
                                              '${events.isNotEmpty ? events[0]?.accessCode ?? '' : ''}'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Event ID copied to clipboard'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                  'Date & Time: ${events.isNotEmpty ? events[0]?.eventDate ?? '' : ''}, ${events.isNotEmpty ? events[0]?.eventTime ?? '' : ''}',
                                  style: TextStyle(fontSize: 14)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  'Category: ${events.isNotEmpty ? events[0]?.eventCategory ?? '' : ''}'),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  'Venue: ${events.isNotEmpty ? events[0]?.eventVenue ?? '' : ''}'),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  'Organizer: ${events.isNotEmpty ? events[0]?.eventOrganizer ?? '' : ''}'),
                            ],
                          ),
                          actions: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      // Fetch judges
                                      bool allScoresSubmitted =
                                          await fetchJudges(widget.eventId);

                                      if (allScoresSubmitted) {
                                        // If all judges have submitted scores, do something
                                        // For example, navigate to a new screen or perform another action
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Winner(
                                                    eventId: widget.eventId,
                                                    event_category:
                                                        event.eventCategory,
                                                  )),
                                        );
                                      } else {
                                        // If not all judges have submitted scores, show a Snackbar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Please wait for all judges to submit their scores'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      // Handle any errors that occur during the fetchJudges function
                                      print('Error fetching judges: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Failed to load judges'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('View scores'),
                                ),
                                Spacer(), // Adds space between the buttons
                                TextButton(
                                  onPressed: () {
                                    // Handle 'Close' button press
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Colors.black,
                ),
              ),
              child: const Text('INFO', style: TextStyle(color: Colors.green)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                bool confirmed = await showConfirmationDialog();
                if (confirmed) {
                  try {
                    await handleSubmit();
                    // The rest of your code goes here
                    final String? token =
                        await SharedPreferencesUtils.retrieveToken();
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>  SearchEvents(token: token),
                    //   ),
                    // );
                  } catch (error) {
                    // Handle the error here, you can log it or show a user-friendly message
                    print('An error occurred: $error');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> buildDataColumns(List<Criteria> criterias) {
    List<DataColumn> columns = [
      DataColumn(
        label: Text(
          'Contestant #',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Name',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Example of using a function to create columns dynamically
      ...criterias.map((criteria) {
        double percentage = double.tryParse(criteria.percentage) ?? 0.0;
        return DataColumn(
          label: Container(
            height: 50,
            padding: const EdgeInsets.only(top: 5),
            color: Colors.green,
            alignment: Alignment.topCenter,
            child: buildCriteriaRow(
              criteria.criterianame,
              percentage,
              criteria.subCriteriaList,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    ];

    return columns;
  }

  List<DataRow> buildContestantsList(BuildContext context,
      List<Contestant> contestants, List<Criteria>? criterias) {
    // Sort contestants based on contestantNumber
    contestants.sort((a, b) =>
        int.parse(a.contestantNumber).compareTo(int.parse(b.contestantNumber)));
    List<DataRow> rows = [];

    for (int index = 0; index < contestants.length; index++) {
      Contestant contestant = contestants[index];
      List<DataCell> cells = [];

      cells.add(
        DataCell(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                contestant.contestantNumber.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      cells.add(
        DataCell(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              contestant.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );

      List<DataCell> scoreFields = [];
      if (criterias != null && criterias.isNotEmpty) {
        scoreFields = criterias.map((criteria) {
          String uniqueKey = "${contestant.id}_${criteria.criteriaId ?? ''}";
          return DataCell(
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: judgeControllers[uniqueKey],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?$|^100(\.0{0,2})?$'),
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Custom logic to restrict input to the range of 0-100
                          try {
                            if (newValue.text.isEmpty) {
                              // Allow empty value
                              return newValue;
                            }
                            final enteredValue = double.parse(newValue.text);
                            if (enteredValue >= 0 && enteredValue <= 100) {
                              return newValue;
                            } else {
                              // Value is out of range, return the oldValue
                              return oldValue;
                            }
                          } catch (e) {
                            // Error parsing the value, return the oldValue
                            return oldValue;
                          }
                        }),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        labelText:
                            criteria.baseScore, // Use baseScore as labelText
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: (judgeControllers[uniqueKey]!
                                        .text
                                        .isNotEmpty &&
                                double.parse(
                                            judgeControllers[uniqueKey]!.text) <
                                    double.parse(criteria.baseScore))
                                ? Colors.red
                                : Colors.black54,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: (judgeControllers[uniqueKey]!
                                        .text
                                        .isNotEmpty &&
                                    double.parse(
                                            judgeControllers[uniqueKey]!.text) <
                                        double.parse(criteria.baseScore))
                                ? Colors.red
                                : Colors.black54,
                            width: (judgeControllers[uniqueKey]!
                                        .text
                                        .isNotEmpty &&
                                double.parse(
                                            judgeControllers[uniqueKey]!.text) <
                                    double.parse(criteria.baseScore))
                                ? 2.0
                                : 1.0, // Change width when condition is true
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(
                            () {}); // Rebuild the widget to update the border color
                      },
                      enabled: !criteria.subCriteriaList
                          .isNotEmpty, // Enable or disable based on the bool parameter
                    ),
                  ),
                ),
                if (criteria.subCriteriaList.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return buildSubCriteriaScoreDialog(
                              uniqueKey, criteria);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        }).toList();
      }

      cells.addAll(scoreFields);

      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  Widget _buildCriteriaColumn() {
    if (event.eventCategory == 'Pageants') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: criterias.map((criteriaItem) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display criteria name as header cell
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                            10.0), // Adjust the vertical padding as needed
                    child: Text(
                      criteriaItem.criterianame,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green), // Set border color
                    borderRadius: BorderRadius.all(
                        Radius.circular(5.0)), // Optional: Add border radius
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.green),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Contestant #',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ...criteriaItem.subCriteriaList.map((subCriteria) {
                        return DataColumn(
                          label: Text(
                            '${subCriteria.subCriteriaName} ${subCriteria.percentage}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                      DataColumn(
                        label: Text(
                          'View',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // Container or widget for contestant list
                    rows: buildContestantList(_contestants, criteriaItem),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    } else {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.green),
              columns: [
                ...buildDataColumns(
                    criterias), // Assuming buildDataColumns returns a list of DataColumn
                DataColumn(
                  label: const Text(
                    'View',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              rows: buildContestantList(_contestants,
                  null), // Assuming this function returns a widget
            ),
          ),
        ],
      );
    }
  }

  // Widget buildSubCriteriaModalButton(Contestant contestant, Criteria criteria) {
  //   String uniqueKey = "${contestant.id}_${criteria.criteriaId ?? ''}";
  //   if (criteria.subCriteriaList.isNotEmpty) {
  //     return buildSubCriteriaScoreButton(uniqueKey, criteria);
  //   } else {
  //     // Return an empty widget
  //     return SizedBox.shrink(); // Or return Container()
  //   }
  // }
  //
  // Widget buildJudgeScoreField(String uniqueKey, bool isSubCriteriaEmpty) {
  //   return Container(
  //     height: 30,
  //     alignment: Alignment.center,
  //     child: TextFormField(
  //       controller: judgeControllers[uniqueKey],
  //       keyboardType: TextInputType.number,
  //       textAlign: TextAlign.center,
  //       inputFormatters: [
  //         FilteringTextInputFormatter.digitsOnly,
  //         LengthLimitingTextInputFormatter(3), // Limit to 3 digits
  //         TextInputFormatter.withFunction((oldValue, newValue) {
  //           // Custom logic to restrict input to the range of 0-100
  //           try {
  //             if (newValue.text.isEmpty) {
  //               // Allow empty value
  //               return newValue;
  //             }
  //             final enteredValue = int.parse(newValue.text);
  //             if (enteredValue >= 0 && enteredValue <= 100) {
  //               return newValue;
  //             } else {
  //               // Value is out of range, return the oldValue
  //               return oldValue;
  //             }
  //           } catch (e) {
  //             // Error parsing the value, return the oldValue
  //             return oldValue;
  //           }
  //         }),
  //       ],
  //       decoration: InputDecoration(
  //         labelText: 'score',
  //         border: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.green),
  //         ),
  //       ),
  //       enabled: true, // Enable or disable based on the bool parameter
  //     ),
  //   );
  // }
  //
  // Widget buildSubCriteriaScoreButton(String uniqueKey, Criteria criteria) {
  //   return IconButton(
  //     icon: Icon(Icons.info_outline),
  //     onPressed: () {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return buildSubCriteriaScoreDialog(uniqueKey, criteria);
  //         },
  //       );
  //     },
  //   );
  // }

  Widget buildSubCriteriaScoreDialog(String uniqueKey, Criteria criteria) {
    List<TextEditingController> validControllers = [];

    // Filter controllers based on the existence of subcriteria
    for (var i = 0; i < criteria.subCriteriaList.length; i++) {
      String subUniqueKey = "${uniqueKey}_${i}"; // Define subUniqueKey here
      TextEditingController? controller = subCriteriaControllers[subUniqueKey];
      if (controller != null) {
        validControllers.add(controller);
      }
    }
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Sub criteria'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Please enter score (${criteria.baseScore}-100)'),
                SizedBox(height: 8),
                ...validControllers.map((controller) {
                  int index = validControllers.indexOf(controller);
                  String subCriteriaName =
                      criteria.subCriteriaList![index].subCriteriaName;
                  double subCriteriaPercentage =
                  double.parse(criteria.subCriteriaList![index].percentage);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?$|^100(\.0{0,2})?$')),
                      // Allow up to 3 digits followed by an optional decimal and up to 2 decimal places
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            if (newValue.text.isEmpty) {
                              return newValue;
                            }
                            final enteredValue = double.parse(newValue.text);
                            if (enteredValue >= 0 && enteredValue <= 100) {
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          } catch (e) {
                            return oldValue;
                          }
                        }),
                      ],
                      decoration: InputDecoration(
                        labelText: '$subCriteriaName (${subCriteriaPercentage}%)',
                        // Use baseScore as labelText
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: (controller.text.isNotEmpty &&
                                double.parse(controller.text) <
                                    double.parse(criteria.baseScore))
                                ? Colors.red
                                : Colors.black54,
                            width: (controller.text.isNotEmpty &&
                                double.parse(controller.text) <
                                    double.parse(criteria.baseScore))
                                ? 2
                                : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: (controller.text.isNotEmpty &&
                                double.parse(controller.text) <
                                    double.parse(criteria.baseScore))
                                ? Colors.red
                                : Colors.black54,
                            width: (controller.text.isNotEmpty &&
                                double.parse(controller.text) <
                                    double.parse(criteria.baseScore))
                                ? 2
                                : 1,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  bool isValid = true;
                  validControllers.forEach((controller) {
                    if (controller.text.isEmpty) {
                      isValid = false;
                      Fluttertoast.showToast(
                        msg: 'Please fill in all fields',
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }
                  });
                  for (var controller in validControllers) {
                    double subCriteriaScore = double.parse(controller.text);
                    int index = validControllers.indexOf(controller);
                    double baseScore = double.parse(criteria.baseScore);
                    if (subCriteriaScore < baseScore) {
                      isValid = false;
                      Fluttertoast.showToast(
                        msg: 'All scores must be greater than or equal to the base score',
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }
                  }
                  if (isValid) {
                    double totalScore = 0;
                    for (var controller in validControllers) {
                      double subCriteriaScore = double.parse(controller.text);
                      int index = validControllers.indexOf(controller);
                      double subCriteriaPercentage =
                      double.parse(criteria.subCriteriaList[index].percentage);
                      String subUniqueKey = "${uniqueKey}_${index}"; // Define subUniqueKey here
                      totalScore +=
                          subCriteriaScore * (subCriteriaPercentage / 100);
                    }
                    TextEditingController judgeController =
                    judgeControllers[uniqueKey]!;
                    judgeController.text = totalScore.toStringAsFixed(2);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget buildContestantRow(Contestant contestant, int number) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text('Number: $number'),
        subtitle:
            Text('Name: ${contestant.name}\nCourse: ${contestant.course}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget buildCriteriaList(List<Criteria> criterias, {TextStyle? style}) {
    return Row(
      children: criterias.map((criteria) {
        double percentage = double.tryParse(criteria.percentage) ?? 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: buildCriteriaRow(
            criteria.criterianame,
            percentage,
            criteria.subCriteriaList,
            style: style,
          ),
        );
      }).toList(),
    );
  }

  Widget buildCriteriaRow(
      String criterianame, double percentage, List<SubCriteria> subCriteriaList,
      {TextStyle? style}) {
    TextStyle finalStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    ).merge(style ?? TextStyle());

    return Row(
      children: [
        Text(
          '$criterianame: $percentage%',
          style: finalStyle,
        ),
        IconButton(
          icon: Icon(Icons.info),
          color: Colors.white, // Customize the color of the info icon
          onPressed: () {
            // Handle the onPressed event (e.g., show information dialog)
            // Example:
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Criteria Information'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Criteria name: $criterianame'),
                      SizedBox(height: 8), // Add spacing
                      Text('Percentage: $percentage%'),
                      SizedBox(height: 8), // Add spacing
                      Row(
                        children: [
                          Text(
                            'Subcriteria',
                            style: finalStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          Text(
                            'Percentage',
                            style: finalStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                      SizedBox(height: 10), // Add spacing between texts
                      ...subCriteriaList.map((subCriteria) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${subCriteria.subCriteriaName}',
                              ),
                            ),
                            Text(
                              '${subCriteria.percentage}%',
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var index = 0;
    for (var element in this) {
      yield f(index, element);
      index += 1;
    }
  }
}
