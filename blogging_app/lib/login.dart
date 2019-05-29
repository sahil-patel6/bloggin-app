import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypt/crypt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String baseURL = "http://192.168.1.100:3000/api";

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _passwordController =
      new TextEditingController(text: "");
  GlobalKey<ScaffoldState> key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(175 / 2),
                  child: Icon(
                    Icons.account_circle,
                    size: 175,
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
                  child: Text("Login"),
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
    String email = _emailController.text;
    String password = _passwordController.text;
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
        content: Text("Loggin in!!!"),
        duration: Duration(
          minutes: 1,
        )));
    // String fileExtension = profilePic.path.split(".").last;
    // print(fileExtension);
    var encryptedPassword =
        Crypt.sha256(_passwordController.text + "@1234!").toString();
    http.post("$baseURL/login", body: {
      "email": _emailController.text,
      "password": encryptedPassword,
    }).then((res) {
      Map<String, dynamic> json = jsonDecode(res.body);
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(json['message']),
      ));
      if (json['userID'] != null) {
        print(json['userID']);
        addUserToDatabase(json['userID'], json['name']);
      }
    }).catchError((err) {
      print(err);
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("An error occured, please try again later"),
      ));
    });
  }

  void addUserToDatabase(String userID, String name) async {
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
    int result = await db.insert("user",
        {'userID': userID, 'name': name, 'email': _emailController.text},
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(result);
  }
}
