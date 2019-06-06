import 'package:flutter/material.dart';

class BookMarkedPosts extends StatefulWidget {
  final String name, email, userID;
  BookMarkedPosts(
      this.name, this.email, this.userID);
  @override
  _BookMarkedPostsState createState() => _BookMarkedPostsState();
}

class _BookMarkedPostsState extends State<BookMarkedPosts> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("BookmarkedPosts"));
  }
}
