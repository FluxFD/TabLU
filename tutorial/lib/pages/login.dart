import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial/pages/forgotpassword.dart';
import 'package:tutorial/pages/searchevents.dart';
import 'package:tutorial/pages/signin.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:provider/provider.dart';


class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }
}

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isSelected = true;
  bool showPassword = false;
  bool isPasswordTextField = true;
  Color usernameBorderColor = Colors.grey.withOpacity(0.5);
  Color passwordBorderColor = Colors.grey.withOpacity(0.5);
  late SharedPreferences prefs; 


@override
void initState(){
  super.initState();
  initSharedPref();
}
void initSharedPref() async{
  prefs = await SharedPreferences.getInstance();

}

/*Future<void> logIn() async {
  if (username.text.isEmpty || password.text.isEmpty) {
    // Handle empty fields and show an error message
    if (username.text.isEmpty) {
      setState(() {
        usernameBorderColor = Colors.red;
      });
    }
    if (password.text.isEmpty) {
      setState(() {
        passwordBorderColor = Colors.red;
      });
    }
    showLoginErrorToast('Please fill in all fields');
    return; // Exit the method if fields are empty
  }

  try {
    final Uri url = Uri.parse("http://10.0.2.2:8080/login");
    var res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username.text,
        'password': password.text,
      }),
    );

    if (res.statusCode == 200) {
      var jsonResponse = json.decode(res.body);
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
            // Successful response
            print(res.body);
            usernameBorderColor = Colors.grey.withOpacity(0.5);
            passwordBorderColor = Colors.grey.withOpacity(0.5);

            final Map<String, dynamic> response = json.decode(res.body);
            if (response.containsKey('message') && response['message'] == 'Successful login') {
                // Navigate to the SearchEvents screen upon successful sign-in
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchEvents(token: myToken),
                ));
            } else {
                showLoginErrorToast('Invalid username or password');
                setState(() {
                    usernameBorderColor = Colors.red;
                    passwordBorderColor = Colors.red;
                });
            }
        } else if (res.statusCode == 401) {
            // Handle cases where the login was not successful
            showLoginErrorToast('Invalid username or password');
            setState(() {
                usernameBorderColor = Colors.red;
                passwordBorderColor = Colors.red;
            });
        } else {
            print('HTTP Error: ${res.statusCode}');
            // Handle other non-200 status codes
            // You might want to display an error message or handle the error differently.
        }
  } catch (e) {
    // Handle any exceptions (e.g., network errors)
    print('Error: $e');
    // You might want to display a network error message to the user.
  }
}*/

void showLoginErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

   Future<void> logIn(BuildContext context, AuthProvider authProvider) async {
  if (username.text.isEmpty || password.text.isEmpty) {
    // Handle empty fields and show an error message
    if (username.text.isEmpty) {
      setState(() {
        usernameBorderColor = Colors.red;
      });
    }
    if (password.text.isEmpty) {
      setState(() {
        passwordBorderColor = Colors.red;
      });
    }
    showLoginErrorToast('Please fill in all fields');
    return; // Exit the method if fields are empty
  }

  try {
    final Uri url = Uri.parse("http://10.0.2.2:8080/login");
    var res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username.text,
        'password': password.text,
      }),
    );

    if (res.statusCode == 200) {
      var jsonResponse = json.decode(res.body);
      var myToken = jsonResponse['token'];
      prefs.setString('token', myToken);
       authProvider.setToken(myToken);


      // Set the token using the AuthProvider
      Provider.of<AuthProvider>(context, listen: false).setToken(myToken);

      // Successful response
      print(res.body);
      usernameBorderColor = Colors.grey.withOpacity(0.5);
      passwordBorderColor = Colors.grey.withOpacity(0.5);

      final Map<String, dynamic> response = json.decode(res.body);
      if (response.containsKey('message') && response['message'] == 'Successful login') {
        // Navigate to the SearchEvents screen upon successful sign-in
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchEvents(token: myToken)),
        );
      } else {
        showLoginErrorToast('Invalid username or password');
        setState(() {
          usernameBorderColor = Colors.red;
          passwordBorderColor = Colors.red;
        });
      }
    } else if (res.statusCode == 401) {
      // Handle cases where the login was not successful
      showLoginErrorToast('Invalid username or password');
      setState(() {
        usernameBorderColor = Colors.red;
        passwordBorderColor = Colors.red;
      });
    } else {
      print('HTTP Error: ${res.statusCode}');
      // Handle other non-200 status codes
      // You might want to display an error message or handle the error differently.
    }
  } catch (e) {
    // Handle any exceptions (e.g., network errors)
    print('Error: $e');
    // You might want to display a network error message to the user.
  }
}

// ===================================================================
  Future<String?> getToken() async {
    return prefs.getString('token');
  }
//==================================================================
  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
    
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/pxfuel (1).jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Consumer<AuthProvider>(
                 builder: (context, authProvider, child) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 100),
                    width: x,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          'Hello!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 5, 70, 20),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Log in to your account',
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
                            border: Border.all(
                              color:
                                  usernameBorderColor, // Change border color based on validation
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: username,
                            onChanged: (text) {
                              setState(() {
                                usernameBorderColor =
                                    Colors.grey.withOpacity(0.5);
                              });
                            },
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
                            border: Border.all(
                              color:
                                  passwordBorderColor, // Change border color based on validation
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: password,
                            onChanged: (text) {
                              setState(() {
                                passwordBorderColor =
                                    Colors.grey.withOpacity(0.5);
                              });
                            },
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
                                      ),
                                    )
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
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Forgotpass(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: y * 0.05,
                    width: x * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                     
                      logIn(context, authProvider);
                    
                      },
                      style: ElevatedButton.styleFrom(
                        primary: isSelected ? Colors.green : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                                fontWeight: FontWeight.bold),
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
                    height: 2,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Signin(),
                              ),
                            );
                          },
                          child: const Text(
                            ' Sign in',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }),
          ),
      )],
      ),
    ));
  }
}
