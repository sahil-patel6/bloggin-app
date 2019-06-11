import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './generalUtility.dart';
import 'forgotPassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _passwordController =
      new TextEditingController(text: "");
  GlobalKey<ScaffoldState> key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
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
            child: Form(
              key: _formKey,
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
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.keyboard),
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ))
                    ],
                  ),
                  RaisedButton(
                    onPressed: login,
                    child: Text("Login"),
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

  void login() {
    if (!_formKey.currentState.validate()) return;
    Scaffold.of(key.currentContext).hideCurrentSnackBar();
    print(_emailController.text);
    print(_passwordController.text);
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Logging in!!!"),
        duration: Duration(
          minutes: 1,
        )));
    http.post("$baseURL/login", body: {
      "email": _emailController.text,
      "password": _passwordController.text,
    }).then((res) {
      Map<String, dynamic> json = jsonDecode(res.body);
      print(json);
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(json['message']),
      ));
      if (json['userID'] != null) {
        print(json['userID']);
        addUserToDatabase(json['userID'], json['name'], json['isVerified']);
      }
    }).catchError((err) {
      print(err);
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("An error occured, please try again later"),
      ));
    });
  }

  void addUserToDatabase(String userID, String name, String isVerified) async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT,isVerified TEXT)",
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
          'name': name,
          'email': _emailController.text,
          'isVerified': isVerified
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(result);
  }
}
