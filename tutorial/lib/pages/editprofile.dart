import 'package:flutter/material.dart';

import 'package:tutorial/pages/settings.dart';

class EditProfile extends StatelessWidget {
   EditProfile({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Settings UI',
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
   EditProfilePage({Key? key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  elevation: 0,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back,
      color: Color.fromARGB(255, 5, 70, 20),
    ),
   onPressed: () {
     
       Navigator.pop(context);
   },
  ),
  actions: [
    IconButton(
      icon: Icon(
        Icons.settings,
        color: Color.fromARGB(255, 5, 70, 20),
      ),
      onPressed: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SettingsPage(),
          ),
        );
      },
    )
  ],
),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          padding: const EdgeInsets.only(left: 16, top: 5, right: 16),
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Color.fromARGB(255, 5, 78, 7),
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15), // Added spacing between text and image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(
                            0,
                            10,
                          ),
                        )
                      ],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/icons/408-4087421_person-svg-circle-icon-picture-charing-cross-tube.png',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          )),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 35),
            buildTextField("Full Name", "Juan Dela Cruz", false),
            buildTextField("Email", "example@example.com", false),
            buildTextField("Password", "**********", true),
            buildTextField("Address", "Calauan, Laguna", false),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Add your cancel button action here
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: Colors.black,
                    ),
                  ),
                  child: const Text('CANCEL',
                      style: TextStyle(color: Colors.green)),
                ),
                const SizedBox(width: 10), // Added spacing between buttons
                ElevatedButton(
                  // Use ElevatedButton instead of RaisedButton
                  onPressed: () {
                    // Add your save button action here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: isPasswordTextField
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: const Icon(Icons.remove_red_eye),
                  color: Colors.green,
                )
              : null,
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
