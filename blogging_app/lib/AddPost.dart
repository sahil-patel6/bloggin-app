import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  final String name, email, userID;
  AddPost(this.name, this.email, this.userID);
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Add Post"));
  }
}
