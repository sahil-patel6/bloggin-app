import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './Search.dart';
import './Home.dart';
import './AddPost.dart';
import './MyAccount.dart';
import './Downloads.dart';
import 'VerifyEmail.dart';
import './generalUtility.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogging App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Database> database;
  String appBarTitle = "Home";
  bool userExists = false, isVerified = false;
  String name, email, userID;
  int _currentIndex = 0;
  Uint8List profilePic;
  @override
  void initState() {
    super.initState();
    checkUserIsLoggedInOrNot();
  }

  GlobalKey<ScaffoldState> key = new GlobalKey();
  List<String> appBarTitles = [
    'Home',
    'Search',
    'Add Post',
    'Downloads',
    'My Account'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            if (i == 4 || i == 0) {
              _currentIndex = i;
              appBarTitle = appBarTitles[i];
            } else if (userExists && isVerified) {
              _currentIndex = i;
              appBarTitle = appBarTitles[i];
            }
          });
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text("Search")),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit), title: Text("Add Post")),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_download), title: Text("Downloads")),
          BottomNavigationBarItem(
              icon: userExists
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: profilePic == null
                          ? Icon(Icons.account_circle, size: 30)
                          : Image.memory(profilePic, height: 30, width: 30))
                  : Icon(
                      Icons.account_circle,
                      size: 22,
                    ),
              title: Text("My Account")),
        ],
      ),
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: Center(
        key: key,
        child: mainWidget(),
      ),
    );
  }

  Widget mainWidget() {
    if (userExists) {
      if (isVerified) {
        return _currentIndex == 0
            ? Home(name, email, userID)
            : _currentIndex == 1
                ? Search(name, email, userID)
                : _currentIndex == 2
                    ? AddPost(name, email, userID)
                    : _currentIndex == 3
                        ? Downloads(name, email, userID)
                        : _currentIndex == 4
                            ? MyAccount(userExists, isVerified, name, email,
                                userID, checkUserIsLoggedInOrNot,signout)
                            : null;
      } else {
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
                              email: email,
                            )));
                checkUserIsLoggedInOrNot();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
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
                signout();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Text("Sign Out",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
          ],
        ));
      }
    } else {
      if (_currentIndex == 4) {
        setState(() {
          appBarTitle = "My Account";
        });
        return MyAccount(userExists, isVerified, name, email, userID,
            checkUserIsLoggedInOrNot,signout);
      } else {
        return Center(
            child: Text(
          "Please Sign in/Sign up",
          style: TextStyle(fontSize: 20),
        ));
      }
    }
  }

  void signout() async {
    database = openDatabase(
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
    if (changes > 0) {
      setState(() {
        userExists = false;
        name = "";
        email = "";
        userID = "";
      });
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("Signed out succesfully"),
      ));
    } else {
      Scaffold.of(key.currentContext).hideCurrentSnackBar();
      Scaffold.of(key.currentContext).showSnackBar(SnackBar(
        content: Text("An error occured while signing you out"),
      ));
    }
  }

  void checkUserIsLoggedInOrNot() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          DbCommandToCreateUserTable,
        );
      },
      version: 1,
    );
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    List<User> user = List.generate(maps.length, (i) {
      return User(
          userID: maps[i]['userID'],
          name: maps[i]['name'],
          email: maps[i]['email'],
          isVerified: maps[i]['isVerified'],
          profilePic: maps[i]['profilePic']);
    });
    if (user.isEmpty) {
      setState(() {
        userExists = false;
      });
    } else {
      setState(() {
        userExists = true;
        name = user[0].name;
        email = user[0].email;
        userID = user[0].userID;
        profilePic = base64Decode(user[0].profilePic);
      });
      if (user[0].isVerified == "YES") {
        setState(() {
          isVerified = true;
        });
      } else {
        setState(() {
          isVerified = false;
        });
      }
    }
  }
}

class User {
  String userID;
  String name;
  String email;
  String isVerified;
  String profilePic;
  User({this.userID, this.name, this.email, this.isVerified, this.profilePic});
}
