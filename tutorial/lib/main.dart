import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/pages/eventsmanagement.dart';
import 'package:tutorial/pages/finalscore.dart';
import 'package:tutorial/pages/login.dart';
import 'package:tutorial/pages/scorecard.dart';
import 'package:tutorial/pages/searchevents.dart';
import 'package:tutorial/pages/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:tutorial/pages/viewprofile.dart';

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
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => TokenProvider(prefs.getString('token') ?? '')),
     //   ChangeNotifierProvider(create: (context) => UserProvider(User(userId: '', username: '', email: ''))),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the token from TokenProvider
    String token = Provider.of<TokenProvider>(context).token;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
 //home: JwtDecoder.isExpired(token) == false ? SearchEvents(token: token) : SplashScreen(),
 home: EventsManagement()
  
    );
  }
}
