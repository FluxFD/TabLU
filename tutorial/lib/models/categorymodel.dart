import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/models/codemodel.dart' as CodeModel;
import 'dart:convert';
import 'package:tutorial/pages/scorecard.dart';

class PageantsScreen extends StatefulWidget {
  final CodeModel.Event event;
  PageantsScreen({required this.event});
  @override
  State<PageantsScreen> createState() => _PageantsScreenState();
}

class _PageantsScreenState extends State<PageantsScreen> {
  late Map<String, dynamic> eventData;
  late Future<List<dynamic>> pageantEvents = fetchPageantEvents();

  @override
  void initState() {
    super.initState();
    pageantEvents = fetchPageantEvents();
  }

  Future<List<dynamic>> fetchPageantEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/pageant-events'));

    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      events.sort((a, b) {
        DateTime dateA = DateTime.parse(a['event_date']);
        DateTime dateB = DateTime.parse(b['event_date']);
        return dateA.compareTo(dateB);
      });
      print('Pageant Events in Flutter: $events');
      return events;
    } else {
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load pageant events');
    }
  }

  void deleteEvent(String? eventId, BuildContext context) async {
    print('Deleting event with eventId: $eventId');
    if (eventId == null) {
      // Handle the case where eventId is null (optional: show a message)
      return;
    }
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        showLoadingIndicator(context);

        final response = await http
            .delete(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

        Navigator.of(context).pop();
        print('DELETE Request Status Code: ${response.statusCode}');
        print('DELETE Request Response: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            pageantEvents = fetchPageantEvents();
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event deleted successfully.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          print('Error deleting event: ${response.statusCode}');
          showErrorMessage(context);
        }
      } catch (error) {
        print('Exception during deletion: $error');
        showErrorMessage(context);
      }
    }
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error deleting event. Please try again.'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Pageants',
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
      body: FutureBuilder<List<dynamic>>(
        future: pageantEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                print('Event data: ${snapshot.data![index]}');
                return PageantItem(
                  event: snapshot.data![index],
                  onDelete: () {
                    print('Deleting event at index $index');
                    dynamic eventData = snapshot.data![index];
                    print('Event data: $eventData');
                    String? eventId = eventData['_id'] as String?;
                    print('Event ID: $eventId');
                    deleteEvent(eventId, context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PageantItem extends StatelessWidget {
  final dynamic event;
  final VoidCallback onDelete;

  const PageantItem({Key? key, required this.event, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Container();
    }
    final event_name = event['event_name'] as String? ?? 'No Event Name';

    final event_date = event['event_date'] != null
        ? event['event_date'] as String
        : 'No Event Date';
    final event_time = event['event_time'] != null
        ? event['event_time'] as String
        : 'No Event Time';
    final access_code = event['access_code'] != null
        ? event['access_code'] as String
        : 'No Event Time';
    return Card(
      color: Colors.green[50],
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 40.0),
        dense: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                event_name.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                '$event_date at $event_time',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            /*Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Access Code: ',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    TextSpan(
                      text: access_code,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),*/
          ],
        ),
        onTap: () {
          try {
            // Handle item tap if needed
            if (event != null && event['event_name'] != null) {
              print('Tapped on ${event['event_name']}');

              // Add additional null checks for event_id
              final event_id =
                  event['_id'] != null ? event['_id'] as String : '';
              final eventData = {
                'eventName': event['event_name'],
                'eventDate': event['event_date'],
                'eventTime': event['event_time'],
                'accessCode': event['acces_code'],
                'eventVenue': event['event_venue'],
                'eventOrganizer': event['event_organizer']
              };

              if (eventData.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreCard(
                      eventId: event_id,
                      eventData: eventData,
                  //    judges: [],
                    ),
                  ),
                );
              } else {
                // Handle the case where eventData is null
                print('eventData is null. Cannot navigate to ScoreCard.');
              }
            }
          } catch (e, stackTrace) {
            print('Error in onTap: $e\n$stackTrace');
          }
        },
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


// -------------------------------------------------------------------//
// THIS IS FOR THE TALENT SHOW PAGE
class TalentShowsScreen extends StatefulWidget {
  final CodeModel.Event talentevent;
  TalentShowsScreen({required this.talentevent});

  @override
  State<TalentShowsScreen> createState() => _TalentShowsScreenState();
}
class _TalentShowsScreenState extends State<TalentShowsScreen> {
late Map<String, dynamic> eventData;
  late Future<List<dynamic>> talentEvents = fetchTalentEvents();

  @override
  void initState() {
    super.initState();
    talentEvents = fetchTalentEvents();
  }

  Future<List<dynamic>> fetchTalentEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/talent-events'));

    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      events.sort((a, b) {
        DateTime dateA = DateTime.parse(a['event_date']);
        DateTime dateB = DateTime.parse(b['event_date']);
        return dateA.compareTo(dateB);
      });
      print('Pageant Events in Flutter: $events');
      return events;
    } else {
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load pageant events');
    }
  }

  void deleteEvent(String? eventId, BuildContext context) async {
    print('Deleting event with eventId: $eventId');
    if (eventId == null) {
      // Handle the case where eventId is null (optional: show a message)
      return;
    }
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        showLoadingIndicator(context);

        final response = await http
            .delete(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

        Navigator.of(context).pop();
        print('DELETE Request Status Code: ${response.statusCode}');
        print('DELETE Request Response: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            talentEvents = fetchTalentEvents();
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event deleted successfully.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          print('Error deleting event: ${response.statusCode}');
          showErrorMessage(context);
        }
      } catch (error) {
        print('Exception during deletion: $error');
        showErrorMessage(context);
      }
    }
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error deleting event. Please try again.'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Talent Shows',
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
      body: FutureBuilder<List<dynamic>>(
        future: talentEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                print('Event data: ${snapshot.data![index]}');
                return PageantItem(
                  event: snapshot.data![index],
                  onDelete: () {
                    print('Deleting event at index $index');
                    dynamic eventData = snapshot.data![index];
                    print('Event data: $eventData');
                    String? eventId = eventData['_id'] as String?;
                    print('Event ID: $eventId');
                    deleteEvent(eventId, context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class TalentShowItem extends StatelessWidget {
  final dynamic talentShowevent;
  final VoidCallback onDelete;

  const TalentShowItem({Key? key, required this.talentShowevent, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (talentShowevent == null) {
      return Container();
    }
    final event_name = talentShowevent['event_name'] as String? ?? 'No Event Name';

    final event_date = talentShowevent['event_date'] != null
        ? talentShowevent['event_date'] as String
        : 'No Event Date';
    final event_time = talentShowevent['event_time'] != null
        ? talentShowevent['event_time'] as String
        : 'No Event Time';
    final access_code = talentShowevent['access_code'] != null
        ? talentShowevent['access_code'] as String
        : 'No Event Time';
    return Card(
      color: Colors.green[50],
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 40.0),
        dense: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                event_name.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                '$event_date at $event_time',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Event Key: ',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    TextSpan(

                    //  text: 'Event ID: $eventId',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          try {
            // Handle item tap if needed
            if (talentShowevent != null && talentShowevent['event_name'] != null) {
              print('Tapped on ${talentShowevent['event_name']}');

              // Add additional null checks for event_id
              final event_id =
                  talentShowevent['_id'] != null ? talentShowevent['_id'] as String : '';
              final eventData = {
                'eventName': talentShowevent['event_name'] ?? '',
                'eventDate': talentShowevent['event_date']?? '',
                'eventTime': talentShowevent['event_time']?? '',
                'accessCode': talentShowevent['acces_code']?? '',
                'eventVenue': talentShowevent['event_venue']?? '',
                'eventOrganizer': talentShowevent['event_organizer'] ?? ''
              };

              if (eventData.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreCard(
                      eventId: event_id,
                      eventData: eventData,
                  //   judges: [],
                    ),
                  ),
                );
              } else {
                // Handle the case where eventData is null
                print('eventData is null. Cannot navigate to ScoreCard.');
              }
            }
          } catch (e, stackTrace) {
            print('Error in onTap: $e\n$stackTrace');
          }
        },
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


class DebatesScreen extends StatefulWidget {
   final CodeModel.Event debateevent;
  DebatesScreen({required this.debateevent});
  @override
  State<DebatesScreen> createState() => _DebatesScreenState();
}

class _DebatesScreenState extends State<DebatesScreen> {
  late Map<String, dynamic> eventData;
  late Future<List<dynamic>> debateevent= fetchDebateEvents();

  @override
  void initState() {
    super.initState();
    debateevent = fetchDebateEvents();
  }

  Future<List<dynamic>> fetchDebateEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/debate-events'));

    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      events.sort((a, b) {
        DateTime dateA = DateTime.parse(a['event_date']);
        DateTime dateB = DateTime.parse(b['event_date']);
        return dateA.compareTo(dateB);
      });
      print('Pageant Events in Flutter: $events');
      return events;
    } else {
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load pageant events');
    }
  }

  void deleteEvent(String? eventId, BuildContext context) async {
    print('Deleting event with eventId: $eventId');
    if (eventId == null) {
      // Handle the case where eventId is null (optional: show a message)
      return;
    }
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        showLoadingIndicator(context);

        final response = await http
            .delete(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

        Navigator.of(context).pop();
        print('DELETE Request Status Code: ${response.statusCode}');
        print('DELETE Request Response: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            debateevent = fetchDebateEvents();
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event deleted successfully.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          print('Error deleting event: ${response.statusCode}');
          showErrorMessage(context);
        }
      } catch (error) {
        print('Exception during deletion: $error');
        showErrorMessage(context);
      }
    }
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error deleting event. Please try again.'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Debates',
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
      body: FutureBuilder<List<dynamic>>(
        future: debateevent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                print('Event data: ${snapshot.data![index]}');
                return PageantItem(
                  event: snapshot.data![index],
                  onDelete: () {
                    print('Deleting event at index $index');
                    dynamic eventData = snapshot.data![index];
                    print('Event data: $eventData');
                    String? eventId = eventData['_id'] as String?;
                    print('Event ID: $eventId');
                    deleteEvent(eventId, context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DebateItem extends StatelessWidget {
  final dynamic debateevent;
  final VoidCallback onDelete;

  const DebateItem({Key? key, required this.debateevent, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (debateevent == null) {
      return Container();
    }
    final event_name = debateevent['event_name'] as String? ?? 'No Event Name';

    final event_date = debateevent['event_date'] != null
        ? debateevent['event_date'] as String
        : 'No Event Date';
    final event_time = debateevent['event_time'] != null
        ? debateevent['event_time'] as String
        : 'No Event Time';
    final access_code = debateevent['access_code'] != null
        ? debateevent['access_code'] as String
        : 'No Event Time';
    return Card(
      color: Colors.green[50],
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 40.0),
        dense: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                event_name.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                '$event_date at $event_time',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Access Code: ',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    TextSpan(
                      text: access_code,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          try {
            // Handle item tap if needed
            if (debateevent != null && debateevent['event_name'] != null) {
              print('Tapped on ${debateevent['event_name']}');

              // Add additional null checks for event_id
              final event_id =
                  debateevent['_id'] != null ? debateevent['_id'] as String : '';
              final eventData = {
                'eventName': debateevent['event_name'] ?? '',
                'eventDate': debateevent['event_date']?? '',
                'eventTime': debateevent['event_time']?? '',
                'accessCode': debateevent['acces_code']?? '',
                'eventVenue': debateevent['event_venue']?? '',
                'eventOrganizer': debateevent['event_organizer'] ?? ''
              };

              if (eventData.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreCard(
                      eventId: event_id,
                      eventData: eventData,
                 //     judges: [],
                    ),
                  ),
                );
              } else {
                // Handle the case where eventData is null
                print('eventData is null. Cannot navigate to ScoreCard.');
              }
            }
          } catch (e, stackTrace) {
            print('Error in onTap: $e\n$stackTrace');
          }
        },
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


class ArtContestScreen extends StatefulWidget {
     final CodeModel.Event artcontestevent;
  ArtContestScreen({required this.artcontestevent});
  @override
  State<ArtContestScreen> createState() => _ArtContestScreenState();
}

class _ArtContestScreenState extends State<ArtContestScreen> {
  late Map<String, dynamic> eventData;
  late Future<List<dynamic>> artcontestevent= fetchArtContestEvents();

  @override
  void initState() {
    super.initState();
    artcontestevent = fetchArtContestEvents();
  }

  Future<List<dynamic>> fetchArtContestEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/artcontest-events'));

    if (response.statusCode == 200) {
      final List<dynamic> events = json.decode(response.body);
      events.sort((a, b) {
        DateTime dateA = DateTime.parse(a['event_date']);
        DateTime dateB = DateTime.parse(b['event_date']);
        return dateA.compareTo(dateB);
      });
      print('Pageant Events in Flutter: $events');
      return events;
    } else {
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load pageant events');
    }
  }

  void deleteEvent(String? eventId, BuildContext context) async {
    print('Deleting event with eventId: $eventId');
    if (eventId == null) {
      // Handle the case where eventId is null (optional: show a message)
      return;
    }
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        showLoadingIndicator(context);

        final response = await http
            .delete(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

        Navigator.of(context).pop();
        print('DELETE Request Status Code: ${response.statusCode}');
        print('DELETE Request Response: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            artcontestevent = fetchArtContestEvents();
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event deleted successfully.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          print('Error deleting event: ${response.statusCode}');
          showErrorMessage(context);
        }
      } catch (error) {
        print('Exception during deletion: $error');
        showErrorMessage(context);
      }
    }
  }

  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error deleting event. Please try again.'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Art Contests',
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
      body: FutureBuilder<List<dynamic>>(
        future: artcontestevent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                print('Event data: ${snapshot.data![index]}');
                return PageantItem(
                  event: snapshot.data![index],
                  onDelete: () {
                    print('Deleting event at index $index');
                    dynamic eventData = snapshot.data![index];
                    print('Event data: $eventData');
                    String? eventId = eventData['_id'] as String?;
                    print('Event ID: $eventId');
                    deleteEvent(eventId, context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

  

class ArtContestItem extends StatelessWidget {
  final dynamic artcontestevent;
  final VoidCallback onDelete;

  const ArtContestItem({Key? key, required this.artcontestevent, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (artcontestevent == null) {
      return Container();
    }
    final event_name = artcontestevent['event_name'] as String? ?? 'No Event Name';

    final event_date = artcontestevent['event_date'] != null
        ? artcontestevent['event_date'] as String
        : 'No Event Date';
    final event_time = artcontestevent['event_time'] != null
        ? artcontestevent['event_time'] as String
        : 'No Event Time';
    final access_code = artcontestevent['eventId'] != null
        ? artcontestevent['access_code'] as String
        : 'No Event Time';
    return Card(
      color: Colors.white,
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 40.0),
        dense: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                event_name.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                '$event_date at $event_time',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Access Code: ',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    TextSpan(
                      text: access_code,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          try {
            // Handle item tap if needed
            if (artcontestevent != null && artcontestevent['event_name'] != null) {
              print('Tapped on ${artcontestevent['event_name']}');

              // Add additional null checks for event_id
              final event_id =
                  artcontestevent['_id'] != null ? artcontestevent['_id'] as String : '';
              final eventData = {
                'eventName': artcontestevent['event_name'] ?? '',
                'eventDate': artcontestevent['event_date']?? '',
                'eventTime': artcontestevent['event_time']?? '',
                'accessCode': artcontestevent['acces_code']?? '',
                'eventVenue': artcontestevent['event_venue']?? '',
                'eventOrganizer': artcontestevent['event_organizer'] ?? ''
              };

              if (eventData.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreCard(
                      eventId: event_id,
                      eventData: eventData,
                 //     judges: [],
                    ),
                  ),
                );
              } else {
                // Handle the case where eventData is null
                print('eventData is null. Cannot navigate to ScoreCard.');
              }
            }
          } catch (e, stackTrace) {
            print('Error in onTap: $e\n$stackTrace');
          }
        },
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  // Create a method to build a clickable item
  Widget buildClickableItem(
      BuildContext context,
      String _id,
      String event_name,
      String event_date,
      String event_time,
      String event_category,
      String event_organizer,
      String event_venue) {
    return GestureDetector(
      onTap: () {
        // Navigate to the corresponding screen when the item is tapped
        if (name == 'Pageants') {
          final Event eventInstance = Event(
            eventId: _id,
            eventName: event_name,
            eventDate: event_date,
            eventTime: event_time,
            eventCategory: event_category,
            eventOrganizer: event_organizer,
            eventVenue: event_venue,
            contestants: [],
            criterias: [],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageantsScreen(
                  event: CodeModel.Event(
                eventId: _id,
             
                eventName: event_name,
                eventDate: event_date,
                eventTime: event_time,
                eventCategory: event_category,
                eventOrganizer: event_organizer,
                eventVenue: event_venue,
                contestants: [],
                criterias: [],
              )),
            ),
          );
        } else if (name == 'Talent Shows') {
            final Event eventInstance = Event(
            eventId: _id,
        
            eventName: event_name,
            eventDate: event_date,
            eventTime: event_time,
            eventCategory: event_category,
            eventOrganizer: event_organizer,
            eventVenue: event_venue,
            contestants: [],
            criterias: [],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TalentShowsScreen(
                talentevent: CodeModel.Event(
                eventId: _id,
          
                eventName: event_name,
                eventDate: event_date,
                eventTime: event_time,
                eventCategory: event_category,
                eventOrganizer: event_organizer,
                eventVenue: event_venue,
                contestants: [],
                criterias: [],
              )
              ),
            ),
          );
        } else if (name == 'Debates') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DebatesScreen(
                debateevent: CodeModel.Event(
                eventId: _id,
                
                eventName: event_name,
                eventDate: event_date,
                eventTime: event_time,
                eventCategory: event_category,
                eventOrganizer: event_organizer,
                eventVenue: event_venue,
                contestants: [],
                criterias: [],
              )
              ),
            ),
          );
        } else if (name == 'Art Contest') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtContestScreen(
                artcontestevent: CodeModel.Event(
                eventId: _id,
                eventName: event_name,
                eventDate: event_date,
                eventTime: event_time,
                eventCategory: event_category,
                eventOrganizer: event_organizer,
                eventVenue: event_venue,
                contestants: [],
                criterias: [],
              )
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              iconPath,
              width: 50,
              height: 50,
            ),
            const SizedBox(height: 8),
            Text(name),
          ],
        ),
      ),
    );
  }

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: 'Pageants',
        iconPath: 'assets/icons/miss-world-model-svgrepo-com.svg',
        boxColor: Colors.green,
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Talent Shows',
        iconPath: 'assets/icons/person-juggling-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 141, 236, 117),
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Debates',
        iconPath: 'assets/icons/marketing-speaker-svgrepo-com.svg',
        boxColor: Colors.green,
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Art Contest',
        iconPath: 'assets/icons/drawing-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 141, 236, 117),
      ),
    );

    return categories;
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.green,
            ),
            SizedBox(
                height:
                    16), // Optional: Add some spacing between the indicator and other content
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoadingScreen(),
  ));
}
