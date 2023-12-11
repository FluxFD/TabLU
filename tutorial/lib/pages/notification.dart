import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Notif extends StatefulWidget {
  final String userId;

  const Notif({Key? key, required this.userId}) : super(key: key);

  @override
  State<Notif> createState() => _NotifState();
}

Future<List<dynamic>> fetchNotifications(String userId) async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/get-notifications/$userId'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load notifications');
  }
}

class _NotifState extends State<Notif> {
  late Future<List<dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the widget is initialized
    notifications = fetchNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFF054E07),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Display notifications
            return listView(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget listView(List<dynamic> notifications) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return listViewItem(notifications[index]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color: Colors.grey.shade400,
        );
      },
      itemCount: notifications.length,
    );
  }

  Widget listViewItem(dynamic notification) {
    // Extract data from the notification and display accordingly
    // Modify as per your notification data structure

    final DateTime date = DateTime.parse(notification['date']);
    final String formattedDate = '${date.day}-${date.month}-${date.year}';

    final String body = notification['body'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prefixIcon(),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message(body),
                  timeAndDate(formattedDate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget prefixIcon() {
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(
        Icons.notifications,
        size: 20,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget message(String body) {
    double textSize = 14;
    return Container(
      child: Text(
        'Message: $body',
        style: TextStyle(
          color: Colors.black,
          fontSize: textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget timeAndDate(String formattedDate) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          // Include logic to format the time from the server response
          // For example: Text(formatTime(notification['date']), style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
