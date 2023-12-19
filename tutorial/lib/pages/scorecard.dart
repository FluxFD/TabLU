import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/pages/finalscore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/utility/sharedPref.dart';

class Event {
  String eventId;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
  final String accessCode;
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
  final String id; // Assuming each judge has an ID
  final String name; // And a name

  Judge({required this.id, required this.name});

  factory Judge.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON to see what data is received.
    print("Judge JSON: $json");

    var judge = Judge(
      id: json['_id'] ?? 'No ID', // Fallback to 'No ID' if null
      name: json['userId']?['username'] ??
          'No Name', // Fallback to 'No Name' if null
    );

    // Debug: Print the created Judge object.
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
  //----------------------------------------------------------------------
  late List<Contestant> contestants = [];

  late List<Criteria> criteria;
  late Map<String, dynamic> eventData;
  late List<Judge> judges = [];
  Map<String?, TextEditingController> controllers = {};

  VoidCallback? onCriteriaFetched;

  //----------------------------------------------------------------------
//   String? criteriaName;
  @override
  void initState() {
    print('Init State - criteriaName: $criterianame');
    super.initState();
    eventData = {};
    initializeData();
    fetchEventDetails();
    // contestant = Contestant(
    //   name: '',
    //   course: 'DefaultCourse',
    //   department: 'DefaultDepartment',
    //   eventId: '',
    //   totalScore: 0,
    //   criterias: [],
    //   criteriaScores: [],
    // );
    calculateInitialTotalScores();
    criterianame = "InitialValue";
    fetchJudges(widget.eventId).then((loadedJudges) {
      setState(() {
        judges = loadedJudges;
      });
    });
  }

  void dispose() {
    // Dispose of each controller in the 'controllers' map.
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> handleSubmit() async {
    try {
      // Step 1: Collect Scores
      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;
      if (token != null && token.isNotEmpty) {
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      Map<String, Map<String, double>> contestantScores = {};
      print(controllers.length);
      controllers.forEach((key, controller) {
        if (key != null && controller.text.isNotEmpty) {
          var ids = key.split('_');
          var contestantId = ids[0];
          var criteriaId = ids[1];
          double score = 0;

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
              score = (parsedValue * percentage);
            }
          }

          if (!contestantScores.containsKey(contestantId)) {
            contestantScores[contestantId] = {};
          }
          contestantScores[contestantId]![criteriaId] = score;
        }
      });

      List<Map<String, dynamic>> submissionData =
          contestantScores.entries.map((entry) {
        var contestantId = entry.key;
        var scores = entry.value;
        var criteriaIds = scores.keys.toList();

        // Create a list of maps for criteriaScores
        List<dynamic> criteriaScores = criteriaIds.map((criteriaId) {
          return {
            "criteriaId": criteriaId,
            "scores": scores[criteriaId],
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
      // Step 3: Send Data to Server or Process Locally
      // Replace this URL with your actual endpoint
      var url = Uri.parse('https://tab-lu.vercel.app/scorecards');
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

      if (response.statusCode == 403) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('error')) {
          final errorMessage = responseBody['error'] as String;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      // Handle exceptions here
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
        Uri.parse('https://tab-lu.vercel.app/judges/$eventId/confirmed');
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
        'https://tab-lu.vercel.app/uploads/${contestantId}'); // Replace with your server URL
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final path = "https://tab-lu.vercel.app/uploads/";
        // Find the document that matches the contestant.id
        return path + data['filePath'];
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
                        return Image.network(
                          snapshot.data ??
                              '', // Replace with your server URL and actual filename
                          width: 200, // Set the desired width
                          height: 200, // Set the desired height
                          fit: BoxFit
                              .cover, // Adjust the BoxFit according to your needs
                        );
                      } else {
                        // You can return a placeholder or loading indicator here
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

  Widget buildContestantList(
      List<Contestant> contestants, List<Criteria>? criterias) {
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Score for ${criteria.criterianame}',
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
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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

  Future<String> fetchEventId() async {
    final String url = 'https://tab-lu.vercel.app/latest-event-id';
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
      final String eventId = widget.eventId;
      print('Fetched Event ID: $eventId');
      if (eventId.isNotEmpty) {
        final response = await http
            .get(Uri.parse("https://tab-lu.vercel.app/event/$eventId"));
        print('Event Details Response Status Code: ${response.statusCode}');
        if (response.statusCode == 200) {
          dynamic eventData = jsonDecode(response.body);
          if (eventData != null && eventData is Map<String, dynamic>) {
            final Event event = Event.fromJson(eventData);
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
            fetchContestants(eventId);
            fetchCriteria(eventId, onCriteriaFetched: () {
              print('Criteria fetched successfully');
            });
          } else {
            print(
                'Invalid event data format. Expected Map, but got: ${eventData.runtimeType}');
          }
        } else {
          throw Exception(
              'Failed to load event details. Status code: ${response.statusCode}');
        }
      } else {
        print('Event ID is empty.');
      }
    } catch (e) {
      print('Error in fetchEventDetails: $e');
    }
  }

  Future<void> fetchContestants(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse("https://tab-lu.vercel.app/events/$eventId/contestants"),
      );
      if (response.statusCode == 200) {
        final dynamic contestantData = jsonDecode(response.body);
        print('Fetched Contestant Data: $contestantData');
        if (contestantData != null && contestantData is List) {
          List<Contestant> fetchedContestants =
              contestantData.map((data) => Contestant.fromJson(data)).toList();

          // Fetch existing scores for each contestant and criteria
          for (var contestant in fetchedContestants) {
            try {
              List<double> existingScores =
                  await fetchExistingScoresForContestant(
                      contestant.id, eventId);

              // Check if the fetch is successful
              if (existingScores.isNotEmpty) {
                for (var criteria in criterias) {
                  String uniqueKey = "${contestant.id}_${criteria.criteriaId}";
                  controllers[uniqueKey] = TextEditingController(
                    text:
                        existingScores[criterias.indexOf(criteria)].toString(),
                  );
                }
              } else {
                for (var contestant in fetchedContestants) {
                  for (var criteria in criterias) {
                    String uniqueKey =
                        "${contestant.id}_${criteria.criteriaId}"; // Assuming each criteria has a unique id
                    controllers[uniqueKey] = TextEditingController();
                  }
                }
                // Handle the case where fetch is not successful

                print('Failed to fetch scores for contestant ${contestant.id}');
              }
            } catch (error) {
              // Handle any errors that occurred during the fetch operation
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
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      // Make a GET request to your server endpoint with contestantId and eventId as query parameters
      final Uri uri = Uri.parse(
          'https://tab-lu.vercel.app/scorecards'); // Update the URL accordingly
      final response = await http.get(
        uri.replace(queryParameters: {
          'contestantId': contestantId ?? '',
          'eventId': eventId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        // Extract the scores from the response
        final List<dynamic> scoresData = responseBody['scores'];
        final List<double> scores = scoresData.map<double>((score) {
          // Assuming the criteriascore is the value you want to extract
          return score['criteria']['criteriascore'].toDouble();
        }).toList();

        print("Contestant scores: $scores");

        // Optionally, you might want to update the UI or perform other actions here
        return scores;
      } else {
        // Handle error responses
        print('Failed to fetch scores. Status code: ${response.statusCode}');
        if (response.statusCode == 401) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.containsKey('error')) {
            final errorMessage = responseBody['error'] as String;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        print('Response body: ${response.body}');
        // You might want to throw an exception or handle the error accordingly
        return [];
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching scores: $e');
      // You might want to throw an exception or handle the error accordingly
      return [];
    }
  }

  Future<List<Criteria>> fetchCriteria(String eventId,
      {VoidCallback? onCriteriaFetched}) async {
    try {
      final response = await http
          .get(Uri.parse("https://tab-lu.vercel.app/events/$eventId/criteria"));
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

  //----------------------------------------------------------------------
// i added this line for the categories
// i have issues here.

  //------------------------------------------------------------

  Future<Map<String, dynamic>> fetchEventData(String eventId) async {
    final response =
        await http.get(Uri.parse('https://tab-lu.vercel.app/events/$eventId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> eventData = json.decode(response.body);
      return eventData;
    } else {
      throw Exception('Failed to load event data');
    }
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
              // var jsonResponse = json.decode(res.body);
              // var myToken = jsonResponse['token'];
              // prefs.setString('token', myToken);
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
      body: SingleChildScrollView(
          child: Container(
              child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 80,
            width: 500,
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
        SizedBox(
          height: 500,
          width: 1000,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
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
                          double percentage =
                              double.tryParse(criteria.percentage) ?? 0.0;
                          return Expanded(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(top: 5),
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
                            height: 50,
                            padding: const EdgeInsets.only(top: 5),
                            color: Colors.green,
                            alignment: Alignment.topCenter,
                            child: const Text(
                              'Info',
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
          child: Container(
            height: 600,
            width: 500,
            child: Card(
              child: Column(
                children: [
                  Container(
                    height: 35,
                    padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: judges.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(judges[index].name),
                          // Customize appearance as needed
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ]))),
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
// Widget buildCriteriaRow(String criterianame, String percentage) {
//   TextEditingController _scoreController = TextEditingController();
//   return Row(
//     children: [
//       Padding(
//         padding: const EdgeInsets.only(left: 20),
//         child: Text(
//           criterianame,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Colors.green,
//           ),
//         ),
//       ),
//       const SizedBox(width: 10), // Adjust the spacing as needed
//       Container(
//         width: 50, // Adjust the width as needed
//         child: Padding(
//           padding: const EdgeInsets.only(left: 20),
//           child: Text(
//             percentage, // Display the actual percentage value
//             style: const TextStyle(
//               color: Colors.green,
//             ),
//           ),
//         ),
//       ),

//       const SizedBox(width: 30),
//       Expanded(
//         child: Container(
//           height: 50,
//           width: 90,
//           child: TextField(
//             controller: _scoreController,
//             keyboardType: TextInputType.number,
//             onChanged: (score) {
//               print('onChanged - criteriaName: $criterianame');
//               setState(() {
//                 criteriaScore = int.tryParse(score) ?? 9;

//                 if (contestant != null) {
//                   if (criterianame != null) {
//                     getCriteriaScore(
//                       contestant!,
//                       criterianame,
//                       criteriaScore!,
//                     );
//                     int index = contestant.criterias.indexWhere(
//                       (criteria) =>
//                           criteria.criterianame.trim().toLowerCase() ==
//                           criterianame.trim().toLowerCase(),
//                     );

//                     if (index != -1) {
//                       contestant.criterias[index].score = criteriaScore!;
//                     } else {
//                       print(
//                         'Warning: No matching criteria found in the contestant\'s list.',
//                       );
//                       print(
//                         'List of criteria names in the contestant: ${contestant.criterias.map((c) => c.criterianame).toList()}',
//                       );
//                     }
//                     updateTotalScore(contestant!);
//                   } else {
//                     print(
//                       'Warning: criteriaName is null. Set a default value or handle this case.',
//                     );
//                   }
//                 } else {
//                   print('Warning: Contestant is null.');
//                 }
//               });
//             },
//             decoration: InputDecoration(
//               hintStyle: const TextStyle(
//                 color: Colors.grey,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 vertical: 10.0,
//                 horizontal: 15.0,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: const BorderSide(
//                   color: Color.fromARGB(255, 5, 70, 20),
//                   width: 2.0,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                   color: Colors.grey.withOpacity(0.5),
//                   width: 1.0,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
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
