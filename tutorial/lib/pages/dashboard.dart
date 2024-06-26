import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/authstate.dart';
import 'package:tutorial/models/categorymodel.dart'; // as CategoryModel;
import 'package:tutorial/models/codemodel.dart' as CodeModel;
import 'package:tutorial/pages/editprofile.dart';
import 'package:tutorial/pages/eventinfo.dart';
import 'package:tutorial/pages/eventsmanagement.dart';
import 'package:tutorial/pages/eventsjoined.dart';
import 'package:tutorial/pages/forgotpassword.dart';
import 'package:tutorial/pages/getstarted.dart';
import 'package:tutorial/pages/help.dart';
import 'package:tutorial/pages/notification.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tutorial/utility/sharedPref.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:firebase_messaging/firebase_messaging.dart';


final io.Socket socket =
io.io('https://tabluprod.onrender.com', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

TextEditingController searchController = TextEditingController();

class Event {
  String eventId;
  String accessCode;
  final String eventName;
  final String eventCategory;
  final String eventVenue;
  final String eventOrganizer;
  final String eventDate;
  final String eventTime;
  // final List<Contestant> contestants;
  // final List<Criteria> criterias;
  Event({
    required this.eventId,
    required this.accessCode,
    required this.eventName,
    required this.eventCategory,
    required this.eventVenue,
    required this.eventOrganizer,
    required this.eventDate,
    required this.eventTime,
    // required this.contestants,
    // required this.criterias,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'accessCode': accessCode,
      'eventName': eventName,
      'eventCategory': eventCategory,
      'eventVenue': eventVenue,
      'eventOrganizer': eventOrganizer,
      'eventDate': eventDate,
      'eventTime': eventTime,
      // 'contestants':
      //     contestants.map((contestant) => contestant.toJson()).toList(),
      // 'criterias': criterias.map((criteria) => criteria.toJson()).toList(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['_id'] is String ? json['_id'] : '',
      accessCode: json['access_code'] is String ? json['access_code'] : '',
      eventName: json['event_name'] is String ? json['event_name'] : '',
      eventCategory:
          json['event_category'] is String ? json['event_category'] : '',
      eventVenue: json['event_venue'] is String ? json['event_venue'] : '',
      eventOrganizer:
          json['event_organizer'] is String ? json['event_organizer'] : '',
      eventDate: json['event_date'] is String ? json['event_date'] : '',
      eventTime: json['event_time'] is String ? json['event_time'] : '',
      // contestants: (json['contestants'] is List)
      //     ? (json['contestants'] as List)
      //         .map((e) => Contestant.fromJson(e))
      //         .toList()
      //     : [],
      //   criterias: (json['criteria'] is List)
      //       ? (json['criteria'] as List).map((e) => Criteria.fromJson(e)).toList()
      //       : [],
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
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'course': course,
      'department': department,
      'eventId': eventId,
      'criterias': criterias.map((criteria) => criteria.toJson()).toList(),
      'profilePic': profilePic,
      'selectedImage': selectedImage,
      'id': id,
      'totalScore': totalScore,
      'criteriaScores': criteriaScores,
    };
  }

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

  Map<String, dynamic> toJson() {
    return {
      'criterianame': criterianame,
      'percentage': percentage,
      'eventId': eventId,
      'score': score,
    };
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

class SearchEvents extends StatefulWidget {
  final token;

  const SearchEvents({required this.token, Key? key}) : super(key: key);

  @override
  State<SearchEvents> createState() => _SearchEventsState();
}

late AuthState authState;

class _SearchEventsState extends State<SearchEvents> {
  late CodeModel.Event eventInstance;
  List<CategoryModel> categories = [];
  List<CodeModel.CodeModel> code = [];
  late String email = "";
  late String username = "";
  String _id = '';
  String event_name = '';
  String event_date = '';
  String event_time = '';
  String event_category = '';
  String event_organizer = '';
  String event_venue = '';
  String? profilePic = '';
  List<String> contestants = [];
  List<String> criterias = [];
  int notificationCount = 0;
  File? _image;


  @override
  void initState() {
    super.initState();
    _getInitialInfo();
    _decodeToken();
    loadNotificationCount();
    fetchAndCountNotifications();
    // Connect to socket only if it's not already connected
    if (!socket.connected) {
      socket.connect();
      socket.onConnect((_) {
        print('Socket connected');
      });
    }

    socket.on('newNotification', (data) {
      fetchAndCountNotifications();
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });
    socket.onError((error) {
      print('Socket error: $error');
    });

    authState = Provider.of<AuthState>(context, listen: false);
  }

  void _getInitialInfo() {
    categories = CategoryModel.getCategories();
    code = CodeModel.CodeModel.getCode();
    eventInstance = CodeModel.Event(
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
  }


  void sendPushNotification() async {
    try {
      // Prepare the notification message
      String notificationTitle = 'New Notification';
      String notificationBody = 'You have a new notification';

      // Send the notification to the user's device
      // await _firebaseMessaging.send(
      //   RemoteMessage(
      //     notification: Notification(
      //       title: notificationTitle,
      //       body: notificationBody,
      //     ),
      //     // Add any additional data if needed
      //   ),
      // );

      print('Push notification sent successfully');
    } catch (error) {
      print('Error sending push notification: $error');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    _showImageDialog();
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    if (_image != null) {
      _uploadProfilePic(_image);
    } else {
      print('Image is null. Unable to upload.');
    }
  }

  Future<void> _uploadProfilePic(File? imageFile) async {
    if (imageFile == null) {
      print('Image is null. Unable to upload.');
      return;
    }

    final String serverUrl = 'https://tabluprod.onrender.com/upload-profilePic';
    final Uri uri = Uri.parse(serverUrl);

    try {
      // Retrieve user information (userId) from token
      String? token = await SharedPreferencesUtils.retrieveToken();
      String userId;

      // Check if the token is not null before decoding
      if (token != null && token.isNotEmpty) {
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'];
      } else {
        print('Token is null or empty. Unable to retrieve userId.');
        return;
      }

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add the image file and userId to the request
      var profilePic = await http.MultipartFile.fromPath(
        'profilePic',
        imageFile.path ?? '', // Provide a default value if path is null
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(profilePic);
      request.fields['userId'] = userId; // Add userId as a field in the request

      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        fetchProfilePic(userId);
        print('Profile picture uploaded successfully');
      } else {
        print(
            'Failed to upload profile picture. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading profile picture: $error');
    }
  }

  Future<void> loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedCount = prefs.getInt('notificationCount') ?? 0;
    // Compare the saved count with the current count
    if (savedCount != notificationCount) {
      setState(() {
        notificationCount = savedCount;
      });
    }
  }


  Future<void> saveNotificationCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationCount', count);
  }

  Future<void> fetchAndCountNotifications() async {
    try {
      // Retrieve the token from shared preferences
      String? token = await SharedPreferencesUtils.retrieveToken();

      // Check if the token is not null before decoding
      if (token != null && token.isNotEmpty) {
        // Decode the token to extract user information
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['userId'];

        // Make the API request with the userId
        final response = await http.get(
            Uri.parse('https://tabluprod.onrender.com/get-notifications/$userId'));

        if (response.statusCode == 200) {
          List<dynamic> notifications = json.decode(response.body);
          setState(() {
            notificationCount = notifications.length;
          });
          saveNotificationCount(notificationCount);
        } else {
          // Handle server errors (e.g., 404, 500)
          print('Server error: ${response.statusCode}');
        }
      } else {
        // Handle case where the token is null
        print('Token is null. Unable to fetch notifications.');
      }
    } catch (e) {
      // Handle any exceptions (e.g., network error)
      print('Error fetching notifications: $e');
    }
  }

  Future<List<Event>> fetchEvents(String accessCode) async {
    try {
      String? token = await SharedPreferencesUtils.retrieveToken();
      if (token == null) {
        print('No token found in shared preferences');
        return [];
      }

      final url = Uri.parse("https://tabluprod.onrender.com/events/$accessCode");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final dynamic responseBody = jsonDecode(response.body);

          if (responseBody is List) {
            // It's a JSON array
            List<Event> events = responseBody.map((eventJson) {
              return Event.fromJson(eventJson);
            }).toList();
            return events;
          } else if (responseBody is Map<String, dynamic>) {
            // It's a single JSON object
            Event event = Event.fromJson(responseBody);
            return [event];
          } else {
            print('Unexpected JSON format');
            return [];
          }
        } catch (e) {
          print('Error parsing JSON: $e');
          return [];
        }
      } else {
        print('Error fetching events: ${response.body}');
        throw Exception('Failed to load events. Error: ${response.body}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to load events. Error: $e');
    }
  }

  void _decodeToken() async {
    try {
      // Retrieve the token from shared preferences
      String? token = await SharedPreferencesUtils.retrieveToken();

      if (token != null && token.isNotEmpty) {
        // Decode the token
        Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
        print("Jwt Token: ${jwtDecodedToken}");

        // Use the decoded token data as required
        setState(() {
          email = jwtDecodedToken['email']?.toString() ??
              'DefaultEmail@example.com';
          username =
              jwtDecodedToken['username']?.toString() ?? 'DefaultUsername';
        });
        await fetchProfilePic(jwtDecodedToken['userId'].toString());
      } else {
        print('No token found');
        setState(() {
          email = 'Guest@example.com';
          username = 'Guest';
        });
      }
    } catch (e) {
      print('Error decoding token: $e');
      setState(() {
        email = 'Guest@example.com';
        username = 'Guest';
      });
    }
  }

  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>> fetchNotifications(String userId) async {
    final response = await http.get(
      Uri.parse('https://tabluprod.onrender.com/get-notifications/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> fetchProfilePic(String userId) async {
    print("User id : ${userId}");
    // Replace 'your-api-endpoint' with the actual API endpoint for fetching user data
    Uri usersCollectionUri =
        Uri.parse('https://tabluprod.onrender.com/get-username/$userId');
    try {
      // Make a GET request to the users collection
      final response = await http.get(usersCollectionUri);
      if (response.statusCode == 200) {
        // Parse the response body
        final users = json.decode(response.body);
        print(users);
        if (users != null) {
          // Extract the profilePic from the user data
          setState(() {
            profilePic = users['profilePic'];
          });
          // Here you can use the profilePic as needed (e.g., display in an Image widget).
        } else {
          print('User not found with userId: $userId');
        }
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 270,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Container(
                              height: 150,
                              width: 150,
                              child: ClipOval(
                                child: _image == null
                                    ? Image.network(
                                        profilePic ??
                                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/icons/408-4087421_person-svg-circle-icon-picture-charing-cross-tube.png',
                                            fit: BoxFit.cover,
                                            width: 64,
                                            height: 64,
                                          );
                                        },
                                      )
                                    : Image.file(
                                        _image!,
                                        fit: BoxFit.fitWidth,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              '${username}', // '${user.username}',
                              style: const TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(255, 5, 70, 20),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        Center(
                          child: Text(
                            '${email}', // ${user.email}
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    height: 70,
                    width: 500,
                    child: Card(
                      child: Container(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.password),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Forgotpass()));
                                            },
                                            child: Text('Change Password')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press as per your requirements
        // Return false to disable the back button press
        return false;
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: Text(
          'TabLU',
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Color.fromARGB(255, 5, 78, 7),
                ),
                onPressed: () async {
                  // Retrieve the token from shared preferences
                  String? token = await SharedPreferencesUtils.retrieveToken();

                  if (token != null && token.isNotEmpty) {
                    // Decode the token to get the userId
                    Map<String, dynamic> jwtDecodedToken =
                        JwtDecoder.decode(token);
                    String userId = jwtDecodedToken['userId'];
                    // Navigate to the Notif screen with the retrieved userId
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Notif(userId: userId),
                    ));
                  } else {
                    // Handle the case where the token is not available
                    print('No token found');
                  }
                },
              ),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/appheader.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  /* AlertDialog(actions: [Widget],)
                 */
                  _showImageDialog();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color.fromARGB(255, 76, 152, 79),
                      child: ClipOval(
                        child: _image != null
                            ? Image.file(
                                _image!, // Assuming _image is of type File
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                              )
                            : Image.network(
                                profilePic ??
                                    'https://example.com/default-image.jpg',
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) {
                                  // If the network image fails to load, display the asset image
                                  return Image.asset(
                                    'assets/icons/408-4087421_person-svg-circle-icon-picture-charing-cross-tube.png',
                                    fit: BoxFit.cover,
                                    width: 64,
                                    height: 64,
                                  );
                                },
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.leaderboard_outlined),
              title: const Text('Event Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventsManagement()),
                );
              },
            ),
            /*
              ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Criteria'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
              ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Category'),
              onTap: () {
                Navigator.pop(context);
              },
            ),*/

            /*  ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help and FAQ's"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpandFaq(),
                  ),
                );
              },
            ),

            //TODO: I have problems in login out
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                /*
               Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const getStarted(),
                  ),
                );*/

                authState.logout(context); // This will clear the app state
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const getStarted(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(children: [
        searchField(searchController),
        const SizedBox(height: 20),

        categoriesSection(categories),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 25.0),
          child: Text(
            'Other Events',
            style: TextStyle(
              color: Color.fromARGB(255, 5, 70, 20),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        joinedEvents(),

        const SizedBox(height: 30),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                offset: const Offset(0, 0),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    'Manage Events',
                    style: TextStyle(
                      color: Color.fromARGB(255, 5, 70, 20),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
              ),
              ListView.separated(
                itemCount: code.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (code[index].name == 'Create Events') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreateEventScreen()));
                      } else if (code[index].name == 'Event Calendar') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CodeModel.EventCalendarScreen(),
                          ),
                          // Remove all routes from the stack
                        );
                      }
                    },
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                code[index].iconPath,
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code[index].name,
                                    style: const TextStyle(
                                      color: Color(0xFF054E07),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    code[index].level,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // i just added this
        // Text('This is the email' + email),
      ]),
    ),
    );
  }

  Container searchField(TextEditingController searchController) {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(10),
                  hintText: ' Search or enter code',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 143, 137, 137),
                    fontSize: 14,
                  ),
                  prefixIcon: SizedBox(
                      width: 10,
                      height: 10,
                      child: SvgPicture.asset('assets/icons/search.svg')),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            TextButton(
              onPressed: () async {
                String accessCode = searchController.text;

                if (accessCode.isNotEmpty) {
                  try {
                    List<Event> events = await fetchEvents(accessCode);
                    if (events.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JoinEvents(events: events.first),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'No events found for the given access code.'),
                          backgroundColor:
                              Colors.orange, // Choose a suitable color
                        ),
                      );
                    }
                  } catch (e) {
                    // Handle errors here, for example, show an error message
                    print('Error fetching events: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Failed to fetch events. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.green,
                ),
                fixedSize: MaterialStateProperty.all(const Size(90.0, 40.0)),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container joinedEvents() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
          ),
          Container(
            height: 100,
            width: 500,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsJoined(),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event, // Replace with the desired icon
                        color: Colors.black,
                        size: 50,
                      ),
                      SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Joined Events",
                              style: const TextStyle(
                                color: Color(0xFF054E07),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Click here to see the events you've joined",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column categoriesSection(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Event Categories',
            style: TextStyle(
              color: Color.fromARGB(255, 5, 70, 20),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          height: 135,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(
              width: 15,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to the corresponding screen when the item is tapped
                  if (categories[index].name == 'Pageants') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PageantsScreen(event: eventInstance),
                      ),
                    );
                  } else if (categories[index].name == 'Talent Shows') {
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
                          ),
                        ),
                      ),
                    );
                  } else if (categories[index].name == 'Debates') {
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
                          ),
                        ),
                      ),
                    );
                  } else if (categories[index].name == 'Art Contest') {
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
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: categories[index].boxColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(categories[index].iconPath),
                        ),
                      ),
                      Text(
                        categories[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 5, 70, 20),
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class EventApi {
  static Future<void> requestJoinEvent(String eventId) async {
    try {
      String? token = await SharedPreferencesUtils.retrieveToken();
      if (token == null || token.isEmpty) {
        print('No token found');
        return;
      }
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];

      final response = await http.post(
        Uri.parse("https://tabluprod.onrender.com/api-join-event"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'eventId': eventId,
        }),
      );

      if (response.statusCode == 200) {
        print('Join request successful');
        print('sending notification');

        // Notify the receiver (organizer)
        await NotificationApi.sendJoinNotification(
          userId: userId,
          eventId: eventId,
        );
      }
      else {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print('Join request failed: ${response.reasonPhrase}');
        throw Exception('${responseBody['message']}');
      }
    } catch (e) {
      print('Error during join request: $e');
      throw Exception('$e');
    }
  }
}

class NotificationApi {
  static Future<void> sendJoinNotification({
    required String userId,
    required String eventId,
  }) async {
    try {
      // Retrieve the token from SharedPreferences
      final token = await SharedPreferencesUtils.retrieveToken();

      // Check if the token is not null before decoding
      if (token != null) {
        // Decode the token to extract user information
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        // Extract userId from the decoded token
        final String username = decodedToken['username'];
        // Fetch event information before sending the notification
        final eventInfoResponse = await http.get(
          Uri.parse("https://tabluprod.onrender.com/notifications/$eventId"),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (eventInfoResponse.statusCode == 200) {
          // Parse the response to extract event information
          final Map<String, dynamic> eventInfo =
              jsonDecode(eventInfoResponse.body);

          // Extract eventName and user from the event information
          final String eventName = eventInfo['eventName'];
          final String user = eventInfo['user'];

          // Compose the notification body
          final String notificationBody =
              'User $username has requested access to event $eventName';
          // Send the join notification
          final response = await http.post(
            Uri.parse("https://tabluprod.onrender.com/notifications"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'eventId': eventId,
              'userId': userId,
              'body': notificationBody,
              'receiver': user,
              'type': "confirmation"
            }),
          );

          if (response.statusCode == 201) {
            print('Notification sent successfully');
          } else {
            print('Failed to send notification: ${response.reasonPhrase}');
            throw Exception(
                'Failed to send notification: ${response.reasonPhrase}');
          }
        } else {
          print(
              'Failed to fetch event information: ${eventInfoResponse.reasonPhrase}');
          throw Exception(
              'Failed to fetch event information: ${eventInfoResponse.reasonPhrase}');
        }
      } else {
        print('Token is null. Unable to send notification.');
      }
    } catch (e) {
      print('Error sending notification: $e');
      throw Exception('Failed to send notification. Please try again.');
    }
  }

  static Future<void> sendNotificationScoresSubmitted(String eventId, String userId) async {
    try {
      // Make an HTTP POST request to send a notification without specifying the type
      final response = await http.post(
        Uri.parse('https://tabluprod.onrender.com/notifications'),
        body: {
          'eventId': eventId,
          'userId': userId,
          'type': "scoreSubmitted"
        },
      );

      print("Event IDs:" + eventId);

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }
}

class User {
  String username;

  User({
    required this.username,
  });
}

class JoinEvents extends StatefulWidget {
  final Event events;
  List<User> judges = [];

  JoinEvents({Key? key, required this.events}) : super(key: key);

  @override
  State<JoinEvents> createState() => _JoinEventsPageState();
}

class _JoinEventsPageState extends State<JoinEvents> {
  Future<void> fetchJudges() async {
    String eventId = widget.events.eventId;

    try {
      final response = await http.get(Uri.parse('/event-judges/$eventId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<User> judges = data
            .map((judgeData) => User(username: judgeData['username']))
            .toList();

        setState(() {
          widget.judges = judges;
        });
        print(widget.judges);

        // Display judges or perform any additional actions
      } else {
        throw Exception('Failed to load judges');
      }
    } catch (e) {
      print('Error fetching judges: $e');
    }
  }

  void requestJoinEvent(BuildContext context) async {
    String eventId = widget.events.eventId;
    try {
      await EventApi.requestJoinEvent(eventId);

      User user = getUser();

      setState(() {
        widget.judges.add(user);
      });

      // Fetch judges after successful join
      await fetchJudges();
      print(widget.judges);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully sent request for access'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ScoreCard(
      //       eventId: eventId,
      //       eventData: widget.events.toJson(),
      //       judges: widget.judges,
      //     ),
      //   ),
      // );
    } catch (e) {
      String error = e.toString().replaceAll('Exception:', '').trim();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  User getUser() {
    return User(username: 'User');
  }

  Future<void> confirmToJoinEvent(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Event Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you really want to join this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                requestJoinEvent(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Event Fetched',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(widget.events.eventName),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event ID: ${widget.events.eventId}'),
                    Text('Category: ${widget.events.eventCategory}'),
                    Text('Venue: ${widget.events.eventVenue}'),
                    Text('Organizer: ${widget.events.eventOrganizer}'),
                    Text('Date: ${widget.events.eventDate}'),
                    Text('Time: ${widget.events.eventTime}'),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              confirmToJoinEvent(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Join Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
