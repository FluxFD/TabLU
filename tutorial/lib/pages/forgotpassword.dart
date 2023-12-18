import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/pages/login.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Forgotpass extends StatefulWidget {
  @override
  State<Forgotpass> createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {
  TextEditingController resetPassword = TextEditingController();
  bool isLoading = false;

  Future<void> sendVerificationCode(String email) async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await http.post(
        Uri.parse('https://tab-lu.vercel.app/send-verification-code'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String resetToken = responseData['resetToken'];
        String accessCode = responseData['accessCode'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerification(
              resetToken: resetToken,
              accessCode: accessCode,
            ),
          ),
        );
      } else {
        print(
            'Failed to send verification code. Status code: ${response.statusCode}, ${response.body}');
        // Show a SnackBar or another UI element to inform the user about the error.
      }
    } catch (e) {
      print('Error sending verification code: $e');
      // Show a SnackBar or another UI element to inform the user about the error.
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF054E07),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Forgot Password',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF054E07),
            )),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: x,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                Container(
                  child: const Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, top: 180, bottom: 10.0, right: 16.0),
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        'Mail Address Here',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 5, 70, 20),
                        ),
                      ),
                    )),
                  ),
                ),
                const Text(
                  'Enter your email and we will send you a \n a verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: x * 0.9,
                  child: TextField(
                    controller: resetPassword,
                    decoration: InputDecoration(
                      hintText: 'example@gmail.com',
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
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            print('Sending verification code...');
                            await sendVerificationCode(resetPassword.text);
                            print('Verification code sent.');
                          },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator() // Show a loading indicator
                        : const Text(
                            'Recover Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmailVerification extends StatefulWidget {
  final String resetToken;
  final String accessCode;

  EmailVerification({required this.resetToken, required this.accessCode});
  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  List<TextEditingController> verificationCodeControllers =
      List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Email Verfication',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF054E07),
            )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Get Your Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 70, 20),
                ),
              ),
              const Text(
                'Enter the 4-digit verification code sent to your email',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: TextField(
                      controller: verificationCodeControllers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement code verification logic
                  // You can concatenate the entered digits and use the resulting code
                  // For simplicity, let's just print the entered code for now
                  String enteredCode = verificationCodeControllers
                      .map((controller) => controller.text)
                      .join();
                  if (enteredCode == widget.accessCode) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPass(
                          resetToken: widget.resetToken,
                          accessCode: widget.accessCode,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Invalid verification code. Please try again.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Verify and Proceed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPass extends StatefulWidget {
  final String resetToken;
  final String accessCode;

  ResetPass(
      {Key? key, required this.resetToken, required String this.accessCode})
      : super(key: key);

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Color passwordBorderColor = Colors.grey.withOpacity(0.5);

  Future<void> resetPassword(
      String resetToken, String newPassword, String accessCode) async {
    try {
      final Uri url = Uri.parse("https://tab-lu.vercel.app/reset-password");

      final Map<String, dynamic> requestBody = {
        'resetToken': resetToken,
        'newPassword': newPassword,
        'accessCode': accessCode,
      };

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse); // Handle the response as needed
      } else {
        print(
            'Failed to reset password. Status code: ${response.statusCode}, ${response.body}');
        // Handle the failure, show a SnackBar, or another UI element to inform the user about the error.
      }
    } catch (e) {
      print('Error resetting password: $e');
      // Handle the error, show a SnackBar, or another UI element to inform the user about the error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter New Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 5, 70, 20),
              ),
            ),
            const Text(
              'Enter the new password to recover your account',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
                  color: passwordBorderColor,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: newPasswordController,
                onChanged: (text) {
                  setState(() {
                    passwordBorderColor = Colors.grey.withOpacity(0.5);
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'New Password',
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
                  color: passwordBorderColor,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: confirmPasswordController,
                onChanged: (text) {
                  setState(() {
                    passwordBorderColor = Colors.grey.withOpacity(0.5);
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword == confirmPassword) {
                  // Perform the password reset
                  await resetPassword(
                      widget.resetToken, newPassword, widget.accessCode);
                  print(
                      'Password reset successful. New Password: $newPassword');
                  print('Sending resetToken: ${widget.resetToken}');
                  print('Sending newPassword: $newPassword');
                  // Show Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset successful'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // Navigate to the Login screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                } else {
                  print('Passwords do not match');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
