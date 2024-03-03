
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/authstate.dart';
import 'package:tutorial/message.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutorial/pages/notification.dart';
import 'package:tutorial/pushnotifications.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received");
  }
}

class TokenProvider extends ChangeNotifier {
  String _token;

  TokenProvider(this._token);

  String get token => _token;

  setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }
}

class User {
  final String userId;
  final String username;
  final String email;

  User({
    required this.userId,
    required this.username,
    required this.email,
  });
}

/*class UserProvider with ChangeNotifier {
  User _user;

  UserProvider(this._user);

  User get user => _user;

  // Add a method to update the user
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }
}*/

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Retrieve the token
  String token = prefs.getString('token') ?? '';

  // Set up Firebase messaging
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      _handleBackgroundMessage(message, token);
    }
  });

  PushNotifications.init();
  PushNotifications.localNotiInit();
  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.notification != null) {
      print("Received Notification");
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }else{
      print("Notification is empty");
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => TokenProvider(token)),
      ],
      child: MyApp(),
    ),
  );
}

void _handleBackgroundMessage(RemoteMessage message, String token) {
  if (message.notification != null) {
    print("Background Notification Tapped");

    // Check if user is authenticated here
    if (token.isEmpty) {
      print("User not authenticated. Returning without navigation.");
      return;
    }

    // If user is authenticated, navigate to the "/message" screen
    navigatorKey.currentState!.pushNamed("/message", arguments: message);
  }
}

class MyApp extends StatelessWidget {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the token from TokenProvider
    String? token;
    String? userId;

    _getToken().then((value) {
      token = value;

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        userId = decodedToken['userId'];
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(fontFamily: 'Poppins'),
      // Check if the user is authenticated
      home: userId != null? SearchEvents(token: token) : Login(),
      routes: {
        '/message': (context) => Notif(userId: userId), // Assuming userId can still be null here
      },
    );
  }
}

