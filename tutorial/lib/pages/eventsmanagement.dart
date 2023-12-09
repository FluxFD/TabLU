// TO BE FIXED 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tutorial/pages/eventInfo.dart';
import 'package:tutorial/pages/globals.dart';
import 'package:tutorial/pages/searchevents.dart';

import '../main.dart';


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
      eventName: json['eventName'] ?? 'Default Event Name',
      eventId: json['eventId'] ?? '',
      eventCategory: json['eventCategory'] ?? 'Default Category',
      eventOrganizer: json['eventOrganizer'] ?? 'Default Organizer',
      eventVenue: json['eventVenue'] ?? 'Default Venue',
      eventDate: json['eventDate'] ?? 'Default Date',
      eventTime: json['eventTime'] ?? 'Default Time',
    );
  }
}


class _EventsManagementState extends State<EventsManagement> {
  Future<List<Event>> fetchEventData(String eventId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

      if (response.statusCode == 200) {
        final dynamic eventData = json.decode(response.body);

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
        throw Exception('Failed to load event data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchEventData: $e');
      throw Exception('Failed to load event data. Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    String token = Provider.of<TokenProvider>(context).token;
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
        builder: (context) => SearchEvents(token: token)
      ),
           );
          },
        ),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchEventData("65729927141361b0d05d1fc8"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading events'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available'));
          } else {
            List<Event> events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(event.eventName),
                      subtitle: Text(''), // Add actual event details if available
                      onTap: () {
                        _navigateToBlankPage();
                      },
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text('Status: Active'),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  isAdding = false;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CreateEventScreen(),
                                    ),
                                  );

                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  _navigateToBlankPage();
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateEventScreen()));
  },
     )

              );     
  }
  void _navigateToBlankPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BlankPage()));
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
