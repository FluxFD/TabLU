import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/pages/judgescoresheet.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:tutorial/utility/sharedPref.dart';
import 'package:http/http.dart' as http;

class Event {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventEndDate;
  final String eventEndTime;
  final String eventId;
  final String judgeId;
  late String status = '';

  Event(this.eventName, this.eventDate, this.eventTime, this.eventEndDate,
      this.eventEndTime, this.eventId, this.judgeId) {
    // Initialize status based on the current date and event end date
    DateTime currentDate = DateTime.now();
    DateTime endDate = DateTime.parse(
        (eventEndDate != '') ? eventEndDate : DateTime.now().toString());
    status = endDate.isAfter(currentDate) ? 'Active' : 'Inactive';
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
      id: json['id'] ?? 'No ID', // Fallback to 'No ID' if null
      name: json['name'] ?? 'Score Sheet', // Fallback to 'No Name' if null
    );

    // Debug: Print the created Judge object.
    print("Created Judge: id=${judge.id}, name=${judge.name}");

    return judge;
  }
}

class EventsJoined extends StatefulWidget {
  const EventsJoined({Key? key}) : super(key: key);

  @override
  State<EventsJoined> createState() => _EventsJoinedState();
}

class _EventsJoinedState extends State<EventsJoined> {
  List<Event> eventsList = []; // Updated to store the fetched events
  late Judge currentJudge;

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    fetchData();
  }

  Future<String> fetchData() async {
    // Retrieve token using your method
    String? token = await SharedPreferencesUtils.retrieveToken();

    try {
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or empty');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];
      // Construct the URL with the userId as a query parameter
      String url =
          'https://tab-lu.onrender.com/get-all-judges-events?userId=$userId';

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the JSON response
        dynamic responseData = jsonDecode(response.body);
        Map<String, dynamic> judge = {};
        judge['id'] = responseData['events'][0]['_id'];
        judge['name'] = "Score Sheet";

        currentJudge = Judge.fromJson(judge);
        // Check if the data is a map with the "events" key
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('events')) {
          List<dynamic> eventsData = responseData['events'];
          // Convert the eventsData to a list of Event objects
          List<Event> events = eventsData
              .map((json) => Event(
                    json['eventId']['event_name'] ??
                        '', // Use empty string if 'event_name' is null
                    json['eventId']['event_date'] ??
                        '', // Use empty string if 'event_date' is null
                    json['eventId']['event_time'] ??
                        '', // Use empty string if 'event_time' is null
                    json['eventId']['event_end_date'] ?? '',
                    json['eventId']['event_end_time'] ?? '',
                    json['eventId']['_id'] ?? '',
                    json['_id'] ?? '', // Use empty string if '_id' is null
                  ))
              .toList();

          // Set the eventsList to the fetched events
          setState(() {
            eventsList = events;
          });

          // Return a success message or any other result
          return 'Data fetched successfully';
        } else {
          print('Invalid data format. Expected a map with "events" key.');
          return 'Invalid data format';
        }
      } else {
        // Handle errors
        print('Failed to fetch data. Error code: ${response.statusCode}');
        return 'Failed to fetch data';
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      return 'An error occurred';
    }
  }

  // List<Event> generateEventsList() {
  //   List<Event> events = [];
  //   for (int i = 1; i <= eventsList.length; i++) {
  //     events.add(
  //       Event(
  //         'Event $i',
  //         '10-10-10',
  //         'at 5:00pm',
  //         '65667e3ca0872db453cdae8d',
  //         '65667e3ca0872db453cdae8d'
  //       ),
  //     );
  //   }
  //   return events;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Joined Events',
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
      body: ListView.builder(
        itemCount: eventsList.length,
        itemBuilder: (context, index) {
          Event event = eventsList[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 3,
              child: Container(
                height: 200, // Adjust the height as needed
                child: ListTile(
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 21.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          event.eventName,
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(255, 5, 70, 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Start Date: ${event.eventDate.split("T")[0]} at ${event.eventTime}',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'End Date: ${event.eventEndDate.split("T")[0]} at ${event.eventEndTime}',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text('Status: ${event.status}'),
                        Text(
                          'Event Id: ${event.eventId}',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle join event logic
                                if (event.status == 'Active') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => JudgeScoreSheet(
                                          eventId: eventsList[index].eventId,
                                          eventData: {},
                                          judges: currentJudge),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Event is already done. Cannot access this event'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                // You can implement the logic to join the event here
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'View Event',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showCancelConfirmationDialog(event);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Delete Event',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> deleteEvent(String judgeId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://tab-lu.onrender.com/delete-judge/$judgeId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any other headers if needed
        },
      );

      if (response.statusCode == 200) {
        // Show a success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await fetchData();
        print('Event deleted successfully');
      } else {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to delete event. Error code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Failed to delete event. Error code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting event'),
          backgroundColor: Colors.red,
        ),
      );
      print('An error occurred while deleting judge: $error');
    }
  }

  // Function to show cancel confirmation dialog
  Future<void> _showCancelConfirmationDialog(Event event) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Event Confirmation',
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you really want to cancel this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm', style: TextStyle(color: Colors.green)),
              onPressed: () {
                // Handle cancel event logic
                // You can implement the logic to cancel the event here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
