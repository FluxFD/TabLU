import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/main.dart';
import 'dart:math';
import 'dart:convert';
import 'package:tutorial/pages/contestants.dart' as contestants;
import 'package:tutorial/pages/searchevents.dart';
import 'package:tutorial/pages/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Event {
  final String eventId;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
  final String eventTime;
  final List<Contestant> contestants;
  //final String userId; 

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventCategory,
    required this.eventVenue,
    required this.eventOrganizer,
    required this.eventDate,
    required this.eventTime,
    required this.contestants,
   // required this.userId
  });
}



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
  String? accessCode;
  String? eventId;

  @override
  void initState() {
    super.initState();
    accessCode = generateRandomAccessCode(8);
    if(isAdding == false){

    }
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
Future<void> saveToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
}
Future<String?> retrieveToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
  
Future<String?> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8080/login'), // Replace with your actual authentication endpoint
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final token = jsonDecode(response.body)['token'];
    await saveToken(token);

    return token;
  } else {
    print('Login failed: ${response.body}');
    return null;
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
  onPressed: () {
   // var jsonResponse = json.decode(res.body);
   // var myToken = jsonResponse['token'];
   // prefs.setString('token', myToken);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchEvents(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NTY2N2UzY2EwODcyZGI0NTNjZGFlOGQiLCJlbWFpbCI6ImF1YnJleWRhbm83QGdtYWlsLmNvbSIsInVzZXJuYW1lIjoiYWRtaW4xMjMiLCJpYXQiOjE3MDE1NjMzMDgsImV4cCI6MTcwMTU2NjkwOH0.lTl3R223HHLxj-vO1dJ1ulmGT1kPLOb2El_U-XZB1t4"),
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
    final createdEventId = await createEvent(event, authToken);
    if (createdEventId != null) {
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

    return {
      "eventName": eventName,
      "eventCategory": eventCategory,
      "eventVenue": eventVenue,
      "eventOrganizer": eventOrganizer,
      "eventDate": eventDate,
      "eventTime": eventTime,
      "accessCode": accessCode,
     // "userId": userId,
    };
  }
  
Future<String?> createEvent(Map<String, dynamic> eventData, String authToken) async {
  eventData["accessCode"] = generateRandomAccessCode(8);

  final response = await http.post(
    Uri.parse('http://10.0.2.2:8080/events'), // Use Uri.parse to convert the string to Uri
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
    print('Failed to create event: ${response.body}');
    return null;
  }
}
}
