import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Criteria {
  String? criteriaId;
  String criterianame;
  String percentage;
  String eventId; // Event ID
  List<SubCriteria> subCriteriaList; // List of subcriteria

  Criteria({
    this.criteriaId,
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    required this.subCriteriaList,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criteriaId: json['_id'] ?? '',
      criterianame: json['criterianame'] ?? '',
      percentage: json['percentage'] ?? '',
      eventId: json['eventId'] ?? '',
      subCriteriaList: (json['subCriteriaList'] as List<dynamic>?)
          ?.map((subCriteriaJson) => SubCriteria.fromJson(subCriteriaJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaId': criteriaId,
      'criterianame': criterianame,
      'percentage': percentage,
      'eventId': eventId,
      'subCriteriaList': subCriteriaList.map((subCriteria) => subCriteria.toJson()).toList(),
    };
  }
}

class SubCriteria {
  String subCriteriaName;
  String percentage;

  SubCriteria({
    required this.subCriteriaName,
    required this.percentage,
  });

  factory SubCriteria.fromJson(Map<String, dynamic> json) {
    return SubCriteria(
      subCriteriaName: json['subCriteriaName'] ?? '',
      percentage: json['percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCriteriaName': subCriteriaName,
      'percentage': percentage,
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
        Uri.parse('http://192.168.101.6:8080/criteria/$eventId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> criteriaList = jsonDecode(response.body);
        final List<Criteria> fetchedCriterias = criteriaList
            .map((criteriaJson) => Criteria.fromJson(criteriaJson))
            .toList();
        setState(() {
          criterias = fetchedCriterias;
          print(criterias[0].subCriteriaList);
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
        "http://192.168.101.6:8080/criteria?eventId=$eventId&criteriaName=$criteriaName");
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
          onAdd: () {},
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

  Future<void> createCriteria(String eventId, Map<String, dynamic> criteriaData) async {
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

    bool allSubCriteriaPercentagesAre100 = true;

    if (criteriaData.containsKey('subCriteriaList')) {
      List<Map<String, dynamic>> subCriteriaList = criteriaData['subCriteriaList'];

      double subPercentage = 0.0; // Initialize subPercentage outside the loop

      for (final subCriteria in subCriteriaList) {
        subPercentage += double.tryParse(subCriteria['percentage'] ?? '0.0') ?? 0.0;
      }

      if (subPercentage != 100.0) {
        _showErrorSnackBar('Total percentage of sub-criteria is not 100', Colors.orange);
        allSubCriteriaPercentagesAre100 = false;
      }

    }

    if (!allSubCriteriaPercentagesAre100) {
      throw Exception('One or more criteria have a total sub-criteria percentage not equal to 100');
    }

    final double totalPercentage = calculateTotalPercentage();
    final double newPercentage = double.tryParse(criteriaData['percentage'] ?? '0.0') ?? 0.0;
    print(newPercentage);

    if (totalPercentage > 100.0) {
      _showErrorSnackBar('Total percentage exceeds 100%. Adjusting percentages.', Colors.orange);
      final double adjustment = 100.0 - totalPercentage;
      final double adjustedPercentage = newPercentage - adjustment;
      criteriaData['percentage'] = adjustedPercentage.toString();
      final int criteriaCount = criterias.length;
      final double adjustmentPerCriteria = adjustment / criteriaCount;

      for (final criteria in criterias) {
        final double currentPercentage = double.tryParse(criteria.percentage ?? '0.0') ?? 0.0;
        criteria.percentage = (currentPercentage + adjustmentPerCriteria).toString();
      }
    } else {
      final url = Uri.parse("http://192.168.101.6:8080/criteria");

      try {
        print(criteriaData);
        final response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({...criteriaData, "eventId": eventId}),
        );

        if (response.statusCode == 201) {
          print("Criteria Created Successfully");
        } else {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String errorMessage = responseData['error'];
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
            onAdd: () => (),
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
                                subCriteriaList: [], // Pass the current criteria's subcriteria list
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
                child: Text('Clear'), // Add the child parameter here
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
                              'http://192.168.101.6:8080/event/$eventId'),
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

class ListItemWidget extends StatefulWidget {
  final Criteria criteria;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  ListItemWidget({
    required this.criteria,
    required this.animation,
    required this.onClicked,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  _ListItemWidgetState createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: buildItem(context),
    );
  }


  Widget buildItem(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeInOut,
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDropdownOpen = !isDropdownOpen;
                      });
                    },
                    child: Transform.rotate(
                      angle: isDropdownOpen ? pi / -75 : pi / -2,
                      child: Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.criteria.criterianame,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Percentage: ${widget.criteria.percentage}',
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
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 25),
                    onPressed: widget.onClicked,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.grey, size: 25),
                    onPressed: () {
                      _showAddSubCriteriaModal(context);
                    },
                  ),
                ],
              ),
            ),
            if (isDropdownOpen) buildDropdownList(),
          ],
        ),
      ),
    );
  }

  void _showAddSubCriteriaModal(BuildContext context) {
    TextEditingController subCriteriaNameController = TextEditingController();
    TextEditingController percentageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subCriteriaNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter sub criteria name',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: percentageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter percentage',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        // Calculate total percentage including the new subcriteria
                        double totalPercentage = widget.criteria.subCriteriaList
                            .map((subCriteria) => double.parse(subCriteria.percentage))
                            .fold(0, (previousValue, element) => previousValue + element);

                        // Parse the new subcriteria's percentage
                        double newPercentage = double.parse(percentageController.text);

                        // Check if the new total percentage will exceed 100%
                        if (totalPercentage + newPercentage <= 100.0) {
                          final newSubCriteria = SubCriteria(
                            subCriteriaName: subCriteriaNameController.text,
                            percentage: percentageController.text,
                          );
                          setState(() {
                            widget.criteria.subCriteriaList.add(newSubCriteria);
                          });
                          Navigator.pop(context);
                        } else {
                          // Display an error message if adding the new subcriteria exceeds 100%
                          Fluttertoast.showToast(
                            msg: 'Sub-criteria percentage exceeds 100%',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.orange,
                            textColor: Colors.white,
                          );
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget buildDropdownList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider( // This creates the horizontal line
            color: Colors.grey,
            thickness: 1, // Adjust thickness as needed
          ),
          if (widget.criteria.subCriteriaList.isNotEmpty)
            Text("Sub-criteria"),
          for (int index = 0; index < widget.criteria.subCriteriaList.length; index++)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.criteria.subCriteriaList[index].subCriteriaName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${widget.criteria.subCriteriaList[index].percentage} %',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      widget.criteria.subCriteriaList.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          if (widget.criteria.subCriteriaList.isEmpty)
            Text("No Sub-criteria"),
        ],
      ),
    );
  }

}







