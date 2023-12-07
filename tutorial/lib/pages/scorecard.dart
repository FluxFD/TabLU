import 'package:flutter/material.dart';
import 'package:tutorial/pages/finalscore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:tutorial/pages/searchevents.dart';

class Event {
  String eventId;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
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
  List<int?> criteriaScores;
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
      id: json['id'] != null ? json['id'].toString() : '',
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
  String criterianame;
  String percentage;
  String eventId; 
  int score;
  Criteria({
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    required this.score,
  });

  Criteria copyWith({
    String? criterianame,
    String? percentage,
    String? eventId,
    int? score,
  }) {
    return Criteria(
      criterianame: criterianame ?? this.criterianame,
      percentage: percentage ?? this.percentage,
      eventId: eventId ?? this.eventId,
      score: score ?? this.score,
    );
  }

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criterianame:
          json['criterianame'] != null ? json['criterianame'].toString() : '',
      percentage:
          json['percentage'] != null ? json['percentage'].toString() : '',
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      score: json['score'] != null ? int.parse(json['score'].toString()) : 0,
    );
  }
}

class User {
  final String username;

  User({required this.username});
}

class ScoreCard extends StatefulWidget {
  String eventId;
  final Map<String, dynamic> eventData;
 // final List<User> judges;

  ScoreCard({
    required this.eventId, 
    required this.eventData,
   // required this.judges

  });

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
  late List<Contestant> contestants;
  late List<Criteria> criteria;
  late Map<String, dynamic> eventData;
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
    contestant = Contestant(
      name: '',
      course: 'DefaultCourse',
      department: 'DefaultDepartment',
      eventId: '',
      totalScore: 0,
      criterias: [],
      criteriaScores: [],
    );
    calculateInitialTotalScores();
    criterianame = "InitialValue";

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
      _contestants[index].criteriaScores =
          _contestants[index].criterias.map((criteria) => criteria.score).toList();
    }

    print('Updated criteria score for ${contestant.name}: ${matchingCriteria.score}');
    return matchingCriteria.score;
  } catch (e) {
    print('Matching criteria not found for: $criteriaName');
    // Handle specific exceptions if needed
    return null;
  }
}

void updateTotalScore(Contestant contestant) {
  print('Before updating total score: ${contestant.criteriaScores}');

  int totalScore = contestant.criteriaScores.isNotEmpty
      ? contestant.criteriaScores.fold(0, (sum, score) => sum + (score ?? 0))
      : 0;

  setState(() {
    contestant.totalScore = totalScore;
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


  void showEditDialog(
    BuildContext context,
    Contestant contestant,
    List<Criteria> criterias,
    Function(List<Contestant>) onCloseCallback,
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
              'Score Card',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 5, 70, 20),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 250,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        child: Image.asset(
                          'assets/icons/aubrey.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          '${contestant.name}',
                          style: const TextStyle(
                            fontSize: 23,
                            color: Color.fromARGB(255, 5, 70, 20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 400,
                  width: 500,
                  child: Card(
                    child: Container(
                      child: Column(
                        children: [
                          Table(
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    height: 33,
                                    width: 100,
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.green,
                                    alignment: Alignment.center,
                                    child: const Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Criteria',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 33,
                                    width: 100,
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.green,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Score',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children: [
                              buildCriteriaList(criterias),
                              const SizedBox(height: 20),
                            ],
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
                for (var c in _contestants) {
                  updateTotalScore(c);
                }
                onCloseCallback(_contestants);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget buildContestantList(List<Contestant> contestants) {
    return Expanded(
      child: ListView.builder(
        itemCount: contestants.length,
        itemBuilder: (BuildContext context, int index) {
          Contestant contestant = contestants[index];
          //  int totalScore = 0;
          return Container(
            height: 80, 
            child: Card(
              elevation: 1.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 75), 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        contestant.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 33,
                      padding: const EdgeInsets.only(top: 5),
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Text(
                            contestant.criteriaScores
                                .fold(0, (sum, score) => sum + (score ?? 0))
                                .toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showEditDialog(
                        context,
                        contestant,
                        criterias,
                        (List<Contestant> updatedContestants) {
                          setState(() {
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Future<String> fetchEventId() async {
    final String url = 'http://10.0.2.2:8080/latest-event-id';
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
      final String eventId = await fetchEventId();
      print('Fetched Event ID: $eventId');
      if (eventId.isNotEmpty) {
        final response =
            await http.get(Uri.parse("http://10.0.2.2:8080/events/$eventId"));
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
             // 'accessCode': event.accessCode,
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
        Uri.parse("http://10.0.2.2:8080/events/$eventId/contestants"),
      );
      if (response.statusCode == 200) {
        final dynamic contestantData = jsonDecode(response.body);
        print('Fetched Contestant Data: $contestantData');
        if (contestantData != null && contestantData is List) {
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

  Future<List<Criteria>> fetchCriteria(String eventId,
      {VoidCallback? onCriteriaFetched}) async {
    try {
      final response = await http
          .get(Uri.parse("http://10.0.2.2:8080/events/$eventId/criteria"));
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

  void main() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
        future: fetchEventId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final String eventId = snapshot.data ?? 'default_event_id';
            return ScoreCard(eventId: eventId, eventData: eventData, );//judges: [],);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }

  //----------------------------------------------------------------------
// i added this line for the categories
// i have issues here.

  //------------------------------------------------------------

  Future<Map<String, dynamic>> fetchEventData(String eventId) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

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
              onPressed: () {
   // var jsonResponse = json.decode(res.body);
   // var myToken = jsonResponse['token'];
   // prefs.setString('token', myToken);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchEvents(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTY2N2UzY2EwODcyZGI0NTNjZGFlOGQiLCJlbWFpbCI6ImF1YnJleWRhbm83QGdtYWlsLmNvbSIsInVzZXJuYW1lIjoiYWRtaW4xMjMiLCJpYXQiOjE3MDE1NjMzMDgsImV4cCI6MTcwMTU2NjkwOH0.lTl3R223HHLxj-vO1dJ1ulmGT1kPLOb2El_U-XZB1t4"),
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
          width: 500,
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
                            height: 33,
                            padding: const EdgeInsets.only(top: 5),
                            color: Colors.green,
                            alignment: Alignment.topCenter,
                            child: const Text(
                              'Number',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 33,
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
                        Expanded(
                          child: Container(
                            height: 33,
                            padding: const EdgeInsets.only(top: 5),
                            color: Colors.green,
                            alignment: Alignment.topCenter,
                            child: const Text(
                              'Total Score',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 33,
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
                    buildContestantList(_contestants),
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
        /*  Expanded(
            child: ListView.builder(
              itemCount: widget.judges.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.judges[index].username),
                  // Customize appearance as needed
                );
              },
            ),)*/
            
            ],),),),),

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
              title: const Center(child: Text('Event Information',
              style: TextStyle(
                fontSize: 18),)),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('${events.isNotEmpty ? events[0]?.eventName ?? '' : ''}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20
                  ),
                  )),
                  
                     Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Event ID: ${events.isNotEmpty ? events[0]?.eventId ?? '' : ''}',
                      style: TextStyle(fontSize: 10),
                      
                      ),
                      IconButton(
                icon: const Icon(Icons.copy, size: 22,),
                onPressed: () {
               Clipboard.setData(new ClipboardData(text: '${events.isNotEmpty ? events[0]?.eventId ?? '' : ''}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event ID copied to clipboard'),
                    ),
                          );
                        },
                      ),
                    ],
                  ),
                  Text('Date & Time: ${events.isNotEmpty ? events[0]?.eventDate ?? '' : ''}, ${events.isNotEmpty ? events[0]?.eventTime ?? '' : ''}', style: 
                  TextStyle(fontSize: 14)
                  ),
                  SizedBox(height: 10,),
                  Text('Category: ${events.isNotEmpty ? events[0]?.eventCategory ?? '' : ''}'),
                    SizedBox(height: 10,),
               
               Text('Venue: ${events.isNotEmpty ? events[0]?.eventVenue ?? '' : ''}'),
                      SizedBox(height: 10,),
                 Text('Organizer: ${events.isNotEmpty ? events[0]?.eventOrganizer ?? '' : ''}'),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Winner(),
                  ),
                );
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
  Widget buildCriteriaList(List<Criteria> criterias) {
    return Column(
      children: criterias.map((criteria) {
        return Column(
          children: [
            buildCriteriaRow(criteria.criterianame),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
  Widget buildCriteriaRow(String criterianame) {
    TextEditingController _scoreController = TextEditingController();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            criterianame,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 100),
        Expanded(
          child: Container(
            height: 45,
            width: 90,
            child: TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              onChanged: (score) {
                print('onChanged - criteriaName: $criterianame');
                setState(() {
                  criteriaScore = int.tryParse(score) ?? 0;

                  if (contestant != null) {
                    if (criterianame != null) {
                      getCriteriaScore(
                          contestant!, criterianame, criteriaScore!);
                      int index = contestant.criterias.indexWhere(
                        (criteria) =>
                            criteria.criterianame.trim().toLowerCase() ==
                            criterianame.trim().toLowerCase(),
                      );

                      if (index != -1) {
                        contestant.criterias[index].score = criteriaScore!;
                      } else {
                        print(
                            'Warning: No matching criteria found in the contestant\'s list.');
                        print(
                            'List of criteria names in the contestant: ${contestant.criterias.map((c) => c.criterianame).toList()}');
                      }
                      updateTotalScore(contestant!);
                    } else {
                      print(
                          'Warning: criteriaName is null. Set a default value or handle this case.');
                    }
                  } else {
                    print('Warning: Contestant is null.');
                  }
                });
              },
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 5, 70, 20),
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
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