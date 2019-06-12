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

  bool showPassword = false;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  GlobalKey<FormState> _formkeyForChangePassword = new GlobalKey();
  GlobalKey<FormState> _formkeyForSendEmail = new GlobalKey();
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
              padding: const EdgeInsets.all(8.0),
              child: showEmailInput
                  ? Form(
                      key: _formkeyForSendEmail,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Enter your email that is registered with us :",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.keyboard),
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
                          SizedBox(
                            height: 40,
                          ),
                          RaisedButton(
                            color: Colors.blue,
                            elevation: 10,
                            highlightElevation: 20,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 75),
                            onPressed: sendOTP,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Text("Send OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      ))
                  : Form(
                      key: _formkeyForChangePassword,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Enter your otp here that is sent to ${_emailController.text} :",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.keyboard),
                              labelText: "OTP",
                            ),
                            maxLength: 6,
                            validator: (otp) {
                              if (otp.length != 6) {
                                return 'It should be exactly 6 characters';
                              }
                            },
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
                            validator: (password) {
                              if (password.length <= 6) {
                                return 'length should be of more than 6 characters';
                              }
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              InkWell(
                                customBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onTap: sendEmail,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "re-send otp",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 15),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                            color: Colors.blue,
                            elevation: 10,
                            highlightElevation: 20,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 75),
                            onPressed: changePassword,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Text("Change Password",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      ),
                    )),
        ]),
      ),
    );
  }

  void changePassword() {
    if (_formkeyForChangePassword.currentState.validate()) {
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
    if (_formkeyForSendEmail.currentState.validate()) {
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
