import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/main.dart';

class AuthState extends ChangeNotifier {
  bool isLoggedIn = false;

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout(BuildContext context) async {
    // Clear provider states
    Provider.of<TokenProvider>(context, listen: false).setToken('');
    // You can clear other provider states similarly if needed

    // Clear shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    isLoggedIn= false;
    // Navigate back to login screen
  }
}
