import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_modern/image_picker_modern.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './VerifyEmail.dart';
import './generalUtility.dart';

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
  final _formKey = GlobalKey<FormState>();
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      onTap: selectImage,
                      child: profilePic == null
                          ? Icon(Icons.add_a_photo,
                              size: 175, color: Colors.grey)
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
                    textCapitalization: TextCapitalization.words,
                    controller: _userNameController,
                    decoration: InputDecoration(
                  
                      icon: Icon(Icons.account_circle),
                      labelText: "User Name",
                    ),
                    validator: (name) {
                      if (name.isEmpty) {
                        return "please don't leave user name field blank";
                      }
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                    validator: (email) {
                      if (email.isEmpty ||
                          !email.contains(new RegExp(
                              r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$'))) {
                        return 'please enter valid email address';
                      }
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.keyboard),
                      labelText: "Password",
                    ),
                    validator: (password) {
                      if (password.length <= 6) {
                        return 'password length should be more than 6 characters';
                      }
                    },
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
          ),
        ]),
      ),
    );
  }

  bool validateIfProfilePicIsEmpty() {
    if (profilePic == null) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Please Select Your Profile Picture"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    return true;
  }

  void signUp() {
    if (!validateIfProfilePicIsEmpty() || !_formKey.currentState.validate()) return;
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
        print("Creating new table");
        return db.execute(
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT, isVerified TEXT)",
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
          'email': _emailController.text,
          'isVerified': "NO",
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(result);
    Navigator.push(
        key.currentContext,
        MaterialPageRoute(
            builder: (context) => VerifyEmail(
                  email: _emailController.text,
                )));
  }

  void selectImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic = image;
    });
  }
}
