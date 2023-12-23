import 'package:flutter/material.dart';

class Refresher extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const Refresher({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  _RefresherState createState() => _RefresherState();
}

class _RefresherState extends State<Refresher> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}
