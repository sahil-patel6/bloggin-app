import 'package:flutter/material.dart';

class Downloads extends StatefulWidget {
  final String name, email, userID;
  Downloads(this.name, this.email, this.userID);
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Your Downloads"));
  }
}
