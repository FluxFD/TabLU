import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/pages/eventinfo.dart';
import 'package:tutorial/pages/eventsjoined.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tutorial/utility/sharedPref.dart';

class Event {
  String eventId;
//  String accessCode;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
  final String eventTime;
  final List<Contestant> contestants;
  final List<Criteria> criterias;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventCategory,
    required this.eventVenue,
    required this.eventOrganizer,
    required this.eventDate,
    required this.eventTime,
    required this.contestants,
    required this.criterias,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['_id'] != null ? json['_id'].toString() : '',
      eventName: json['event_name'] != null ? json['event_name'].toString() : '',
      eventCategory:
          json['event_category'] != null ? json['event_category'].toString() : '',
      eventVenue:
          json['event_venue'] != null ? json['event_venue'].toString() : '',
      eventOrganizer: json['event_organizer'] != null
          ? json['event_organizer'].toString()
          : '',
      eventDate: json['event_date'] != null ? json['event_date'].toString() : '',
      eventTime: json['event_time'] != null ? json['event_time'].toString() : '',
      contestants: (json['contestants'] as List<dynamic>?)
          ?.map((contestant) => Contestant.fromJson(contestant))
          .toList() ??
          [],
      criterias: (json['criterias'] as List<dynamic>?)
          ?.map((criteria) => Criteria.fromJson(criteria))
          .toList() ??
          [],
    );
  }
}

class Contestant {
  String name;
  String course;
  String department;
  String eventId;
  List<Criteria> criterias;
  String? profilePic;
  String? selectedImage;
  String? id;
  int totalScore;
  List<int?> criteriaScores;
  Contestant({
    required this.name,
    required this.course,
    required this.department,
    required this.eventId,
    required this.criterias,
    this.profilePic,
    this.selectedImage,
    this.id,
    required this.totalScore,
    required this.criteriaScores,
  });
  Contestant copyWith({
    String? name,
    String? course,
    String? department,
    String? eventId,
    List<Criteria>? criterias,
    String? profilePic,
    String? selectedImage,
    String? id,
    int? totalScore,
    List<int?>? criteriaScores,
  }) {
    return Contestant(
      name: name ?? this.name,
      course: course ?? this.course,
      department: department ?? this.department,
      eventId: eventId ?? this.eventId,
      criterias: criterias ?? List.unmodifiable(this.criterias),
      profilePic: profilePic ?? this.profilePic,
      selectedImage: selectedImage ?? this.selectedImage,
      id: id ?? this.id,
      totalScore: totalScore ?? this.totalScore,
      criteriaScores: criteriaScores ?? List.unmodifiable(this.criteriaScores),
    );
  }

  factory Contestant.fromJson(Map<String, dynamic> json) {
    List<dynamic>? criteriaList = json['criterias'] as List<dynamic>?;
    print('Raw JSON: $json');
    print('criteriaList: $criteriaList');
    return Contestant(
      name: json['name'] != null ? json['name'].toString() : '',
      course: json['course'] != null ? json['course'].toString() : '',
      department:
          json['department'] != null ? json['department'].toString() : '',
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      criterias: criteriaList != null
          ? List.unmodifiable(
              criteriaList.map((criteria) => Criteria.fromJson(criteria)))
          : [],
      profilePic:
          json['profilePic'] != null ? json['profilePic'].toString() : '',
      selectedImage:
          json['selectedImage'] != null ? json['selectedImage'].toString() : '',
      id: json['id'] != null ? json['id'].toString() : '',
      totalScore: json['totalScore'] != null ? json['totalScore'] : 0,
      criteriaScores: criteriaList != null && criteriaList.isNotEmpty
          ? List<int?>.from(
              criteriaList.map((criteria) => criteria['score'] as int? ?? 0))
          : List<int?>.filled(criteriaList?.length ?? 0, null, growable: true),
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contestant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Criteria {
  String criterianame;
  String percentage;
  String eventId;
  int score;
  Criteria({
    required this.criterianame,
    required this.percentage,
    required this.eventId,
    required this.score,
  });

  Criteria copyWith({
    String? criterianame,
    String? percentage,
    String? eventId,
    int? score,
  }) {
    return Criteria(
      criterianame: criterianame ?? this.criterianame,
      percentage: percentage ?? this.percentage,
      eventId: eventId ?? this.eventId,
      score: score ?? this.score,
    );
  }

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      criterianame:
          json['criterianame'] != null ? json['criterianame'].toString() : '',
      percentage:
          json['percentage'] != null ? json['percentage'].toString() : '',
      eventId: json['eventId'] != null ? json['eventId'].toString() : '',
      score: json['score'] != null ? int.parse(json['score'].toString()) : 0,
    );
  }
}

class EventCalendarScreen extends StatefulWidget {
  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();
  List<Event> events = [];
  Map<DateTime, List<Event>> eventsByDate = {};

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Fetch events when the screen is initialized
  }
  void eventLoader(List<Event> events) {
    eventsByDate.clear();

    for (Event event in events) {
      DateTime eventDateTime = eventDateFromString(event.eventDate);
      print("String ${eventDateTime}");
      if (!eventsByDate.containsKey(eventDateTime)) {
        eventsByDate[eventDateTime] = [];
      }
      eventsByDate[eventDateTime]!.add(event);
    }
  }

  void fetchEvents() async {
    try {
      String? token = await SharedPreferencesUtils.retrieveToken();
      String? userId;
      if (token != null && token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      }
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/calendar-events/$userId'));
      if (response.statusCode == 200) {
        print(response);
        final List<dynamic> data = json.decode(response.body);
        print('Fetched Events: $data');
        // Update the events list
        setState(() {
          events = data.map((json) => Event.fromJson(json)).toList();
          print('Fetched Events: $events');
          eventLoader(events);
        });
      } else {
        // Handle error
        print('Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Exception during data fetch: $e');
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDay = day;
      print('Selected Day: $selectedDay');
      print('Events for Selected Day: ${getEventsForSelectedDay()}');
    });

    // Fetch events for the selected day
    fetchEvents();
  }

  List<Event> getEventsForSelectedDay() {
    DateTime selectedDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    print('Selected Date: $selectedDate');

    List<Event> selectedEvents = events
        .where((event) =>
            isSameDay(eventDateFromString(event.eventDate), selectedDate))
        .toList();

    print('Selected Events: ${selectedEvents.length}');

    return selectedEvents;
  }

  DateTime eventDateFromString(String date) {
    try {
      // Assuming 'eventDate' is in the format 'yyyy-MM-ddTHH:mm:ss.SSSZ'
      return DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parseUTC(date);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Event Calendar',
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
            Navigator.pop(context); // Use pop to navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: Column(
          children: [
            TableCalendar(
              locale: 'en_us',
              rowHeight: 80, // Adjust the row height as needed

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              focusedDay: today,
              onDaySelected: _onDaySelected,
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              firstDay: DateTime.utc(2000, 01, 01),
              lastDay: DateTime.utc(2030, 01, 01),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, events) {
                  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  final dateEvents = eventsByDate[date] ?? [];
                  print('Formatted Date: $formattedDate');
                  print('Date Events: $dateEvents');
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSameDay(date, selectedDay)
                                ? Colors.white
                                : null,
                          ),
                        ),

                        if (dateEvents.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.all(4.0),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (getEventsForSelectedDay().isNotEmpty)
              Flexible(
                child: Container(
                  color: Colors.grey[200],
                  child: ListView.builder(
                    itemCount: getEventsForSelectedDay().length,
                    itemBuilder: (context, index) {
                      final event = getEventsForSelectedDay()[index];
                      return ListTile(
                        title: Text("${event.eventName} ${event.eventTime}"),
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

class CodeModel {
  String eventId;
  String name;
  String iconPath;
  String level;
  bool boxIsSelected;

  CodeModel({
    required this.eventId,
    required this.name,
    required this.iconPath,
    required this.level,
    required this.boxIsSelected,
  });

  Widget buildClickableItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the corresponding screen when the item is tapped
        if (name == 'Create events') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(),
            ),
          );
        } else if (name == 'Events Joined') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventsJoined(),
            ),
          );
        } else if (name == 'Event calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCalendarScreen(),
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

  static List<CodeModel> getCode() {
    List<CodeModel> code = [];

    code.add(
      CodeModel(
        eventId: '',
        name: 'Create Events',
        iconPath: 'assets/icons/add-event-calendar-svgrepo-com.svg',
        level: 'Click here to create events',
        boxIsSelected: false,
      ),
    );

    code.add(
      CodeModel(
        eventId: '',
        name: 'Event Calendar',
        iconPath: 'assets/icons/event-svgrepo-com.svg',
        level: 'Click here to see event calendar',
        boxIsSelected: false,
      ),
    );

    return code;
  }
}
