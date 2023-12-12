import 'package:flutter/material.dart';

class NotificationModel with ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  void setNotificationCount(int newCount) {
    _notificationCount = newCount;
    notifyListeners();
  }
}
