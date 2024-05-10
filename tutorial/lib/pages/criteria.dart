import 'dart:async';
import 'dart:ffi';
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
  bool isSpecialAwards;
  List<SubCriteria> subCriteriaList; // List of subcriteria
  String baseScore; // Added field

  Criteria({
    this.criteriaId,
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    required this.isSpecialAwards,
    required this.subCriteriaList,
    required this.baseScore, // Added field
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criteriaId: json['_id'] ?? '',
      criterianame: json['criterianame'] ?? '',
      percentage: json['percentage'] ?? '',
      isSpecialAwards: json['isSpecialAwards'] ?? false,
      eventId: json['eventId'] ?? '',
      subCriteriaList: (json['subCriteriaList'] as List<dynamic>?)
              ?.map((subCriteriaJson) => SubCriteria.fromJson(subCriteriaJson))
              .toList() ??
          [],
      baseScore: json['baseScore'] ?? '0', // Added field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaId': criteriaId,
      'criterianame': criterianame,
      'percentage': percentage,
      'isSpecialAwards': isSpecialAwards,
      'eventId': eventId,
      'subCriteriaList':
          subCriteriaList.map((subCriteria) => subCriteria.toJson()).toList(),
      'baseScore': baseScore, // Added field
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
  String event_category; // Added field
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
    required this.event_category,
    required this.contestants,
    required this.criteria,
  });

  // Factory method to create an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      event_name: json['eventName'] ?? '',
      event_date: json['eventDate'] ?? '',
      event_time: json['eventTime'] ?? '',
      access_code: json['accessCode'] ?? '',
      event_venue: json['eventVenue'] ?? '',
      event_organizer: json['eventOrganizer'] ?? '',
      event_category: json['eventCategory'] ?? '',
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
  final bool isEdit;

  Criterias({required this.eventId, required this.isEdit});

  @override
  _CriteriasState createState() => _CriteriasState();
}

class _CriteriasState extends State<Criterias> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _anotherListKey =
      GlobalKey<AnimatedListState>();

  List<Criteria> criterias = [];
  List<Criteria> specialAwards = [];
  Event? event;
  bool isLoading = true;
  bool isMainCriteriaOpen = true;
  bool isSpecialAwardsOpen = true;
  bool isSending = false;
  late final Animation<double> animation;
  TextEditingController _criteriaNameController = TextEditingController();
  TextEditingController _percentageController = TextEditingController();
  TextEditingController _baseScoreController = TextEditingController();
  TextEditingController _specialAwardsNameController = TextEditingController();

  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() async {
    await _fetchEvent(widget.eventId);
    await _fetchCriterias(widget.eventId);
    // Now, the event variable can be safely accessed here
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchEvent(String eventId) async {
    try {
      final response = await http
          .get(Uri.parse('https://tabluprod.onrender.com/event/$eventId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
        event = Event.fromJson(jsonData);
        print(event?.event_name);
      } else {
        print(
            'Failed to fetch event data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching event data: $e');
    }
  }

  Future<void> _fetchCriterias(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('https://tabluprod.onrender.com/criteria/$eventId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> criteriaList = jsonDecode(response.body);
        final List<Criteria> fetchedCriterias = criteriaList
            .map((criteriaJson) => Criteria.fromJson(criteriaJson))
            .toList();

        List<Criteria> fetchedMainCriterias = [];
        List<Criteria> fetchedSpecialAwards = [];

        for (var criteria in fetchedCriterias) {
          if (criteria.isSpecialAwards) {
            fetchedSpecialAwards.add(criteria);
          } else {
            fetchedMainCriterias.add(criteria);
          }
        }

        setState(() {
          criterias = fetchedMainCriterias;
          specialAwards = fetchedSpecialAwards;
        });
      } else {
        print('Failed to fetch criteria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching criteria: $e');
    }
  }

  void updateTotalPercentage() {
    // if (event?.event_category != "Pageants") {
    //   setState(() {
    //     totalPercentage = calculateTotalPercentage();
    //   });
    // }
    setState(() {
      totalPercentage = calculateTotalPercentage();
    });
  }

  Future<void> deleteCriteria(String eventId, String? criteriaId) async {
    print(criteriaId);
    final url = Uri.parse(
        "https://tabluprod.onrender.com/criteria?eventId=$eventId&criteriaId=$criteriaId");
    try {
      final response = await http.delete(url);
      // print('Response headers: ${response.headers}');
      if (response.statusCode == 200) {
        updateTotalPercentage();
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

  void insertItem(Criteria criteria, String type) {
    if (type == "Main Criteria") {
      setState(() {
        final newIndex = 0;
        criterias.insert(newIndex, criteria);
        _listKey.currentState!.insertItem(newIndex);
      });
    } else {
      setState(() {
        final newIndex = 0;
        specialAwards.insert(newIndex, criteria);
        _anotherListKey.currentState!.insertItem(newIndex);
      });
    }
  }

  bool validateFields(
      BuildContext context, List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        // Show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Return false as not all fields are valid
      }
    }
    return true; // Return true as all fields are valid
  }

  void _editCriteria(BuildContext context, Criteria criteria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _criteriaNameController.text = criteria.criterianame;
        _percentageController.text = criteria.percentage;
        _baseScoreController.text = criteria.baseScore;

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
                  onChanged: (value) {
                    // Ensure the entered base score is a valid integer and not more than 100
                    if (value.isNotEmpty) {
                      int percentage = int.tryParse(value) ??
                          0; // Default to 0 if parsing fails
                      if (percentage < 0 || percentage > 100) {
                        // If the base score is not within the valid range, clear the text field
                        _percentageController.clear();
                      }
                    }
                  },
                ),
                TextField(
                  controller: _baseScoreController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Base Score',
                    labelStyle: TextStyle(fontSize: 15, color: Colors.green),
                  ),
                  onChanged: (value) {
                    // Ensure the entered base score is a valid integer and not more than 100
                    if (value.isNotEmpty) {
                      int baseScore = int.tryParse(value) ??
                          0; // Default to 0 if parsing fails
                      if (baseScore < 0 || baseScore > 100) {
                        // If the base score is not within the valid range, clear the text field
                        _baseScoreController.clear();
                      }
                    }
                  },
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
                bool isAllField = validateFields(context, [
                  _criteriaNameController,
                  _percentageController,
                  _baseScoreController
                ]);
                if (!isAllField) {
                  return;
                }
                // Update the criteria
                criteria.criterianame = _criteriaNameController.text;
                double updatedTotalPercentage = totalPercentage +
                    double.parse(_percentageController.text) -
                    double.parse(criteria.percentage);
                if (updatedTotalPercentage > 100.0) {
                  // Show a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Total percentage cannot exceed 100%'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Return to prevent the rest of the code from executing
                }
                criteria.percentage = _percentageController.text;
                criteria.baseScore = _baseScoreController.text.isEmpty
                    ? "0"
                    : _baseScoreController.text;

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

  void removeItem(int index, String method) {
    print("object");
    if (method == "Special Awards" || method == "deleteAll") {
      removeItemFromList(
          index, specialAwards, _anotherListKey, "Special Awards");
    }
    if (method == "Main Criteria" || method == "deleteAll") {
      removeItemFromList(index, criterias, _listKey, "Main Criteria");
    }
  }

  void removeItemFromList(int index, List<Criteria> list,
      GlobalKey<AnimatedListState> listKey, String method) {
    if (index >= 0 && index < list.length) {
      setState(() {
        final removedItem = list[index];
        list.removeAt(index);
        listKey.currentState!.removeItem(
          index,
          (context, animation) => ListItemWidget(
            criteria: method == "Main Criteria" ? removedItem : null,
            specialAwards: method == "Special Awards" ? removedItem : null,
            criteriaType: method,
            animation: animation,
            onClicked: () => removeItem(index, method),
            onEdit: () {},
            onAdd: () {},
            event_category: event?.event_category,
          ),
          duration: const Duration(milliseconds: 300),
        );
        deleteCriteria(removedItem.eventId, removedItem.criteriaId);
      });
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

  Future<void> createCriteria(String eventId, Map<String, dynamic> criteriaData,
      String criteriaType) async {
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
      List<Map<String, dynamic>> subCriteriaList =
          criteriaData['subCriteriaList'];

      double subPercentage = 0.0; // Initialize subPercentage outside the loop

      for (final subCriteria in subCriteriaList) {
        subPercentage +=
            double.tryParse(subCriteria['percentage'] ?? '0.0') ?? 0.0;
      }
      if (event?.event_category == "Pageants" && subPercentage < 100) {
        _showErrorSnackBar(
            'Total percentage of ${criteriaType == "Main Criteria" ? "sub-criteria" : "criteria"} must be 100',
            Colors.orange);
        allSubCriteriaPercentagesAre100 = false;
      }

      if (subPercentage != 100.0 &&
          criteriaData['subCriteriaList'] != null &&
          (criteriaData['subCriteriaList'] as List).isNotEmpty) {
        _showErrorSnackBar(
            'Total percentage of ${criteriaType == "Main Criteria" ? "sub-criteria" : "criteria"} must be 100',
            Colors.orange);
        allSubCriteriaPercentagesAre100 = false;
      }
    }

    if (!allSubCriteriaPercentagesAre100) {
      throw Exception(
          'One or more criteria have a total sub-criteria percentage not equal to 100');
    }

    final double totalPercent = calculateTotalPercentage();
    final double newPercentage =
        double.tryParse(criteriaData['percentage'] ?? '0.0') ?? 0.0;
    print(newPercentage);

    if (totalPercent > 100.0 && event?.event_category != "Pageants") {
      _showErrorSnackBar(
          'Total percentage exceeds 100%. Adjusting percentages.',
          Colors.orange);
      final double adjustment = 100.0 - totalPercent;
      final double adjustedPercentage = newPercentage - adjustment;
      criteriaData['percentage'] = adjustedPercentage.toString();
      final int criteriaCount = criterias.length;
      final double adjustmentPerCriteria = adjustment / criteriaCount;

      for (final criteria in criterias) {
        final double currentPercentage =
            double.tryParse(criteria.percentage ?? '0.0') ?? 0.0;
        criteria.percentage =
            (currentPercentage + adjustmentPerCriteria).toString();
      }
    } else {
      final url = Uri.parse("https://tabluprod.onrender.com/criteria");

      try {
        // print("Criteria Data ${criteriaData}");
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            parentMainCriteria(context),
            if (event?.event_category == "Pageants")
              parentSpecialAwards(context)
          ],
        ),
      ),
      floatingActionButton: totalPercentage >= 100.0 &&
              event?.event_category != "Pageants"
          ? FloatingActionButton(
              onPressed: () {
                // Add onPressed functionality here
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: totalPercentage >= 100.0 &&
                      event?.event_category != "Pageants"
                  ? Colors.grey
                  : Colors.green,
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20), // Adjust the value as needed
                color: totalPercentage >= 100.0 &&
                        event?.event_category != "Pageants"
                    ? Colors.grey
                    : Colors.green,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.add, color: Colors.white),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Main Criteria',
                      child: Text('Main Criteria'),
                    ),
                    if (event?.event_category == "Pageants")
                      const PopupMenuItem<String>(
                        value: 'Special Awards',
                        child: Text('Special Awards'),
                      ),
                  ],
                  onSelected: (String value) {
                    if (value == 'Main Criteria' && totalPercentage >= 100.0) {
                      return null;
                    }
                    switch (value) {
                      case 'Main Criteria':
                        _criteriaNameController.clear();
                        _percentageController.clear();
                        _baseScoreController.clear();
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
                                      onChanged: (value) {
                                        // Ensure the entered base score is a valid integer and not more than 100
                                        if (value.isNotEmpty) {
                                          int percentage = int.tryParse(
                                                  value) ??
                                              0; // Default to 0 if parsing fails
                                          if (percentage < 0 ||
                                              percentage > 100) {
                                            // If the base score is not within the valid range, clear the text field
                                            _percentageController.clear();
                                          }
                                        }
                                      },
                                    ),
                                    TextField(
                                      controller: _baseScoreController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Base Score',
                                        labelStyle: TextStyle(
                                            fontSize: 15, color: Colors.green),
                                      ),
                                      onChanged: (value) {
                                        // Ensure the entered base score is a valid integer and not more than 100
                                        if (value.isNotEmpty) {
                                          int baseScore = int.tryParse(value) ??
                                              0; // Default to 0 if parsing fails
                                          if (baseScore < 0 ||
                                              baseScore > 100) {
                                            // If the base score is not within the valid range, clear the text field
                                            _baseScoreController.clear();
                                          }
                                        }
                                      },
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
                                    bool isAllField = validateFields(context, [
                                      _criteriaNameController,
                                      _percentageController,
                                      _baseScoreController
                                    ]);
                                    if (!isAllField) {
                                      return;
                                    }
                                    // Calculate total percentage including the new criteria
                                    double newPercentage = double.tryParse(
                                            _percentageController.text) ??
                                        0.0;

                                    double updatedTotalPercentage =
                                        totalPercentage + newPercentage;
                                    print(updatedTotalPercentage);
                                    // Check if the new total percentage will exceed 100%
                                    if (updatedTotalPercentage <= 100.0) {
                                      Criteria newCriterias = Criteria(
                                          criterianame:
                                              _criteriaNameController.text ??
                                                  '',
                                          percentage: newPercentage.toString(),
                                          isSpecialAwards: false,
                                          eventId: widget.eventId,
                                          subCriteriaList: [], // Pass the current criteria's subcriteria list
                                          baseScore:
                                              _baseScoreController.text.isEmpty
                                                  ? "0"
                                                  : _baseScoreController.text);

                                      insertItem(newCriterias, "Main Criteria");
                                      _criteriaNameController.clear();
                                      _percentageController.clear();
                                      _baseScoreController.clear();

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
                        break;
                      case 'Special Awards':
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: const Center(
                                child: Text(
                                  'Add Special Awards',
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
                                      controller: _specialAwardsNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Special Award Name',
                                        labelStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: _baseScoreController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Base Score',
                                        labelStyle: TextStyle(
                                            fontSize: 15, color: Colors.green),
                                      ),
                                      onChanged: (value) {
                                        // Ensure the entered base score is a valid integer and not more than 100
                                        if (value.isNotEmpty) {
                                          int baseScore = int.tryParse(value) ??
                                              0; // Default to 0 if parsing fails
                                          if (baseScore < 0 ||
                                              baseScore > 100) {
                                            // If the base score is not within the valid range, clear the text field
                                            _baseScoreController.clear();
                                          }
                                        }
                                      },
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
                                    if (event?.event_category == "Pageants") {
                                      bool isAllField = validateFields(
                                          context, [
                                        _specialAwardsNameController,
                                        _baseScoreController
                                      ]);
                                      if (!isAllField) {
                                        return;
                                      }
                                      Criteria newCriterias = Criteria(
                                        criterianame:
                                            _specialAwardsNameController.text ??
                                                '',
                                        percentage: '0.0',
                                        isSpecialAwards: true,
                                        eventId: widget.eventId,
                                        subCriteriaList: [], // Pass the current criteria's subcriteria list
                                        baseScore: _baseScoreController.text,
                                      );

                                      insertItem(
                                          newCriterias, "Special Awards");
                                      _specialAwardsNameController.clear();
                                      _baseScoreController.clear();

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
                        break;
                    }
                  },
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                                removeItem(i, "Main Criteria");
                              }

                              for (int i = specialAwards.length - 1;
                                  i >= 0;
                                  i--) {
                                removeItem(i, "Special Awards");
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
                onPressed: isSending || criterias.isEmpty
                    ? null
                    : () async {
                        setState(() {
                          isSending = true;
                        });
                        try {
                          final double totalPercentage =
                              calculateTotalPercentage();
                          // if (totalPercentage != 100.0 || event?.event_category != "Pageants") {
                          //   _showErrorSnackBar(
                          //     'Error: Total percentage must be 100%. Current total: $totalPercentage%',
                          //     Colors.red,
                          //   );
                          //   return;
                          // }
                          if (totalPercentage == 100.0) {
                            if (criterias.isNotEmpty) {
                              for (final criteria in criterias) {
                                if (widget.eventId != null) {
                                  await createCriteria(widget.eventId!,
                                      criteria.toJson(), "Main Criteria");
                                } else {
                                  print('Error: Event ID is null');
                                }
                              }
                              for (final awards in specialAwards) {
                                if (widget.eventId != null) {
                                  await createCriteria(widget.eventId!,
                                      awards.toJson(), "Special Awards");
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
                                    'https://tabluprod.onrender.com/event/$eventId'),
                              );

                              if (response.statusCode == 200) {
                                event =
                                    Event.fromJson(jsonDecode(response.body));

                                // Navigate to the next screen or perform any other actions
                                if (widget.isEdit) {
                                  Navigator.pop(context);
                                } else {
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
                                }
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
                        finally {
                          setState(() {
                            isSending = false; // Set isSending to false when the process ends
                          });
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

  Widget parentMainCriteria(BuildContext context) {
    return AnimatedSize(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMainCriteriaOpen = !isMainCriteriaOpen;
                      });
                    },
                    child: Transform.rotate(
                      angle: isMainCriteriaOpen ? -pi / 75 : -pi / 2,
                      child: SizedBox(
                          height: 50,
                          child: Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.green,
                            size: 30,
                          )),
                    ),
                  ),
                ],
              ),
              title: Text(
                "Main Criteria",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 450), // Set maximum height
              height: isMainCriteriaOpen ? criterias.length * 120 : 0,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: criterias.length,
                itemBuilder: (context, index, animation) {
                  final criteria = criterias[index];
                  return ListItemWidget(
                    criteriaType: "Main Criteria",
                    criteria: criteria,
                    animation: animation,
                    onClicked: () => removeItem(index, "Main Criteria"),
                    onEdit: () => _editCriteria(context, criteria),
                    onAdd: () {},
                    event_category: event?.event_category,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, bottom: 16.0), // Add padding to the left
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${totalPercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget parentSpecialAwards(BuildContext context) {
    return AnimatedSize(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 500),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                        isSpecialAwardsOpen = !isSpecialAwardsOpen;
                      });
                    },
                    child: Transform.rotate(
                      angle: isSpecialAwardsOpen ? -pi / 75 : -pi / 2,
                      child: SizedBox(
                          height: 50,
                          child: Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.green,
                            size: 30,
                          )),
                    ),
                  ),
                ],
              ),
              title: Text(
                "Special Awards",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 450), // Set maximum height
              height: isSpecialAwardsOpen ? specialAwards.length * 120 : 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    return true;
                  }
                  return false;
                },
                child: AnimatedList(
                  key: _anotherListKey,
                  initialItemCount: specialAwards.length,
                  itemBuilder: (context, index, animation) {
                    final criteria = specialAwards[index];
                    final specialAward = specialAwards[index];
                    return ListItemWidget(
                      criteriaType: "Special Awards",
                      criteria: criteria,
                      specialAwards: specialAward,
                      animation: animation,
                      onClicked: () => removeItem(index, "Special Awards"),
                      onEdit: () => _editCriteria(context, criteria),
                      onAdd: () {},
                      event_category: event?.event_category,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItemSpecialWidget extends StatefulWidget {
  final Criteria criteria;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final event_category;

  ListItemSpecialWidget({
    required this.criteria,
    required this.animation,
    required this.onClicked,
    required this.onEdit,
    required this.onAdd,
    required this.event_category,
  });

  @override
  _ListItemSpecialWidgetState createState() => _ListItemSpecialWidgetState();
}

class _ListItemSpecialWidgetState extends State<ListItemSpecialWidget> {
  @override
  Widget build(BuildContext context) {
    // Implement your widget build method here
    return Container();
  }
}

class ListItemWidget extends StatefulWidget {
  final Criteria? criteria;
  final Criteria? specialAwards;
  final String criteriaType;
  final Animation<double> animation;
  final VoidCallback onClicked;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final event_category;

  ListItemWidget({
    this.criteria,
    this.specialAwards,
    required this.criteriaType,
    required this.animation,
    required this.onClicked,
    required this.onEdit,
    required this.onAdd,
    required this.event_category,
  });

  @override
  _ListItemWidgetState createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  bool isDropdownOpen = false;

  // Method to calculate the total percentage
  double? calculateTotalPercentage() {
    return widget.specialAwards?.subCriteriaList
        .map((subCriteria) => double.parse(subCriteria.percentage))
        .fold(0, (previousValue, element) => previousValue! + element);
  }

  // Method to update the main criteria's percentage
  void updateMainCriteriaPercentage() {
    print(calculateTotalPercentage().toString());
    setState(() {
      widget.specialAwards?.percentage = calculateTotalPercentage().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                '${widget.criteria?.criterianame}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Percentage: ${widget.criteria?.percentage}',
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this criteria?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  widget
                                      .onClicked(); // Call the deletion function
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                widget.criteria!.criterianame,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Percentage: ${widget.criteria!.percentage}',
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this criteria?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  widget
                                      .onClicked(); // Call the deletion function
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                        hintText:
                            'Enter ${widget.criteriaType == "Main Criteria" ? "sub-criteria" : "criteria"} name',
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
                        double totalPercentage = widget
                            .criteria!.subCriteriaList
                            .map((subCriteria) =>
                                double.parse(subCriteria.percentage))
                            .fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element);

                        // Parse the new subcriteria's percentage
                        double newPercentage =
                            double.parse(percentageController.text);

                        // Check if the new total percentage will exceed 100%
                        if (totalPercentage + newPercentage <= 100.0) {
                          final newSubCriteria = SubCriteria(
                            subCriteriaName: subCriteriaNameController.text,
                            percentage: percentageController.text,
                          );
                          setState(() {
                            widget.criteria!.subCriteriaList
                                .add(newSubCriteria);
                          });
                          if (widget.event_category == "Pageants") {
                            updateMainCriteriaPercentage();
                          }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            // This creates the horizontal line
            color: Colors.grey,
            thickness: 1, // Adjust thickness as needed
          ),
          // if (widget.criteria!.subCriteriaList.isNotEmpty || widget.specialAwards!.subCriteriaList.isNotEmpty) Text(widget.criteriaType),
          for (int index = 0;
              index < widget.criteria!.subCriteriaList.length;
              index++)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.criteria!.subCriteriaList[index].subCriteriaName,
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
                    '${widget.criteria!.subCriteriaList[index].percentage} %',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Deletion'),
                          content: Text(
                              'Are you sure you want to delete this sub-criteria?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                setState(() {
                                  widget.criteria!.subCriteriaList
                                      .removeAt(index);
                                  if (widget.event_category == "Pageants") {
                                    updateMainCriteriaPercentage();
                                  }
                                });
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          if (widget.criteriaType == "Main Criteria" &&
              widget.criteria!.subCriteriaList.isEmpty)
            Text("No Sub-criteria")
          else if (widget.criteriaType == "Special Awards" &&
              widget.specialAwards!.subCriteriaList.isEmpty)
            Text("No Criteria")
        ],
      ),
    );
  }
}
