import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tutorial/pages/searchevents.dart';
import 'package:tutorial/pages/editprofile.dart';
import 'package:tutorial/pages/forgotpassword.dart';
import 'package:tutorial/pages/settings.dart';

class HelpandFaq extends StatefulWidget {
  const HelpandFaq({super.key});

  @override
  State<HelpandFaq> createState() => _HelpandFaqState();
}

class _HelpandFaqState extends State<HelpandFaq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/competition-contest-cyber-svgrepo-com.svg',
              width: 50,
              height: 50,
              color: const Color.fromARGB(255, 5, 78, 7),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(),
          leading: IconButton(
  icon: const Icon(
    Icons.arrow_back,
    color: Color.fromARGB(255, 5, 78, 7),
  ),
  onPressed: () {
    Navigator.pop(context); // Use pop to navigate back
  },
),

        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'WELCOME TO TABLU APP SUPPORT',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 5, 78, 7),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 5, 78, 7),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(),
                          ),
                        );
                      },
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 5, 78, 7),
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 5, 78, 7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Forgotpass(),
                          ),
                        );
                      },
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                color: Color.fromARGB(255, 5, 78, 7),
                                size: 35,
                              ),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 5, 78, 7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                color: Color.fromARGB(255, 5, 78, 7),
                                size: 35,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 5, 78, 7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 5, 78, 7),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('What is an Event Tabulation App?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('An Event Tabulation App is a software application designed to streamline and automate the process of tabulating scores, results, and data related to events, competitions, or contests.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),
                    const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('How does the Event Tabulation App work?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('The app typically allows organizers to input and manage event data, judges to enter scores, and participants to view real-time results. It automates calculations, reduces manual errors, and provides a centralized platform for all stakeholders.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),
                    const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('What features does the Event Tabulation App offer?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Features may include user authentication, result entry, real-time score updates, participant information management, customizable scoring criteria, and data export options.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),
                    const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Is the app customizable for different types of events?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Yes, a good Event Tabulation App should be customizable to accommodate various types of events, scoring systems, and criteria. Organizers can often tailor the app to suit the specific needs of their event.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),
                    const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Can judges access the app remotely?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Depending on the app, judges may have the option to access and submit scores remotely, enhancing flexibility and convenience, especially for events with multiple judging locations.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Can the app be used for both small and large-scale events?', 
                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 5, 78, 7), 
                    fontWeight: FontWeight.w500
                    ),
                    ),
                  ),
        
                ),
                 const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16, right: 8.0, bottom: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Ideally, the app should be scalable, catering to the needs of both small local events and large-scale competitions with multiple categories and participants.', textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 11, color: Colors.black, 
                    ),
                    ),
                  ),
                  
                ),
              ],
            ),
          ),
        ));
  }
}
