import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial/pages/login.dart';

class Forgotpass extends StatefulWidget {
   
  @override
  State<Forgotpass> createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {
  TextEditingController resetPassword = TextEditingController();

   Future<void> sendVerificationCode(String email) async {
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8080/send-verification-code'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerification(resetToken: response.body),
          ),
        );
      } else {
        print('Failed to send verification code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending verification code: $e');
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
        title: const Text('Forgot Password', style: TextStyle(
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
                    child: Center(child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text('Mail Address Here', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 5, 70, 20),
                  ),),
                )),
                    
                  ),
                  
                ),
                const Text(
                      'Enter your email and we will send you a \n a verification code',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10,),
                
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
                    onPressed: () async{
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
                    child: const Text(
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

  EmailVerification({required this.resetToken});
  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  List<TextEditingController> verificationCodeControllers = List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
        title: const Text('Email Verfication', style: TextStyle(
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
              const Text('Get Your Code',
              style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 5, 70, 20),
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
                        // Move to the next box when a digit is entered
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
    String enteredCode = verificationCodeControllers.map((controller) => controller.text).join();
    print('Entered verification code: $enteredCode');
    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  ResetPass(resetToken: widget.resetToken,),
                        ),
                      );
  },
  style: ElevatedButton.styleFrom(
    primary: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: const Text('Verify and Proceed', style: TextStyle(
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

   ResetPass({Key? key, required this.resetToken}) : super(key: key);


  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Color passwordBorderColor = Colors.grey.withOpacity(0.5);

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
      print('Password reset successful. New Password: $newPassword');
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