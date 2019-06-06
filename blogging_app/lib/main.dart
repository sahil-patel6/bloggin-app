import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './signup.dart';
import './login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './BookmarkedPosts.dart';
import './Home.dart';
import './AddPost.dart';
import './LikedPosts.dart';
import './YourPosts.dart';
import 'VerifyEmail.dart';

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
  bool userExists = false, isVerified = false;
  String name, email, userID;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    checkUserIsLoggedInOrNot();
  }

  GlobalKey<ScaffoldState> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            if (userExists && isVerified) _currentIndex = i;
          });
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), title: Text("Bookmarked Posts")),
          BottomNavigationBarItem(
              icon: Icon(Icons.add), title: Text("Add Post")),
          BottomNavigationBarItem(
              icon: Icon(Icons.thumb_up), title: Text("Liked Posts")),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), title: Text("Your Posts")),
        ],
      ),
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          Center(
            child: InkWell(
                onTap: () {
                  if (!userExists) {
                    showDialog(
                        context: context,
                        child: Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                  checkUserIsLoggedInOrNot();
                                },
                                title: Text("Signup"),
                              ),
                              ListTile(
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                  checkUserIsLoggedInOrNot();
                                  print("Login");
                                },
                                title: Text("Login"),
                              ),
                            ],
                          ),
                        ));
                  } else {
                    showDialog(
                        context: context,
                        child: Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  signout();
                                },
                                title: Text("Sign out"),
                              ),
                            ],
                          ),
                        ));
                  }
                },
                child: userExists
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(33 / 2),
                        child: CachedNetworkImage(
                          imageUrl:
                              "http://192.168.1.101:3000/profile_pics/$userID.jpg",
                          placeholder: (context, url) =>
                              Icon(Icons.account_circle, size: 33),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.account_circle, size: 33),
                          fit: BoxFit.cover,
                          width: 33,
                          height: 33,
                        ))
                    : Icon(
                        Icons.account_circle,
                        size: 33,
                      )),
          ),
          SizedBox(width: 20),
        ],
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
                ? BookMarkedPosts(name, email, userID)
                : _currentIndex == 2
                    ? AddPost(name, email, userID)
                    : _currentIndex == 3
                        ? LikedPost(name, email, userID)
                        : _currentIndex == 4
                            ? YourPosts(name, email, userID)
                            : null;
      } else {
        return Center(
            child: Column(
          children: <Widget>[
            Text("You have not verified your email yet, please verify. "),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: () async {
                await Navigator.push(
                    key.currentContext,
                    MaterialPageRoute(
                        builder: (context) => VerifyEmail(
                              email: email,
                            )));
                checkUserIsLoggedInOrNot();
              },
              child: Text("Verify"),
            )
          ],
        ));
      }
    } else {
      return Center(child: Text("Please sign in/sign up"));
    }
  }

  void signout() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT)",
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
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT,isVerified TEXT)",
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
      );
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
  User({this.userID, this.name, this.email, this.isVerified});
}
