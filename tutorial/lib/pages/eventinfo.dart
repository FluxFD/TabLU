import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/main.dart';
import 'dart:math';
import 'dart:convert';
import 'package:tutorial/pages/contestants.dart' as contestants;
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/pages/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/utility/sharedPref.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final items = ['Pageants', 'Talent Shows', 'Debates', 'Art Contests'];
  String? selectedCategory;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _organizerController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  String? accessCode = "";
  String? eventId;
  String? token;
  bool isCopied = false;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    if (isAdding == false) {}
    //print('Generated Access Code: $accessCode');
  }

  String generateRandomAccessCode(int length) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => charset.codeUnitAt(random.nextInt(charset.length)),
    ));
  }

  Future<String?> retrieveToken() async {
    return await SharedPreferencesUtils.retrieveToken();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Event Information',
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
          onPressed: () async {
            // Retrieve the token asynchronously
            String? token = await retrieveToken();
            // Navigate to the SearchEvents screen with the retrieved token
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchEvents(token: token),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          //height: 603,

          child: Card(
            color: Colors.white,
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Name',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _eventNameController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text(
                            'Event Category',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                        SizedBox(
                          width: 150,
                          child: DropdownButton<String>(
                            elevation: 20,
                            value: selectedCategory,
                            iconSize: 30,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.green,
                            ),
                            items: items.map(buildMenuItem).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Venue',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _venueController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Organizer',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _organizerController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 145),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'DATE',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 105),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              labelText: 'TIME',
                              prefixIcon: Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectTime();
                            },
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 110),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _endDateController,
                            decoration: const InputDecoration(
                              labelText: 'END DATE',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectEndDate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Add end time input field
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 105),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'END TIME',
                              prefixIcon: Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectEndTime();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                _eventNameController.clear();
                setState(() {
                  selectedCategory = null;
                });
                _venueController.clear();
                _organizerController.clear();
                _dateController.clear();
                _timeController.clear();
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
              onPressed: isButtonDisabled ? null : () async {
                setState(() {
                  isButtonDisabled = true; // Disable the button
                });
                final String? authToken = await retrieveToken();
                if (authToken != null) {
                  final event = createEventFromControllers();
                  final createdEventId = await createEvent(event, authToken);
                  if (createdEventId != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        // Use a separate StatefulWidget to manage state within the dialog
                        return EventCreatedDialog(accessCode: accessCode, eventId: createdEventId);
                      },
                    );
                  }
                } else {
                  // Handle the case where login fails
                  print('Failed to create an Event');
                }
                setState(() {
                  isButtonDisabled = false; // Re-enable the button after the operation is complete
                });
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
              child: const Text('APPLY'),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _endDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectEndTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTimeController.text = picked.format(context);
      });
    }
  }


  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );

  Map<String, dynamic> createEventFromControllers() {
    String eventName = _eventNameController.text;
    String eventCategory = selectedCategory ?? '';
    String eventVenue = _venueController.text;
    String eventOrganizer = _organizerController.text;
    String eventDate = _dateController.text;
    String eventTime = _timeController.text;
    String eventEndDate = _endDateController.text;
    String eventEndTime= _endTimeController.text;
    return {
      "eventName": eventName,
      "eventCategory": eventCategory,
      "eventVenue": eventVenue,
      "eventOrganizer": eventOrganizer,
      "eventDate": eventDate,
      "eventTime": eventTime,
      "eventEndDate": eventEndDate,
      "eventEndTime": eventEndTime,
      "accessCode": accessCode,
      // "userId": userId,
    };
  }

  Future<String?> createEvent(
      Map<String, dynamic> eventData, String authToken) async {
        accessCode = generateRandomAccessCode(8);
      eventData["accessCode"] = accessCode;
      print(eventData["accessCode"]);
    final response = await http.post(
      Uri.parse(
          'http://192.168.1.8:8080/events'), // Use Uri.parse to convert the string to Uri
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      final eventInfo = jsonDecode(response.body);
      final eventId = eventInfo["_id"];

      print('Event created successfully');
      return eventId;
    } else {
      String? token = await retrieveToken(); //debugging purposes
      print("JWT Token ${token}"); //debugging purposes
      print('Failed to create event: ${response.body}');
      return null;
    }
  }
}

/////////////////////////EDIT SECTION //////////////////////////////

class EditEventScreen extends StatefulWidget {
  final String eventId;
  EditEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventScreen createState() => _EditEventScreen();
}

class _EditEventScreen extends State<EditEventScreen> {
  final items = ['Pageants', 'Talent Shows', 'Debates', 'Art Contests'];

  Future<List<Event>> fetchEventData(String? eventId) async {
    token = await SharedPreferencesUtils.retrieveToken();
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.8:8080/event/$eventId'));

      if (response.statusCode == 200) {
        final dynamic eventData = json.decode(response.body);

        if (eventData is List) {
          // Handle the case where eventData is a list
          // Depending on your use case, you might want to choose an appropriate action here.
          print('Received a list of events: $eventData');
          return []; // Return an empty list or handle appropriately
        } else if (eventData is Map<String, dynamic>) {
          // If the response is a single event, wrap it in a list
          // print(eventData);
          // List<dynamic> events = [Event.fromJson(eventData)];
          // Populate the UI fields with the fetched event data
          print(eventData["eventDate"]);
          _dateController.text = eventData["eventDate"].split("T")[0];
          _timeController.text = eventData["eventTime"];
          _endDateController.text = eventData["eventEndDate"].split("T")[0];
          _endTimeController.text = eventData["eventEndTime"];
          _eventNameController.text = eventData["eventName"];
          _venueController.text = eventData["eventVenue"];
          _organizerController.text = eventData["eventOrganizer"];
          //Set the selected category
          setState(() {
            selectedCategory = eventData["eventCategory"];
            ;
          });

          // Set the accessCode and eventId
          // accessCode = events.first.accessCode;
          // eventId = events.first.eventId;

          return [];
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

  String? selectedCategory;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _organizerController = TextEditingController();
  String? eventId;
  String? token;

  @override
  void initState() {
    super.initState();
    print("Event ID: ${widget.eventId}");
    if (widget.eventId != null) {
      fetchEventData(widget.eventId);
    }

    if (isAdding == false) {}
    //print('Generated Access Code: $accessCode');
  }



  Future<String?> retrieveToken() async {
    return await SharedPreferencesUtils.retrieveToken();
  }

  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _endDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectEndTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTimeController.text = picked.format(context);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Event Information',
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
          onPressed: () async {
            // Retrieve the token asynchronously
            String? token = await retrieveToken();
            // Navigate to the SearchEvents screen with the retrieved token
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchEvents(token: token),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          //height: 603,

          child: Card(
            color: Colors.white,
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Name',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _eventNameController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text(
                            'Event Category',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                        SizedBox(
                          width: 150,
                          child: DropdownButton<String>(
                            elevation: 20,
                            value: selectedCategory,
                            iconSize: 30,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.green,
                            ),
                            items: items.map(buildMenuItem).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Venue',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _venueController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    'Organizer',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 370,
                        height: 40,
                        child: TextField(
                          controller: _organizerController,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 5, 70, 20),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 145),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'DATE',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 105),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              labelText: 'TIME',
                              prefixIcon: Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectTime();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 110),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _endDateController,
                            decoration: const InputDecoration(
                              labelText: 'END DATE',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectEndDate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Add end time input field
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 105),
                        SizedBox(
                          width: 180,
                          height: 35,
                          child: TextField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'END TIME',
                              prefixIcon: Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectEndTime();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                _eventNameController.clear();
                setState(() {
                  selectedCategory = null;
                });
                _venueController.clear();
                _organizerController.clear();
                _dateController.clear();
                _timeController.clear();
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
                final String? authToken = await retrieveToken();
                if (authToken != null) {
                  final event = createEventFromControllers();
                  final createdEventId =
                      await editEvent(event, authToken, widget.eventId);
                  if (createdEventId != null) {
                    // Show snackbar when event is successfully edited
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Event edited successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            contestants.Contestants(eventId: createdEventId)));
                  }
                } else {
                  // Handle the case where login fails
                  print('Failed to create an Event');
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
              child: const Text('APPLY'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );

  Map<String, dynamic> createEventFromControllers() {
    String eventName = _eventNameController.text;
    String eventCategory = selectedCategory ?? '';
    String eventVenue = _venueController.text;
    String eventOrganizer = _organizerController.text;
    String eventDate = _dateController.text;
    String eventTime = _timeController.text;
    String eventEndDate = _endDateController.text;
    String eventEndTime= _endTimeController.text;
    return {
      "eventName": eventName,
      "eventCategory": eventCategory,
      "eventVenue": eventVenue,
      "eventOrganizer": eventOrganizer,
      "eventDate": eventDate,
      "eventTime": eventTime,
      "eventEndDate": eventEndDate,
      "eventEndTime": eventEndTime,
      // "userId": userId,
    };
  }

  Future<String?> editEvent(
      Map<String, dynamic> eventData, String authToken, String eventId) async {
    final response = await http.put(
      Uri.parse(
          'http://192.168.1.8:8080/events/$eventId'), // Include eventId in the URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 200) {
      final eventInfo = jsonDecode(response.body);
      final editedEventId = eventInfo["eventId"];
      print('Event edited successfully');
      return editedEventId;
    } else {
      String? token = await retrieveToken(); // Debugging purposes
      print("JWT Token ${token}"); // Debugging purposes
      print('Failed to edit event: ${response.body}');
      return null;
    }
  }
}

class EventCreatedDialog extends StatefulWidget {
  final String? accessCode;
  final String eventId;

  const EventCreatedDialog({Key? key, required this.accessCode, required this.eventId}) : super(key: key);

  @override
  _EventCreatedDialogState createState() => _EventCreatedDialogState();
}

class _EventCreatedDialogState extends State<EventCreatedDialog> {
  bool isCopied = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Event Created',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ACCESS CODE: ${widget.accessCode}'),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '${widget.accessCode}'));
    // Use a boolean flag to check if the widget is still mounted
                    if (mounted) {
                      setState(() {
                        isCopied = true;
                      });
                    }
                    Future.delayed(Duration(seconds: 2), () {
                    // Check if the widget is still mounted before calling setState
                    if (mounted) {
                    setState(() {
                    isCopied = false;
                    });
                    }
                    });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCopied ? Colors.grey : Colors.green,
                ),
                child: Text(
                  isCopied ? 'Copied to Clipboard' : 'Copy to Clipboard',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          contestants.Contestants(eventId: widget.eventId)));
                  // Do something when the "Close" button is pressed
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}
