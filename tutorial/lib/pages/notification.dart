import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/utility/sharedPref.dart';

class Notif extends StatefulWidget {
  final String userId;

  const Notif({Key? key, required this.userId}) : super(key: key);

  @override
  State<Notif> createState() => _NotifState();
}

Future<List<dynamic>> fetchNotifications(String userId) async {
  final response = await http.get(
    Uri.parse('https://tab-lu.vercel.app/get-notifications/$userId'),
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
          onPressed: () async {
            String? token = await SharedPreferencesUtils.retrieveToken();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => SearchEvents(token: token)),
            );
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
            // Display notifications with swipe-to-delete functionality
            return ListView.separated(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(index.toString()),
                  onDismissed: (direction) async {
                    // Handle delete logic here

                    final String notificationType =
                        snapshot.data![index]['type'];
                    final String userId = snapshot.data![index]['userId'];
                    if (notificationType == "confirmation") {
                      rejectJudgeRequest(userId);
                    }
                    await deleteNotification(snapshot.data![index]['userId']);
                    await refreshNotifications();
                  },
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  child: listViewItem(context, snapshot.data![index]),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0,
                  color: Colors.grey.shade400,
                );
              },
              itemCount: snapshot.data!.length,
            );
          }
        },
      ),
    );
  }

  Widget listView(List<dynamic> notifications) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return listViewItem(context, notifications[index]);
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

  Widget listViewItem(BuildContext context, dynamic notification) {
    final DateTime date = DateTime.parse(notification['date']);
    final String formattedDate = '${date.day}-${date.month}-${date.year}';
    final String body = notification['body'];
    final String notificationType = notification['type'];
    final String userId = notification['userId'];

    return GestureDetector(
      onTap: () {
        if (notificationType == 'confirmation') {
          // Show accept and reject dialogue for confirmation type
          showConfirmationDialog(context, body, userId, notification);
        }
      },
      child: Container(
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
                    // Text(userId),
                    message(body),
                    timeAndDate(formattedDate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshNotifications() async {
    try {
      setState(() {
        notifications = fetchNotifications(widget.userId);
      });
    } catch (error) {
      print('Error refreshing notifications: $error');
    }
  }

  Future<void> updateJudgeConfirmationStatus(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://tab-lu.vercel.app/update-confirmation'),
        body: {
          'userId': userId,
          'isConfirm': true.toString(),
        },
      );

      if (response.statusCode == 200) {
        print('Judge confirmation status updated successfully');
      } else {
        print('Failed to update judge confirmation status');
      }
    } catch (error) {
      print('Error updating judge confirmation status: $error');
    }
  }

  Future<void> rejectJudgeRequest(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://tab-lu.vercel.app/reject-request/$userId'),
      );

      if (response.statusCode == 200) {
        print('Judge request rejected successfully');
      } else {
        print('Failed to reject judge request');
      }
    } catch (error) {
      print('Error rejecting judge request: $error');
    }
  }

  Future<void> deleteNotification(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://tab-lu.vercel.app/delete-notification/$userId'),
      );

      if (response.statusCode == 200) {
        print('Notification deleted successfully');
      } else {
        print('Failed to delete notification');
      }
    } catch (error) {
      print('Error deleting notification: $error');
    }
  }

  Future<void> sendNotificationWithoutType(
      String receiverId, String? username, String status) async {
    try {
      // Make an HTTP POST request to send a notification without specifying the type
      final response = await http.post(
        Uri.parse('https://tab-lu.vercel.app/notifications'),
        body: {
          'userId': widget.userId,
          'receiver': receiverId,
          'body': '${username} has ${status} your request',
        },
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  Future<String?> getUsernameById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://tab-lu.vercel.app/get-username/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return userData['username'];
      } else {
        print('Failed to get username');
        return null;
      }
    } catch (error) {
      print('Error getting username: $error');
      return null;
    }
  }

  void showConfirmationDialog(BuildContext context, String notificationBody,
      String userId, dynamic notification) async {
    final receiverId = notification['receiver'];
    final username = await getUsernameById(receiverId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation Notification'),
          content: Text('Do you want to accept or reject this notification?\n'),
          actions: [
            TextButton(
              onPressed: () async {
                // Handle accept logic here
                updateJudgeConfirmationStatus(userId);
                await deleteNotification(userId);
                await refreshNotifications();
                // Get the receiver ID from the current notification
                final receiverId = notification['userId'];

                await sendNotificationWithoutType(
                    receiverId, username, "accepted");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () async {
                // Handle reject logic here
                rejectJudgeRequest(userId);
                await deleteNotification(userId);
                await refreshNotifications();
                final receiverId = notification['userId'];
                await sendNotificationWithoutType(
                    receiverId, username, "rejected");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
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
        'Message\n$body',
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
