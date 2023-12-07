import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorial/pages/editprofile.dart';
import 'package:tutorial/pages/getstarted.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 5, 70, 20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ),
              );
            },
            icon: const Icon(
              Icons.person, // Replace with your desired icon
              color: Color.fromARGB(255, 5, 70, 20),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, top: 25, right: 16),
        child: ListView(
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Color.fromARGB(255, 5, 70, 20),
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Account',
                  style: TextStyle(
                      color: Color.fromARGB(255, 5, 70, 20),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Forgot Password'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Option 1'),
                          Text('Option 2'),
                          Text('Option 3'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Change Password'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Option 1'),
                          Text('Option 2'),
                          Text('Option 3'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Language'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Option 1'),
                          Text('Option 2'),
                          Text('Option 3'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy and Security',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Notification',
                  style: TextStyle(
                      color: Color.fromARGB(255, 5, 70, 20),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            const SizedBox(
              height: 10,
            ),
            buildNotifOpt('New for you', true),
            buildNotifOpt('Account activity', true),
            buildNotifOpt('Opportunity', false),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const getStarted(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    letterSpacing: 2.2,
                  ),
                ),
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    color: Color.fromARGB(255, 5, 70, 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row buildNotifOpt(String title, bool isActivate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: isActivate,
            onChanged: (bool val) {
              // Handle the switch value change here
            },
          ),
        ),
      ],
    );
  }
}
