import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String name, email, userID;
  Home(this.name, this.email, this.userID);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home"));
  }
}
