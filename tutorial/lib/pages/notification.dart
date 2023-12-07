import 'package:flutter/material.dart';

class Notif extends StatefulWidget {
  const Notif({Key? key});

  @override
  State<Notif> createState() => _NotifState();
}

class _NotifState extends State<Notif> {
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
      body: listView(),
    );
  }

  Widget listView() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return listViewItem(index);
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color: Colors.grey.shade400,
        );
      },
      itemCount: 15,
    );
  }

  Widget listViewItem(int index) {
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
                  message(index),
                  timeAndDate(index),
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

  Widget message(int index) {
    double textSize = 14;
    return Container(
      child: Text(
        'Message: Message Description',
        style: TextStyle(
          color: Colors.black,
          fontSize: textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget timeAndDate(int index) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '06-11-2023',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          Text(
            '6:14 am',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
