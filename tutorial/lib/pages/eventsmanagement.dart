// TO BE FIXED 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/pages/eventInfo.dart';
import 'package:tutorial/pages/globals.dart';
import 'package:tutorial/pages/searchevents.dart';


class EventsManagement extends StatefulWidget {
  const EventsManagement({Key? key}) : super(key: key);

  @override
  State<EventsManagement> createState() => _EventsManagementState();
}

class Event {
  final String eventName;
  final String eventId;
  final String eventCategory;
  final String eventOrganizer;
  final String eventVenue;

  Event({
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
    );
  }
}


class _EventsManagementState extends State<EventsManagement> {
    Future<List<Event>> fetchEventData(String eventId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

      if (response.statusCode == 200) {
        final List<dynamic> eventDataList = json.decode(response.body);
        final List<Event> events = eventDataList.map((eventData) {
          return Event.fromJson(eventData);
        }).toList();
        return events;
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
        builder: (context) => SearchEvents(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTY2N2UzY2EwODcyZGI0NTNjZGFlOGQiLCJlbWFpbCI6ImF1YnJleWRhbm83QGdtYWlsLmNvbSIsInVzZXJuYW1lIjoiYWRtaW4xMjMiLCJpYXQiOjE3MDE1NjMzMDgsImV4cCI6MTcwMTU2NjkwOH0.lTl3R223HHLxj-vO1dJ1ulmGT1kPLOb2El_U-XZB1t4")
      ),
           );
          },
        ),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchEventData("65667e3ca0872db453cdae8d"),
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
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text('Status: Active'),
                          ),
                          SizedBox(height: 4),
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
