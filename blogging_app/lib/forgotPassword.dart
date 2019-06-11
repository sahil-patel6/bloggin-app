import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './generalUtility.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email;
  TextEditingController _emailController = new TextEditingController(text: "");
  TextEditingController _otpController = new TextEditingController(text: "");
  TextEditingController _passwordController =
      new TextEditingController(text: "");
  bool showEmailInput;
  @override
  void initState() {
    super.initState();
    showEmailInput = true;
  }

  GlobalKey<ScaffoldState> key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Center(
        key: key,
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: showEmailInput
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Enter your email that is registered with us :",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.keyboard),
                          labelText: "Email",
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        onPressed: sendOTP,
                        child: Text("send otp"),
                      )
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Enter your otp here that is sent to ${_emailController.text} :",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.keyboard),
                          labelText: "OTP",
                        ),
                        maxLength: 6,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.keyboard),
                          labelText: "New Password",
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            onTap: sendEmail,
                            child: Text(
                              "re-send otp",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                        onPressed: changePassword,
                        child: Text("Change Password"),
                      )
                    ],
                  ),
          ),
        ]),
      ),
    );
  }

  void changePassword() {
    if (_otpController.text.length < 6 || _passwordController.text.length < 6) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Length of both fields should be more than 6 characters"),
        backgroundColor: Colors.red,
      ));
      return;
    } else {
      http.post("$baseURL/forgotPassword", body: {
        "email": _emailController.text,
        "otp": _otpController.text,
        "newPassword": _passwordController.text
      }).then((res) {
        Scaffold.of(key.currentContext).showSnackBar(SnackBar(
          content: Text(res.body),
        ));
      });
    }
  }

  void sendOTP() {
    var email = _emailController.text;
    if (email.isEmpty ||
        !email.contains(new RegExp(
            r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$'))) {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Please Enter a valid email address"),
        backgroundColor: Colors.red,
      ));
      return;
    } else {
      setState(() {
        email = _emailController.text;
        showEmailInput = false;
      });
      sendEmail();
    }
  }

  void sendEmail() {
    http.post("$baseURL/sendVerificationEmail",
        body: {"email": _emailController.text}).then((res) {
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text(res.body),
      ));
    });
  }
}
