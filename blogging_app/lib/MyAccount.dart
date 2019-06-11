import 'package:flutter/material.dart';

class MyAccount extends StatefulWidget {
  final String name, email, userID;
  MyAccount(this.name, this.email, this.userID);
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("My Account"));
  }
}
