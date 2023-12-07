import 'package:flutter/material.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Criteria {
  String criterianame;
  String percentage;
  String eventId; // Event ID
  //String contestantId; // Contestant ID

  Criteria({
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    //required this.contestantId,
  });

 Map<String, dynamic> toJson() {
    return {
      'criterianame': criterianame,
      'percentage': percentage,
      'eventId': eventId,
    };
  }
}
class Event {
  String event_name;
  String event_date;
  String event_time;
  String access_code;
  String? event_venue;  // Added field
  String? event_organizer;  // Added field
  final List<dynamic>? contestants;  // Assuming contestants is a list of strings
  final List<dynamic>? criteria;  // Assuming criteria is a list of strings

  // Constructor
  Event({
    required this.event_name,
    required this.event_date,
    required this.event_time,
    required this.access_code,
    required this.event_venue,
    required this.event_organizer,
    required this.contestants,
    required this.criteria,
  });

  // Factory method to create an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      event_name: json['event_name'] ?? '',
      event_date: json['event_date']?? '',
      event_time: json['event_time'] ?? '',
      access_code: json['access_code'] ?? '',
      event_venue: json['event_venue'] ?? '',
      event_organizer: json['event_organizer'] ?? '',
     contestants: json['contestants'] != null
          ? List<dynamic>.from(json['contestants'])
          : null,
      criteria: json['criteria'] != null
          ? List<dynamic>.from(json['criteria'])
          : null,
    );
  }
}


class Criterias extends StatefulWidget {
  final String eventId;

  Criterias({required this.eventId});

  @override
  _CriteriasState createState() => _CriteriasState();
}

class _CriteriasState extends State<Criterias> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Criteria> criterias = [];

  TextEditingController _criteriaNameController = TextEditingController();
  TextEditingController _percentageController = TextEditingController();

  void insertItem(Criteria criteria) {
    final newIndex = 0;
    criterias.insert(newIndex, criteria);
    _listKey.currentState!.insertItem(newIndex);
  }

  void _editCriteria(BuildContext context, Criteria criteria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _criteriaNameController.text = criteria.criterianame;
        _percentageController.text = criteria.percentage;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Center(
            child: Text(
              'Edit Criteria Information',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 5, 78, 7),
              ),
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _criteriaNameController,
                  decoration: const InputDecoration(
                    labelText: 'Criteria Name',
                    labelStyle: TextStyle(fontSize: 15, color: Colors.green),
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Percentage',
                    labelStyle: TextStyle(fontSize: 15, color: Colors.green),
                  ),
                  
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                // Update the criteria
                criteria.criterianame = _criteriaNameController.text;
                criteria.percentage = _percentageController.text;

                // Notify the list to update the UI
                _listKey.currentState!.setState(() {});

                Navigator.pop(context);
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

  void removeItem(int index) {
    if (index >= 0 && index < criterias.length) {
      final removedItem = criterias[index];
      criterias.removeAt(index);
      _listKey.currentState!.removeItem(
        index,
        (context, animation) => ListItemWidget(
          criteria: removedItem,
          animation: animation,
          onClicked: () => removeItem(index),
          onEdit: () {},
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
  }

Future<void> createCriteria(
    String eventId, Map<String, dynamic> criteriaData) async {
    if (eventId == null) {
    print('Error: Event ID is null');
    return;
  }
  if (criteriaData == null || !criteriaData.containsKey('criterianame') || !criteriaData.containsKey('percentage')) {
    print('Error: Invalid criteria data');
    return;
  }
  final url = Uri.parse("http://10.0.2.2:8080/criteria");

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        ...criteriaData,
        "eventId": eventId,
      }),
    );

    if (response.statusCode == 201) {
      print('Criteria created successfully');
    } else {
      print('Failed to create criteria. Status code: ${response.statusCode}');

      // Check for null response body
      final responseBody = response.body;
      if (responseBody != null && responseBody.isNotEmpty) {
        print('Response body: $responseBody');
      } else {
        print('Empty or null response body');
      }
    }
  } catch (e) {
    print('Error creating criteria: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Criteria for Judging',
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
      body: AnimatedList(
        key: _listKey,
        initialItemCount: criterias.length,
        itemBuilder: (context, index, animation) {
          return ListItemWidget(
            criteria: criterias[index],
            animation: animation,
            onClicked: () => removeItem(index),
            onEdit: () => _editCriteria(context, criterias[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white,),
        onPressed: () {
          _criteriaNameController.clear();
          _percentageController.clear();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: const Center(
                  child: Text(
                    'Add Criteria Information',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 5, 78, 7),
                    ),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _criteriaNameController,
                        decoration: const InputDecoration(
                          labelText: 'Criteria Name',
                          labelStyle:
                              TextStyle(fontSize: 15, color: Colors.green),
                        ),
                      ),
                      TextField(
                        controller: _percentageController,
                         keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Percentage',
                          labelStyle:
                              TextStyle(fontSize: 15, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Criteria newCriterias = Criteria(
                        criterianame: _criteriaNameController.text ?? '',
                        percentage: _percentageController.text ?? '',
                        eventId: widget.eventId,
                      );

                      insertItem(newCriterias);
                      _criteriaNameController.clear();
                      _percentageController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                // Add your cancel button action here
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
              child: const Text('CLEAR', style: TextStyle(color: Colors.green)),
            ),
            const SizedBox(width: 10),
           ElevatedButton(
  onPressed: () async {
  try {
    if (criterias.isNotEmpty) {
      for (final criteria in criterias) {
        if (widget.eventId != null) {
          await createCriteria(widget.eventId!, criteria.toJson());
        } else {
          print('Error: Event ID is null');
        }
      }
    }
      
      final String? eventId = await fetchEventId();
      if (eventId != null) {
         print('Fetching event with ID: $eventId');
        final response = await http.get(Uri.parse('http://10.0.2.2:8080/events/$eventId'));

        if (response.statusCode == 200) {
          final Event event = Event.fromJson(jsonDecode(response.body));

          final eventData = {
            'eventName': event.event_name,
            'eventDate': event.event_date,
            'eventTime': event.event_time,
            'accessCode': event.access_code,
            'eventVenue': event.event_venue ?? 'n/a',  // Uncomment this line if event_venue is not null
            'eventOrganizer': event.event_organizer ?? 'n/a',  // Add other fields as needed
            'contestants': event.contestants ?? [],  // Assuming contestants is an array
            'criteria': event.criteria ?? [],  // Assuming criteria is an array
            // Add other data as needed
          };

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScoreCard(
                eventId: widget.eventId,
                eventData: eventData,
             //   judges: judges,
              ),
            ),
          );
        } else {
          print('Failed to fetch event data. Status code: ${response.statusCode}');
        }
      } else {
        print('Failed to fetch eventId. Defaulting to "default_event_id".');
      }
    } catch (e) {
      print('Error fetching event data: $e');
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
  child: const Text('SAVE'),
),

          ],
        ),
      ),
    );
  }
}

class ListItemWidget extends StatelessWidget {
  final Criteria criteria;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final VoidCallback onEdit;

  ListItemWidget({
    required this.criteria,
    required this.animation,
    required this.onClicked,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: buildItem(context),
    );
  }

  Widget buildItem(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: Container(
            width: 16, // Set a fixed width for the leading widget
            child: GestureDetector(
              onTap: () {},
            ),
          ),
          title: Text(
            criteria.criterianame,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Percentage: ${criteria.percentage}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 25),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 25),
                onPressed: onClicked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> fetchEventId() async {
  final String url = 'http://10.0.2.2:8080/latest-event-id';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if responseData contains the expected structure
      if (responseData.containsKey('eventData')) {
        final eventData = responseData['eventData'];
        if (eventData.containsKey('eventId')) {
          return eventData['eventId']?.toString();
        } else {
          // Handle unexpected response structure
          print('Error: Unexpected response structure - missing eventId');
          return null;
        }
      } else {
        // Handle unexpected response structure
        print('Error: Unexpected response structure - missing eventData');
        return null;
      }
    } else if (response.statusCode == 404) {
      // Handle case where no events are found
      print('No events found.');
      return null;
    } else {
      // Handle other error scenarios
      print('Failed to fetch event ID. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // Handle network or other errors
    print('Error fetching event ID: $e');
    return null;
  }
}



void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: fetchEventId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              print('Error: Unable to fetch valid Event ID. Defaulting to "default_event_id"');
              final String eventId = 'default_event_id'; // Provide a default value
              return Scaffold(
                body: Criterias(eventId: eventId),
              );
            }

            final String eventId = snapshot.data!;

            return Scaffold(
              body: Criterias(eventId: eventId),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ),
  );
}

