import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool showPassword = false;
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
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
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
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.keyboard),
                      labelText: "Password",
                      suffixIcon: InkWell(
                          customBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(33)),
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          child: Icon(Icons.remove_red_eye)),
                    ),
                    obscureText: !showPassword,
                    validator: (pass) {
                      if (pass.length <= 6) {
                        return 'length should be more than 6 characters';
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                          customBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Forgot Password",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 15),
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    elevation: 10,
                    highlightElevation: 20,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 75),
                    onPressed: login,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text("Log In",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        )),
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
    if (_formKey.currentState.validate()) {
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
          addUserToDatabase(json['userID'], json['name'], json['isVerified'],
              json['profilePic']);
        }
      }).catchError((err) {
        print(err);
        Scaffold.of(key.currentContext).showSnackBar(SnackBar(
          content: Text("An error occured, please try again later"),
        ));
      });
    }
  }

  void addUserToDatabase(
      String userID, String name, String isVerified, String profilePic) async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          DbCommandToCreateUserTable,
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
          'isVerified': isVerified,
          'profilePic': profilePic,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(result);
  }
}
