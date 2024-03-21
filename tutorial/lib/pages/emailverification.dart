import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/pages/login.dart';

class VerifyAccount extends StatefulWidget {
  final TextEditingController emailController;

  const VerifyAccount({
    Key? key,
    required this.emailController,
  }) : super(key: key);

  @override
  _VerifyAccountState createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  List<TextEditingController> verificationCodeControllers =
  List.generate(4, (index) => TextEditingController());

  bool isVerificationCodeFilled() {
    // Check if all slots are filled
    return verificationCodeControllers
        .every((controller) => controller.text.isNotEmpty);
  }

  Future<void> verifyEmail() async {
    try {
      String enteredCode = verificationCodeControllers
          .map((controller) => controller.text)
          .join();

      final response = await http.post(
        Uri.parse("https://tab-lu.onrender.com/verify-email"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': widget.emailController.text,
          'verificationCode': enteredCode,
        }),
      );

      if (response.statusCode == 200) {
        print('Email verification successful');
        Navigator.pop(context); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verification successful'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid verification code'),
            duration: Duration(seconds: 3),
          ),
        );
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Email Verification',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
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
                          borderSide: BorderSide(
                            color: verificationCodeControllers[index].text.isEmpty
                                ? Colors.red // Border color when empty
                                : Colors.grey, // Border color when not empty
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                        setState(() {}); // Update the state on each change
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isVerificationCodeFilled() ? verifyEmail : null,
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
