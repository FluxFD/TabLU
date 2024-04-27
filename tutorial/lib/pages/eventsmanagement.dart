// TO BE FIXED
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tutorial/pages/chart.dart';
import 'package:tutorial/pages/editnavigation.dart';
import 'package:tutorial/pages/eventinfo.dart';
import 'package:tutorial/pages/globals.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:tutorial/utility/sharedPref.dart';

class EventsManagement extends StatefulWidget {
  const EventsManagement({Key? key}) : super(key: key);

  @override
  State<EventsManagement> createState() => _EventsManagementState();
}

class Event {
  final String eventName;
  final String eventTime;
  final String eventDate;
  final String eventId;
  final String eventCategory;
  final String eventOrganizer;
  final String eventVenue;

  Event({
    required this.eventDate,
    required this.eventTime,
    required this.eventName,
    required this.eventId,
    required this.eventCategory,
    required this.eventOrganizer,
    required this.eventVenue,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['event_name'] ?? 'Default Event Name',
      eventId: json['_id'] ?? '',
      eventCategory: json['event_category'] ?? 'Default Category',
      eventOrganizer: json['event_organizer'] ?? 'Default Organizer',
      eventVenue: json['event_venue'] ?? 'Default Venue',
      eventDate: json['event_date'] ?? 'Default Date',
      eventTime: json['event_time'] ?? 'Default Time',
    );
  }
}

class Judge {
  final String id;
  final String name;
  bool isConfirm;

  Judge({
    required this.id,
    required this.name,
    required this.isConfirm,
  });

  factory Judge.fromJson(Map<String, dynamic> json) {
    print("Judge JSON: $json");

    var judge = Judge(
      id: json['_id'] ?? 'No ID',
      name: json['userId']?['username'] ?? 'No Name',
      isConfirm:
      json['isConfirm'] ?? false, // Fallback to false if null
    );

    print("Created Judge: id=${judge.id}, name=${judge.name}");

    return judge;
  }
}

class _EventsManagementState extends State<EventsManagement> {
  String? token;
  List<Event> events = [];
  late Future<List<Event>> eventsFuture;

  void initState() {
    super.initState();
    events = [];
    eventsFuture = fetchAllEvents();
  }

  Future<List<Event>> fetchEventData(String eventId) async {
    token = await SharedPreferencesUtils.retrieveToken();
    try {
      final response =
          await http.get(Uri.parse('http://192.168.101.6:8080/api/events'));
      if (response.statusCode == 200) {
        final dynamic eventData = json.decode(response.body);
        print(eventData);
        if (eventData is List) {
          // If the response is a list, directly return the list of events
          return eventData.map((event) => Event.fromJson(event)).toList();
        } else if (eventData is Map<String, dynamic>) {
          // If the response is a single event, wrap it in a list
          return [Event.fromJson(eventData)];
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        print('API Error: Status Code ${response.statusCode}');
        print('API Error Body: ${response.body}');
        throw Exception(
            'Failed to load event data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchEventData: $e');
      throw Exception('Failed to load event data. Error: $e');
    }
  }

  Future<List<Event>> fetchAllEvents() async {
    try {
      // Retrieve the token from shared preferences
      String? token = await SharedPreferencesUtils.retrieveToken();
      if (token == null) {
        print('No token found in shared preferences');
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse("http://192.168.101.6:8080/user-events");
      final response = await http.get(
        url,
        // Include the Authorization header with the token
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> eventsJson = jsonDecode(response.body);
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        print('Error fetching events: ${response.body}');
        throw Exception('Failed to load events. Error: ${response.body}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to load events. Error: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    // Show a confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancellation
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to indicate confirmation
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // If deletion is confirmed, proceed with the deletion
    if (deleteConfirmed == true) {
      try {
        final url = Uri.parse("http://192.168.101.6:8080/api/event/$eventId");
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          setState(() {
            eventsFuture = fetchAllEvents();
          });
          print('Event deleted successfully');
          // Reload the events after deletion
        } else {
          print('Error deleting event: ${response.body}');
          throw Exception('Failed to delete event. Error: ${response.body}');
        }
      } catch (e) {
        print('Error deleting event: $e');
        throw Exception('Failed to delete event. Error: $e');
      }
    }
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
      bool judgesJoined = judges.isNotEmpty && judges.every((judge) => judge.isConfirm == true);
      return judgesJoined;
    } else {
      throw Exception('Failed to load judges');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          title: const Text(
            'Events Management',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 5, 78, 7),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 5, 78, 7),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => SearchEvents(token: token)),
              );
            },
          ),
        ),
        body: FutureBuilder<List<Event>>(
          future: eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading events'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No events available'));
            } else {
              events = snapshot.data!;

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Card(
                    child: ListTile(
                      title: Text(event.eventName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Status: Active'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  bool judgesScoreSubmitted = await fetchJudgesScoreSubmitted(events[index].eventId);
                                  if (!judgesScoreSubmitted) {
                                    isAdding = false;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditNavigation(
                                          eventId: events[index].eventId,
                                          isEdit: true,
                                        ),
                                      ),
                                    );
                                  }else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text("Can't edit event. Judges have already joined."),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  // Call the delete function when the delete button is pressed
                                  deleteEvent(events[index].eventId);
                                },
                                icon: Icon(Icons.delete),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScoreCard(
                                        eventId: events[index].eventId,
                                        eventData: {},
                                        judges: [],
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChartData(
                                        eventId: events[index].eventId,
                                        eventCategory: events[index].eventCategory,
                                        judges: [],
                                        title: '',
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.align_vertical_bottom_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoreCard(
                              eventId: events[index].eventId,
                              eventData: {},
                              judges: [],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateEventScreen()));
          },
        ));
  }

  void _navigateToBlankPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => BlankPage()));
  }
}

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'View Event',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 5, 78, 7),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 5, 78, 7),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(),
    );
  }
}
