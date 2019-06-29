import 'package:flutter/material.dart';
import './SignInAndSignUp.dart';

import 'VerifyEmail.dart';

class MyAccount extends StatefulWidget {
  final bool userExists, isVerified;
  final String name, email, userID;
  final Function check, signout;
  MyAccount(this.userExists, this.isVerified, this.name, this.email,
      this.userID, this.check, this.signout);
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  void initState() {
    widget.check();
    super.initState();
  }

  GlobalKey<ScaffoldState> key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(key: key, child: mainWidget());
  }

  Widget mainWidget() {
    if (widget.userExists && !widget.isVerified) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "You have not verified your email yet, please verify.",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          RaisedButton(
            color: Colors.blue,
            elevation: 10,
            highlightElevation: 20,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 75),
            onPressed: () async {
              await Navigator.push(
                  key.currentContext,
                  MaterialPageRoute(
                      builder: (context) => VerifyEmail(
                            email: widget.email,
                          )));
              widget.check();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Text("Verify",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                )),
          ),
          SizedBox(height: 40),
          RaisedButton(
            color: Colors.blue,
            elevation: 10,
            highlightElevation: 20,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 75),
            onPressed: () async {
              widget.signout();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Text("Sign Out",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                )),
          ),
        ],
      ));
    } else if (widget.userExists) {
      return myAccount();
    } else {
      return SignInAndSignUp(widget.check);
    }
  }

  Widget myAccount() {
    if (widget.userExists && widget.isVerified) {
      return Center(
        child: RaisedButton(
          color: Colors.blue,
          elevation: 10,
          highlightElevation: 20,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 75),
          onPressed: widget.signout,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text("Sign Out",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              )),
        ),
      );
    } else {
      return Center(
        child: Text("An Error Occurred"),
      );
    }
  }
}
