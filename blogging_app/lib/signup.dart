import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_modern/image_picker_modern.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String baseURL = "http://192.168.1.102:3000/api";

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _passwordController =
      new TextEditingController(text: "");
  TextEditingController _userNameController =
      new TextEditingController(text: "");
  File profilePic;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Center(
        key: key,
        child: ListView(shrinkWrap: true, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                    onTap: selectImage,
                    child: profilePic == null
                        ? Icon(Icons.add_a_photo, size: 175, color: Colors.grey)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(175 / 2),
                            child: Image.file(
                              profilePic,
                              width: 175,
                              height: 175,
                              fit: BoxFit.cover,
                            ),
                          )),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.account_circle),
                    hintText: "User Name",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    hintText: "Email",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.keyboard),
                    hintText: "Password",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  onPressed: signUp,
                  child: Text("Sign up"),
                ),
                SizedBox(
                  height: 60,
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  bool validate() {
    String name = _userNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    print(name.length);
    if (name.length <= 0) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Don't leave user name field blank"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (profilePic == null) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Please Select Your Profile Picture"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (email.isEmpty ||
        !email.contains(new RegExp(
            r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$'))) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Please Enter a valid email address"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (password.isEmpty || password.length < 8) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Password Length should be more then 8 characters"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    return true;
  }

  void signUp() {
    if (!validate()) return;
    Scaffold.of(key.currentContext).hideCurrentSnackBar();
    print(_emailController.text);
    print(_passwordController.text);
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Registering!!!"),
        duration: Duration(
          minutes: 1,
        )));
    String base64Image = base64Encode(profilePic.readAsBytesSync());
    http.post("$baseURL/signup", body: {
      "profilePic": base64Image,
      "userName": _userNameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
    }).then((res) {
      Map<String, dynamic> json = jsonDecode(res.body);
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(json['message']),
      ));
      if (json['userID'] != null) {
        print(json['userID']);
        addUserToDatabase(json['userID']);
      }
    }).catchError((err) {
      print(err);
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("An error occured, please try again later"),
      ));
    });
  }

  void addUserToDatabase(String userID) async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT,)",
        );
      },
      version: 1,
    );
    final Database db = await database;
    int changes = await db.delete("user");
    print(changes);
    int result = await db.insert(
        "user",
        {
          'userID': userID,
          'name': _userNameController.text,
          'email': _emailController.text
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(result);
  }

  void selectImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic = image;
    });
  }
}
