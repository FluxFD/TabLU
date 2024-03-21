import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/pages/finalscore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/pages/judgescoresheet.dart';
import 'package:tutorial/refresher.dart';
import 'package:tutorial/utility/sharedPref.dart';

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
    String? name,
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
  String eventId;
  int score;
  Criteria({
    required this.criteriaId,
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    required this.score,
  });

  Criteria copyWith({
    String? criteriaId,
    String? criterianame,
    String? percentage,
    String? eventId,
    int? score,
  }) {
    return Criteria(
      criteriaId: criteriaId ?? this.criteriaId,
      criterianame: criterianame ?? this.criterianame,
      percentage: percentage ?? this.percentage,
      eventId: eventId ?? this.eventId,
      score: score ?? this.score,
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
      score: json['score'] != null ? int.parse(json['score'].toString()) : 0,
    );
  }
}

class Judge {
  final String id;
  final String name;
  bool scoreSubmitted;

  Judge({
    required this.id,
    required this.name,
    required this.scoreSubmitted,
  });

  factory Judge.fromJson(Map<String, dynamic> json) {
    print("Judge JSON: $json");

    var judge = Judge(
      id: json['_id'] ?? 'No ID',
      name: json['userId']?['username'] ?? 'No Name',
      scoreSubmitted:
          json['scoreSubmitted'] ?? false, // Fallback to false if null
    );

    print("Created Judge: id=${judge.id}, name=${judge.name}");

    return judge;
  }
}

class ScoreCard extends StatefulWidget {
  String eventId;
  final Map<String, dynamic> eventData;
  final List<User> judges;

  ScoreCard(
      {required this.eventId, required this.eventData, required this.judges});

  void updateEventId(String newEventId) {
    ScoreCard._scoreCardState.currentState?.updateEventId(newEventId);
  }

  @override
  State<ScoreCard> createState() => _ScoreCardState();
  static final GlobalKey<_ScoreCardState> _scoreCardState =
      GlobalKey<_ScoreCardState>();
}

String criterianame = "default_value";

class _ScoreCardState extends State<ScoreCard> {
  late List<Contestant> contestants = [];

  late List<Criteria> criteria;
  late Map<String, dynamic> eventData = {};
  late List<Judge> judges = [];
  Map<String?, TextEditingController> controllers = {};
  Map<String, TextEditingController> judgeControllers = {};
  bool isLoading = false;
  late Event event;
  bool isCreator = true;

  VoidCallback? onCriteriaFetched;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  void checkCreator(Event event) async {
    String? token = await SharedPreferencesUtils.retrieveToken();
    String? userId;

    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId']?.toString();
    }
    if (userId == event.userId) {
      isCreator = false;
    }
  }

  Future<void> fetchAll() async {
    initializeData();
    fetchEventDetails();
    calculateInitialTotalScores();
    criterianame = "InitialValue";
    fetchJudges(widget.eventId).then((loadedJudges) {
      setState(() {
        judges = loadedJudges;
      });
    });
  }

  Future<void> initializeControllers() async {
    controllers.clear();
    for (var contestant in _contestants) {
      for (var criteria in criterias) {
        String uniqueKey = "${contestant.id}_${criteria.criteriaId}";
        print(uniqueKey);
        controllers[uniqueKey] = TextEditingController();
      }
    }
    // print("Controllers initialized: ${controllers.length}");
  }

  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool areAllFieldsPopulated() {
    for (TextEditingController controller in controllers.values) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<bool> fetchJudgesScoreSubmitted(String eventId) async {
    final url =
        Uri.parse('http://192.168.101.6:8080/judges/$eventId/confirmed');
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

  Future<void> handleSubmit() async {
    try {
      if (!isCreator) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("You are the creator of this event. Can't submit scores"),
            backgroundColor: Colors.orange,
          ),
        );
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
      // Step 1: Collect Scores
      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;
      if (token != null && token.isNotEmpty) {
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      Map<String, Map<String, double>> contestantScores = {};
      Map<String, Map<String, double>> contestantRawScores = {};
      print(controllers.length);
      controllers.forEach((key, controller) {
        if (key != null && controller.text.isNotEmpty) {
          var ids = key.split('_');
          var contestantId = ids[0];
          var criteriaId = ids[1];
          double score = 0;
          double rawScore = 0;

          if (criteriaId != null && controller.text.isNotEmpty) {
            var parsedValue = double.tryParse(controller.text);

            // Find the Criteria object in the criterias list based on criteriaId
            var criteria = criterias
                .firstWhere((criteria) => criteria.criteriaId == criteriaId);

            if (parsedValue != null &&
                criteria != null &&
                double.tryParse(criteria.percentage) != 0) {
              // Access the percentage directly from the found criteria
              double percentage = double.parse(criteria.percentage) / 100;

              // Calculate the score based on the percentage
              rawScore = parsedValue;
              score = (parsedValue * percentage);
            }
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
        // Create a list of maps for criteriaScores
        List<dynamic> criteriaScores = criteriaIds.map((criteriaId) {
          return {
            "criteriaId": criteriaId,
            "scores": scores[criteriaId],
            "rawScore": rawScores[criteriaId],
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
      var url = Uri.parse('http://192.168.101.6:8080/scorecards');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submissionData),
      );

      if (response.statusCode == 201) {
        // Handle successful submission
        print('Scores submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score successfully submitted'),
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

  Future<List<Judge>> fetchJudges(String eventId) async {
    final url =
        Uri.parse('http://192.168.101.6:8080/judges/$eventId/confirmed');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> judgesJson = json.decode(response.body);
      return judgesJson.map((json) => Judge.fromJson(json)).toList();
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
  TextEditingController _scoreController = TextEditingController();

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
            score: 0,
          );
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

    print('Updated Contestants List: $_contestants');
  }

  Future<String?> fetchImagePath(Contestant contestant) async {
    final contestantId = contestant.id;
    final url = Uri.parse(
        'http://192.168.101.6:8080/uploads/${contestantId}'); // Replace with your server URL
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
                    future: fetchImagePath(contestant),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError || snapshot.data == null) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey,
                          );
                        } else {
                          Uri? imageUrl;
                          try {
                            imageUrl = Uri.parse(snapshot.data!);
                          } catch (e) {
                            imageUrl = null;
                          }

                          if (imageUrl != null && imageUrl.isScheme("http") ||
                              imageUrl != null && imageUrl.isScheme("https")) {
                            return Image.network(
                              snapshot.data!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey,
                            );
                          }
                        }
                      } else {
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
                print('Winner button pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Winner(
                        eventId: widget.eventId,
                        event_category: event.eventCategory),
                  ),
                );
              },
              child: const Text(
                'Winner',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildContestantList(
      List<Contestant> contestants, List<Criteria>? criterias) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 150, right: 110),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: contestants.length,
          itemBuilder: (BuildContext context, int index) {
            Contestant contestant = contestants[index];
            List<Widget> scoreFields = [];
            if (criterias != null && criterias.isNotEmpty) {
              scoreFields = criterias.map((criteria) {
                String uniqueKey =
                    "${contestant.id}_${criteria.criteriaId ?? ''}";
                return Expanded(
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: controllers[uniqueKey],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      enabled: isCreator,
                      decoration: InputDecoration(
                        labelText: 'score',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList();
            }

            return Card(
              elevation: 5.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(contestant.name,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  ...scoreFields,
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                    onPressed: () {
                      showContestantDetailsDialog(context, contestant);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget buildJudgesList(List<Judge> judges, List<Criteria>? criterias) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 150, right: 110),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: judges.length,
          itemBuilder: (BuildContext context, int index) {
            Judge judge = judges[index];
            List<Widget> scoreFields = [];
            return Card(
              elevation: 5.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(judge.name,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  ...scoreFields,
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JudgeScoreSheet(
                            eventId: events[0].eventId,
                            eventData: {},
                            judges: judge,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Future<String> fetchEventId() async {
    final String url = 'http://192.168.101.6:8080/latest-event-id';
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
            .get(Uri.parse("http://192.168.101.6:8080/event/$eventId"));
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
        Uri.parse("http://192.168.101.6:8080/events/$eventId/contestants"),
      );
      if (response.statusCode == 200) {
        final dynamic contestantData = jsonDecode(response.body);
        print('Fetched Contestant Data: $contestantData');
        if (contestantData != null && contestantData is List) {
          List<Contestant> fetchedContestants =
              contestantData.map((data) => Contestant.fromJson(data)).toList();

          for (var contestant in fetchedContestants) {
            try {
              List<double> existingScores =
                  await fetchExistingScoresForContestant(
                      contestant.id, eventId);

              if (existingScores.isNotEmpty) {
                int criteriaLength = criterias.length;
                List<List<double>> splitScores = List.generate(
                  criteriaLength - 1,
                  (index) {
                    int start = index * criteriaLength;
                    int end = (index + 1) * criteriaLength;
                    return existingScores.sublist(start, end);
                  },
                );

                List<double> criterionAverages = List.generate(
                  criteriaLength,
                  (index) =>
                      splitScores.fold(
                          0.0, (sum, scores) => sum + scores[index]) /
                      splitScores.length,
                );

                for (var criteria in criterias) {
                  String uniqueKey = "${contestant.id}_${criteria.criteriaId}";
                  controllers[uniqueKey] = TextEditingController(
                    text: criterionAverages[criterias.indexOf(criteria)]
                        .toStringAsFixed(2),
                  );
                }
              } else {
                for (var contestant in fetchedContestants) {
                  for (var criteria in criterias) {
                    String uniqueKey =
                        "${contestant.id}_${criteria.criteriaId}";
                    controllers[uniqueKey] = TextEditingController();
                  }
                }
                print(
                    "Controllers populated after fetching contestants: ${controllers.length}");
                print('Failed to fetch scores for contestant ${contestant.id}');
              }
            } catch (error) {
              print('Error fetching scores: $error');
            }
          }

          setState(() {
            updateContestants(
              contestantData.map((data) => Contestant.fromJson(data)).toList(),
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

  Future<List<double>> fetchExistingScoresForContestant(
      String? contestantId, String eventId) async {
    try {
      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;
      if (token != null && token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      final Uri uri = Uri.parse('http://192.168.101.6:8080/scorecards');
      final response = await http.get(
        uri.replace(queryParameters: {
          'contestantId': contestantId ?? '',
          'eventId': eventId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> scoresData = responseBody['scores'];
        final List<double> scores = scoresData.map<double>((score) {
          return score['criteria']['criteriascore'].toDouble();
        }).toList();

        print("Contestant scores: $scores");

        return scores;
      } else {
        // Handle error responses
        print('Failed to fetch scores. Status code: ${response.statusCode}');
        if (response.statusCode == 401) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          // if (responseBody.containsKey('error')) {
          //   final errorMessage = responseBody['error'] as String;
          //
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(errorMessage),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          // }
        }
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching scores: $e');
      return [];
    }
  }

  Future<List<Criteria>> fetchCriteria(String eventId,
      {VoidCallback? onCriteriaFetched}) async {
    try {
      final response = await http
          .get(Uri.parse("http://192.168.101.6:8080/events/$eventId/criteria"));
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

  Future<void> fetchData() async {
    try {
      final fetchedCriteria = await fetchCriteria(widget.eventId);
      if (fetchedCriteria != null && fetchedCriteria.isNotEmpty) {
        setState(() {
          updateCriterias(fetchedCriteria);
        });
        onCriteriaFetched?.call();
      } else {
        print('Error: Criteria data is null or empty');
      }
    } catch (e) {
      print('Error fetching criteria: $e');
    }
  }

  Future<Map<String, dynamic>> fetchEventData(String eventId) async {
    final response =
        await http.get(Uri.parse('http://192.168.101.6:8080/events/$eventId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> eventData = json.decode(response.body);
      return eventData;
    } else {
      throw Exception('Failed to load event data');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (eventData == null) {
      return const CircularProgressIndicator();
    }
    final eventName = eventData['event_name'] ?? '';
    final eventVenue = eventData['event_venue'] ?? '';

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
        title: const Text(
          'Score Sheet',
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
                    height: 100,
                    width: 500,
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
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
                Visibility(
                  visible: false,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: 400,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 600,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 70,
                                        padding: const EdgeInsets.only(top: 5),
                                        color: Colors.green,
                                        alignment: Alignment.topCenter,
                                        child: const Text(
                                          'Name',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...criterias.map((criteria) {
                                      double percentage = double.tryParse(
                                              criteria.percentage) ??
                                          0.0;
                                      return Expanded(
                                        child: Container(
                                          height: 70,
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          color: Colors.green,
                                          alignment: Alignment.topCenter,
                                          child: buildCriteriaRow(
                                            criteria.criterianame,
                                            percentage,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    Expanded(
                                      child: Container(
                                        height: 70,
                                        padding: const EdgeInsets.only(top: 5),
                                        color: Colors.green,
                                        alignment: Alignment.topCenter,
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                buildContestantList(_contestants, criterias),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                  child: Container(
                    height: 500,
                    child: Column(
                      children: [
                        Container(
                          height: 35,
                          padding:
                              const EdgeInsets.only(top: 5, left: 5, right: 5),
                          color: Colors.green,
                          alignment: Alignment.topCenter,
                          child: const Text(
                            'Judges',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Instructions: Judges can only enter scores from 1 to 100',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w200,
                              color: Color.fromARGB(255, 128, 127, 127),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(top: 5),
                          color: Colors.green,
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Center(
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(top: 5),
                                  color: Colors.green,
                                  alignment: Alignment.topCenter,
                                  child: Center(
                                    child: Text(
                                      'View Scoresheet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        buildJudgesList(judges, criterias),
                      ],
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
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
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
                try {
                  bool allScoresSubmitted =
                      await fetchJudgesScoreSubmitted(widget.eventId);

                  if (!allScoresSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please wait for all judges to submit their scores'),
                        backgroundColor: Colors.orange,
                      ),
                    );

                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Winner(
                          eventId: widget.eventId,
                          event_category: event.eventCategory),
                    ),
                  );
                } catch (error) {
                  print('An error occurred: $error');
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
            style: style,
          ),
        );
      }).toList(),
    );
  }

  Text buildCriteriaRow(String criterianame, double percentage,
      {TextStyle? style}) {
    TextStyle finalStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ).merge(style ?? TextStyle());

    return Text(
      '$criterianame: $percentage%',
      style: finalStyle,
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
