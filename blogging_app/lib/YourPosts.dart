import 'package:flutter/material.dart';

class YourPosts extends StatefulWidget {
  final String name, email, userID;
  YourPosts(this.name, this.email, this.userID);
  @override
  _YourPostsState createState() => _YourPostsState();
}

class _YourPostsState extends State<YourPosts> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Your Posts"));
  }
}
