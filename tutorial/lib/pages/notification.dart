import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'package:tutorial/pages/dashboard.dart';
import 'package:tutorial/refresher.dart';
import 'package:tutorial/utility/sharedPref.dart';



class Notif extends StatefulWidget {
  final String? userId;

  const Notif({Key? key, required this.userId}) : super(key: key);


  @override
  State<Notif> createState() => _NotifState();
}

class _NotifState extends State<Notif> {
  late Future<List<dynamic>> notifications;
  bool notificationSent = false;



  @override
  void initState() {
    super.initState();
    // Fetch notifications when the widget is initialized
    notifications = fetchNotifications(widget.userId);

      socket.on('newNotification', (data) {
        print('Notification received');
        refreshNotifications();
      });

      socket.onDisconnect((_) {
        print('Socket disconnected');
      });
      socket.onError((error) {
        print('Socket error: $error');
      });

  }
  void dispose() {
    // Clean up resources here
    super.dispose();
  }


  Future<List<dynamic>> fetchNotifications(String? userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.101.6:8080/get-notifications/$userId'),
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> notifications = json.decode(response.body);

      // Sort the notifications based on the 'date' field
      notifications.sort((a, b) {
        DateTime dateTimeA = DateTime.parse(a['date']);
        DateTime dateTimeB = DateTime.parse(b['date']);
        return dateTimeB
            .compareTo(dateTimeA); // Descending order, modify if needed
      });
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }


  Future<void> refreshNotifications() async {
    try {
      final List<dynamic>? fetchedNotifications = await notifications;

      if (!mounted) {
        // If the widget is disposed, return without updating state
        return;
      }

      setState(() {
        notifications = fetchNotifications(widget.userId);
      });

      if (fetchedNotifications != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int notificationCount = fetchedNotifications.length;
        // Update the notification count in SharedPreferences
        prefs.setInt('notificationCount', notificationCount);
      }
    } catch (error) {
      print('Error refreshing notifications: $error');
    }
  }


  Future<void> updateJudgeConfirmationStatus(
      String userId, String eventId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.101.6:8080/update-confirmation'),
        body: {
          'userId': userId,
          'eventId': eventId,
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

  Future<void> rejectJudgeRequest(String userId, String eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.101.6:8080/reject-request/$userId/$eventId'),
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
        Uri.parse('http://192.168.101.6:8080/delete-notification/$userId'),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<dynamic> notificationList = await notifications;
        int notificationCount = notificationList.length - 1;
        // Update the notification count in SharedPreferences
        prefs.setInt('notificationCount', notificationCount);

        print('Notification deleted successfully');
      } else {
        print('Failed to delete notification');
      }
    } catch (error) {
      print('Error deleting notification: $error');
    }
  }


  Future<void> sendNotificationWithoutType(String receiverId, String? username,
      String status, String eventId) async {
    try {
      notificationSent = true;
      print("Event ID:" + eventId);
      // Make an HTTP POST request to send a notification without specifying the type
      final response = await http.post(
        Uri.parse('http://192.168.101.6:8080/notifications'),
        body: {
          'eventId': eventId,
          'userId': widget.userId,
          'receiver': receiverId,
          'body': '${username} has ${status} your request',
        },
      );

      print("Event IDs:" + eventId);

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        notificationSent = false;
        print('Failed to send notification');
      }
    } catch (error) {
      notificationSent = false;
      print('Error sending notification: $error');
    }
  }

  Future<String?> getUsernameById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.101.6:8080/get-username/$userId'),
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
    final eventId = notification['eventId'];
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
                updateJudgeConfirmationStatus(userId, eventId);
                await deleteNotification(userId);
                await refreshNotifications();
                // Get the receiver ID from the current notification
                final receiverId = notification['userId'];

                if (!notificationSent) {
                  await sendNotificationWithoutType(
                      receiverId, username, "accepted", eventId);
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () async {
                // Handle reject logic here
                rejectJudgeRequest(userId, eventId);
                await deleteNotification(userId);
                await refreshNotifications();
                final receiverId = notification['userId'];
                await sendNotificationWithoutType(
                    receiverId, username, "rejected", eventId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
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
      body: Refresher(
        onRefresh: refreshNotifications,
        child: FutureBuilder<List<dynamic>>(
          future: notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    // You can create a separate widget for the shimmer item
                  },
                  itemCount: 10, // You can adjust the number of shimmer items
                ),
              );
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
                        rejectJudgeRequest(userId, snapshot.data![index]['eventId']);
                      }
                      await deleteNotification(snapshot.data![index]['userId']);
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
    return FutureBuilder<String?>(
      future: getUsernameById(notification['userId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return ShimmerNotificationItem();
        } else if (snapshot.hasError) {
          // Handle error state
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final String? username = snapshot.data;
          final DateTime date = DateTime.parse(notification['date']);
          // final String formattedDate = '${date.day}-${date.month}-${date.year}';
          final String userId = notification['userId'];
          final String notificationType = notification['type'];
          String body;
          if (notification['body'] is Map<String, dynamic>) {
            final Map<String, dynamic> bodyData = notification['body'];
            final String rating = bodyData['rating'];
            final String feedback = bodyData['feedback'];
            final String eventName = bodyData['eventName'];

            body = "$username rate the $eventName $rating\nFeedback: $feedback";
          } else {
            body = notification['body'];
          }
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
                          timeAndDate(date),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // If the data is null, you can decide how to handle it (e.g., show a placeholder)
          return Container(); // Return an empty container or any placeholder widget
        }
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
        '$body',
        style: TextStyle(
          color: Colors.black,
          fontSize: textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget timeAndDate(DateTime formattedDate) {
    final DateTime notificationDate = formattedDate;
    final DateTime currentDate = DateTime.now();

    final Duration difference = currentDate.difference(notificationDate);

    String timeDifference = '';

    if (difference.inDays > 0) {
      timeDifference = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeDifference = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeDifference = '${difference.inMinutes}m ago';
    } else if (difference.inSeconds > 0) {
      timeDifference = '${difference.inSeconds}s ago';
    } else {
      timeDifference = 'Just now';
    }
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeDifference,
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

class ShimmerNotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: 100,
                height: 30, // Adjust the height as needed
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
