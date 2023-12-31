import 'package:flutter/material.dart';
import 'package:tutorial/constant.dart';
import 'package:tutorial/pages/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/utility/sharedPref.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Signin> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool showPassword = false;
  bool isSelected = true;
  bool isPasswordTextField = true;
  Color usernameBorderColor = Colors.grey.withOpacity(0.5);
  Color passwordBorderColor = Colors.grey.withOpacity(0.5);
  Color emailBorderColor = Colors.grey.withOpacity(0.5);

  bool isEmailValid(String email) {
    return email.contains('@');
  }

  Future<void> signIn() async {
    final Uri url = Uri.parse("https://tab-lu.vercel.app/signin");

    if (username.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      // Handle empty fields
      // Set border colors to indicate the error
      if (username.text.isEmpty) {
        setState(() {
          usernameBorderColor = Colors.red;
        });
      }
      if (email.text.isEmpty) {
        setState(() {
          emailBorderColor = Colors.red;
        });
      }
      if (password.text.isEmpty) {
        setState(() {
          passwordBorderColor = Colors.red;
        });
      }
      showLoginErrorToast('Please fill in all fields');
      return;
    }

    if (!isEmailValid(email.text)) {
      // Handle invalid email
      setState(() {
        emailBorderColor = Colors.red;
      });
      showLoginErrorToast('Please enter a valid email address');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email.text,
          'password': password.text,
          'username': username.text
        }),
      );

      if (response.statusCode == 201) {
        print('Sign-up successful');
        var jsonResponse = json.decode(response.body);
        var myToken = jsonResponse['token'];
        print(jsonResponse);
        await SharedPreferencesUtils.saveToken(myToken);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchEvents(token: "myToken")),
        );
      } else if (response.statusCode == 400) {
        print('Username or Email already exists');
        showLoginErrorToast('User or Email already exists');
        setState(() {
          usernameBorderColor = Colors.red;
          passwordBorderColor = Colors.red;
        });
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showLoginErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'assets/icons/pxfuel (1).jpg',
            width: x,
            height: y,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: x,
                  height: y * 0.100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    child: const Stack(
                      children: [
                        Positioned(
                          top: 30,
                          left: 10,
                          child: Icon(
                            Icons.arrow_back,
                            color: Color.fromARGB(255, 5, 78, 7),
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  width: x,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Color.fromARGB(255, 5, 70, 20),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Create a new account',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: const Offset(1, 1),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: username,
                          decoration: InputDecoration(
                            hintText: 'Username',
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
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: usernameBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: const Offset(1, 1),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: email,
                          decoration: InputDecoration(
                            hintText: 'Email',
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
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: emailBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: const Offset(1, 1),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: password,
                          obscureText:
                              isPasswordTextField ? !showPassword : false,
                          decoration: InputDecoration(
                            suffixIcon: isPasswordTextField
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                      icon: Icon(
                                        showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.green,
                                      ),
                                    ))
                                : null,
                            hintText: 'Password',
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
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: passwordBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: y * 0.05,
                    width: x * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: isSelected ? Colors.green : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 300,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.green,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        child: const Text(
                          ' Log in',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
