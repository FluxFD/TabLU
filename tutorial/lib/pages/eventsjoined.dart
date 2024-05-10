import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/pages/judgescoresheet.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:tutorial/utility/sharedPref.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Event {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventEndDate;
  final String eventEndTime;
  final String eventId;
  final String judgeId;
  late String status = '';

  Event(
    this.eventName,
    this.eventDate,
    this.eventTime,
    this.eventEndDate,
    this.eventEndTime,
    this.eventId,
    this.judgeId,
  ) {
    // Initialize status based on the current date, time, and event end date, time
    DateTime currentDateTime = DateTime.now();
    DateTime endDateTime = _parseDateTime(eventEndDate, eventEndTime);

    status = endDateTime.isAfter(currentDateTime) ? 'Active' : 'Inactive';
  }

  DateTime _parseDateTime(String date, String time) {
    // Parse date and time manually
    List<String> dateParts = date.split('-');
    List<String> timeParts = time.split(':');

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2].substring(0, 2));

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(' ')[0]);

    String period = timeParts[1].split(' ')[1];

    if (period == 'PM' && hour < 12) {
      hour += 12;
    }

    return DateTime(year, month, day, hour, minute);
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
  bool isLoading = true; // Track loading state
  late Timer _timer = Timer(Duration.zero, () {}); // Initialize with a dummy value



  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Refresh data every minute
      print("30 seconds have passed");
      fetchData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }


  Future<String> fetchData() async {
    // Retrieve token using your method
    String? token = await SharedPreferencesUtils.retrieveToken();

    try {
      setState(() {
        isLoading = true; // Set loading state to true before fetching
      });
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or empty');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];
      // Construct the URL with the userId as a query parameter
      String url =
          'https://tabluprod.onrender.com/get-all-judges-events?userId=$userId';

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
        // Check if responseData['events'] is null or empty
        if (responseData['events'] == null ||
            (responseData['events'] as Iterable).isEmpty) {
          // Handle the case where there are no events
          print('No events found.');
          setState(() {
            isLoading = false; // Set loading state to true before fetching
          });
          return 'No events found';
        }
        judge['id'] = responseData['events'][0]['_id'];
        judge['name'] = "Score Sheet";

        currentJudge = Judge.fromJson(judge);
        // Check if the data is a map with the "events" key
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('events')) {
          List<dynamic> eventsData = responseData['events'];
          // print(eventsData);
          // Convert the eventsData to a list of Event objects
          List<Event> events = eventsData
              .where((json) => json['eventId'] != null) // Filter out entries where eventId is null
              .map<Event>((json) {
            var eventId = json['eventId'];
            return Event(
              eventId['event_name'] ?? 'Event Name Not Available',
              eventId['event_date'] ?? 'Event Date Not Available',
              eventId['event_time'] ?? 'Event Time Not Available',
              eventId['event_end_date'] ?? 'Event End Date Not Available',
              eventId['event_end_time'] ?? 'Event End Time Not Available',
              eventId['_id'] ?? 'Event ID Not Available',
              json['_id'] ?? 'ID Not Available',
            );
          }).toList();

          print(events);


          // Set the eventsList to the fetched events
          setState(() {
            eventsList = events;
          });
          setState(() {
            isLoading = false; // Set loading state to true before fetching
          });
          // Return a success message or any other result
          return 'Data fetched successfully';
        } else {
          setState(() {
            isLoading = false; // Set loading state to true before fetching
          });
          print('Invalid data format. Expected a map with "events" key.');
          return 'Invalid data format';
        }
      } else {
        setState(() {
          isLoading = false; // Set loading state to true before fetching
        });
        // Handle errors
        print('Failed to fetch data. Error code: ${response.statusCode}');
        return 'Failed to fetch data';
      }
    } catch (e) {
      // Handle exceptions
      setState(() {
        isLoading = false; // Set loading state to true before fetching
      });
      print('Error: $e');
      return 'An error occurred';
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : eventsList.isEmpty
          ? Center(child: Text("No events joined"))
          :ListView.builder(
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
                                onPressed: event.status == 'Active'
                                    ? () {
                                  // Handle join event logic
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => JudgeScoreSheet(
                                        eventId: eventsList[index].eventId,
                                        eventData: {},
                                        judges: currentJudge,
                                      ),
                                    ),
                                  );
                                }
                                    : null, // Set onPressed to null if event is inactive
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
                              // ElevatedButton(
                              //   onPressed: () {
                              //     _showCancelConfirmationDialog(event);
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     primary: Colors.red,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(20),
                              //     ),
                              //   ),
                              //   child: Text(
                              //     'Delete Event',
                              //     style: TextStyle(color: Colors.white),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Future<void> deleteEvent(String judgeId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://tabluprod.onrender.com/delete-judge/$judgeId'),
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
