import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './generalUtility.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  VerifyEmail({this.email});
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    super.initState();
    sendVerificationEmail();
  }

  void sendVerificationEmail() {
    print(widget.email);
    http.post("$baseURL/sendVerificationEmail",
        body: {"email": widget.email}).then((res) {
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(res.body),
      ));
    });
  }

  TextEditingController _otpController = new TextEditingController(text: "");
  GlobalKey<ScaffoldState> key = new GlobalKey();
  GlobalKey<FormState> _formKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Your Email"),
      ),
      body: Center(
        child: ListView(shrinkWrap: true, children: <Widget>[
          Center(
            key: key,
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Please Enter OTP that is sent to your email: " +
                              widget.email,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.keyboard),
                            labelText: "OTP",
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (otp) {
                            if (otp.length != 6) {
                              return 'otp length should be exactly of size 6';
                            }
                          },
                        ),
                        InkWell(
                          customBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onTap: sendVerificationEmail,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "resend otp",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          color: Colors.blue,
                          elevation: 10,
                          highlightElevation: 20,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 75),
                          onPressed: verify,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text("Verify",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              )),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ]),
      ),
    );
  }

  void verify() {
    Scaffold.of(key.currentContext).showSnackBar(SnackBar(
      content: Text("Verifying"),
    ));
    String otp = _otpController.text;
    if (_formKey.currentState.validate()) {
      http.post("$baseURL/verify", body: {
        "email": widget.email,
        "code": otp,
      }).then((res) {
        Map<String, dynamic> json = jsonDecode(res.body);

        Scaffold.of(key.currentContext).hideCurrentSnackBar();
        Scaffold.of(key.currentContext).showSnackBar(SnackBar(
          content: Text(json['message']),
        ));
        if (json['isVerified']) {
          print("verified");
          verifyInDataBase();
        }
      });
    }
  }

  void verifyInDataBase() async {
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
    int result = await db.update("user", {"isVerified": "YES"},
        where: "email=?", whereArgs: [widget.email]);
    print(result);
    if (result == 1) {
      Navigator.pop(key.currentContext, true);
    }
  }
}
