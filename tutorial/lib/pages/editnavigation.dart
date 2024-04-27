import 'package:flutter/material.dart';
import 'package:tutorial/pages/criteria.dart';
import 'package:tutorial/pages/eventinfo.dart';

import 'contestants.dart';

class EditNavigation extends StatelessWidget {
  final String eventId;
  final bool isEdit;

  EditNavigation({required this.eventId, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          centerTitle: true,
          title: const Text(
            'Edit event details',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 5, 78, 7),
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
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              buildButton("Event Info", Icons.info, EditEventScreen(eventId: eventId), context),
              SizedBox(height: 20),
              buildButton("Criteria", Icons.grid_on, Criterias(eventId: eventId, isEdit: isEdit), context),
              SizedBox(height: 20),
              buildButton("Contestant", Icons.people, Contestants(eventId: eventId, isEdit: isEdit,), context),
            ],
          ),
        ),
    );
  }

  Widget buildButton(String text, IconData icon, Widget page, context) {
    return Container(
      width: 300,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add your functionality here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 10), // Add space before icon
                Icon(
                  icon,
                  size: 36, // Adjust the size as needed
                  color: Color(0xFF054E07),
                ), // Icon
                SizedBox(width: 10), // Add space between icon and text
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 36), // Arrow pointing left
          ],
        ),
      ),
    );
  }
}
