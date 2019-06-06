import 'package:flutter/material.dart';

class LikedPost extends StatefulWidget {
  final String name, email, userID;
  LikedPost(this.name, this.email, this.userID);
  @override
  _LikedPostState createState() => _LikedPostState();
}

class _LikedPostState extends State<LikedPost> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Liked Posts"));
  }
}
