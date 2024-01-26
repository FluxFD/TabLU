import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Criteria {
  String? criteriaId;
  String criterianame;
  String percentage;
  String eventId; // Event ID
  //String contestantId; // Contestant ID

  Criteria({
    this.criteriaId,
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    //required this.contestantId,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criteriaId: json['_id'] ?? '',
      criterianame: json['criterianame'] ?? '',
      percentage: json['percentage'] ?? '',
      eventId: json['eventId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaId': criteriaId,
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
  String? event_venue; // Added field
  String? event_organizer; // Added field
  final List<dynamic>? contestants; // Assuming contestants is a list of strings
  final List<dynamic>? criteria; // Assuming criteria is a list of strings

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
      event_date: json['event_date'] ?? '',
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
  void updateTotalPercentage() {
    setState(() {
      totalPercentage = calculateTotalPercentage();
    });
  }

  Future<void> _fetchCriterias(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('https://tab-lu.onrender.com/criteria/$eventId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> criteriaList = jsonDecode(response.body);
        // print("Critieria List ${criteriaList}");
        final List<Criteria> fetchedCriterias = criteriaList
            .map((criteriaJson) => Criteria.fromJson(criteriaJson))
            .toList();
        setState(() {
          criterias = fetchedCriterias;
        });
      } else {
        print('Failed to fetch criteria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching criteria: $e');
    }
  }

  Future<void> deleteCriteria(String eventId, String criteriaName) async {
    final url = Uri.parse(
        "https://tab-lu.onrender.com/criteria?eventId=$eventId&criteriaName=$criteriaName");
    updateTotalPercentage();
    try {
      final response = await http.delete(url);
      print('Response headers: ${response.headers}');
      if (response.statusCode == 200) {
        _showErrorSnackBar('Criteria deleted successfully', Colors.green);
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String errorMessage = responseData['error'];
        // _showErrorSnackBar(
        //   'Failed to delete criteria: ${errorMessage}',
        //   Colors.red,
        // );
        print("Failed to delete criteria: ${errorMessage}");
      }
    } catch (e) {
      print('Error deleting criteria: $e');
    }
  }

  bool isLoading = true;
  void initState() {
    super.initState();
    _fetchCriterias(widget.eventId);
    Timer(Duration(seconds: 3), () {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

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
                updateTotalPercentage();

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
      deleteCriteria(removedItem.eventId, removedItem.criterianame);
    }
  }

  double totalPercentage = 0.0;
  double calculateTotalPercentage() {
    double totalPercentage = 0.0;
    for (final criteria in criterias) {
      final percentage = double.tryParse(criteria.percentage) ?? 0.0;
      totalPercentage += percentage;
    }

    return totalPercentage;
  }

  void _showErrorSnackBar(String message, MaterialColor color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  Future<void> createCriteria(
      String eventId, Map<String, dynamic> criteriaData) async {
    if (eventId == null) {
      print('Error: Event ID is null');
      return;
    }
    if (criteriaData == null ||
        !criteriaData.containsKey('criterianame') ||
        !criteriaData.containsKey('percentage')) {
      _showErrorSnackBar('Error: Invalid criteria data', Colors.orange);
      return;
    }

    final double totalPercentage = calculateTotalPercentage();
    print(totalPercentage);
    final double newPercentage =
        double.tryParse(criteriaData['percentage'] ?? '0.0') ?? 0.0;
    print(newPercentage);
    if (totalPercentage > 100.0) {
      _showErrorSnackBar(
          'Total percentage exceeds 100%. Adjusting percentages.',
          Colors.orange);

      final double adjustment = 100.0 - totalPercentage;

      final double adjustedPercentage = newPercentage - adjustment;

      criteriaData['percentage'] = adjustedPercentage.toString();

      final int criteriaCount = criterias.length;
      final double adjustmentPerCriteria = adjustment / criteriaCount;

      for (final criteria in criterias) {
        final double currentPercentage =
            double.tryParse(criteria.percentage) ?? 0.0;
        criteria.percentage =
            (currentPercentage + adjustmentPerCriteria).toString();
      }
    } else {
      final url = Uri.parse("https://tab-lu.onrender.com/criteria");

      try {
        print(criteriaData);
        // Check if criteria with the same name already exists
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
          print("Criteria Created Successfully");
        } else {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String errorMessage = responseData['error'];
          // _showErrorSnackBar(
          //     'Failed to create criteria: ${errorMessage}',
          //     Colors.red);
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
  }

  @override
  Widget build(BuildContext context) {
    if (criterias.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    if (isLoading) {
      // Data is still loading, display a loading indicator
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    totalPercentage = calculateTotalPercentage();
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
        backgroundColor: totalPercentage >= 100.0 ? Colors.grey : Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: totalPercentage >= 100.0
            ? null // Set onPressed to null to disable the button
            : () {
                _criteriaNameController.clear();
                _percentageController.clear();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: const Center(
                        child: Text(
                          'Add Criteria Information',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 5, 78, 7),
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            TextField(
                              controller: _criteriaNameController,
                              decoration: const InputDecoration(
                                labelText: 'Criteria Name',
                                labelStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            TextField(
                              controller: _percentageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Percentage',
                                labelStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                ),
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
                            // Calculate total percentage including the new criteria
                            double newPercentage =
                                double.tryParse(_percentageController.text) ??
                                    0.0;

                            double updatedTotalPercentage =
                                totalPercentage + newPercentage;

                            // Check if the new total percentage will exceed 100%
                            if (updatedTotalPercentage <= 100.0) {
                              Criteria newCriterias = Criteria(
                                criterianame:
                                    _criteriaNameController.text ?? '',
                                percentage: newPercentage.toString(),
                                eventId: widget.eventId,
                              );

                              insertItem(newCriterias);
                              _criteriaNameController.clear();
                              _percentageController.clear();

                              updateTotalPercentage();
                              Navigator.pop(context);
                            } else {
                              _showErrorSnackBar(
                                'Error: Total percentage will exceed 100%. Current total: $totalPercentage',
                                Colors.red,
                              );
                            }
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${totalPercentage.toStringAsFixed(2)}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Clear All Criteria'),
                        content: Text(
                            'Are you sure you want to delete all criteria?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete all criteria
                              for (int i = criterias.length - 1; i >= 0; i--) {
                                removeItem(i);
                              }
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete All'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Your Button Text'), // Add the child parameter here
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
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
                child:
                    const Text('CLEAR', style: TextStyle(color: Colors.green)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final double totalPercentage = calculateTotalPercentage();

                    if (totalPercentage != 100.0) {
                      _showErrorSnackBar(
                        'Error: Total percentage must be 100%. Current total: $totalPercentage%',
                        Colors.red,
                      );
                      return;
                    }

                    if (totalPercentage == 100.0) {
                      if (criterias.isNotEmpty) {
                        for (final criteria in criterias) {
                          if (widget.eventId != null) {
                            await createCriteria(
                                widget.eventId!, criteria.toJson());
                          } else {
                            print('Error: Event ID is null');
                          }
                        }
                      }

                      _fetchCriterias(widget.eventId);
                      _showErrorSnackBar(
                          'Criteria created successfully', Colors.green);

                      final String? eventId = widget.eventId;
                      if (eventId != null) {
                        print('Fetching event with ID: $eventId');
                        final response = await http.get(
                          Uri.parse(
                              'https://tab-lu.onrender.com/event/$eventId'),
                        );

                        if (response.statusCode == 200) {
                          final Event event =
                              Event.fromJson(jsonDecode(response.body));

                          final eventData = {
                            'eventName': event.event_name,
                            'eventDate': event.event_date,
                            'eventTime': event.event_time,
                            'accessCode': event.access_code,
                            'eventVenue': event.event_venue ?? 'n/a',
                            'eventOrganizer': event.event_organizer ?? 'n/a',
                            'contestants': event.contestants ?? [],
                            'criteria': event.criteria ?? [],
                          };

                          // Navigate to the next screen or perform any other actions
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScoreCard(
                                eventId: widget.eventId,
                                eventData: {},
                                judges: [],
                              ),
                            ),
                          );
                        } else {
                          print(
                            'Failed to fetch event data. Status code: ${response.statusCode}',
                          );
                        }
                      }
                    } else {
                      _showErrorSnackBar(
                          'Error: Total percentage must be 100%. Current total: $totalPercentage',
                          Colors.red);
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
        ]),
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
