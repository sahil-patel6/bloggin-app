import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './signup.dart';
import './login.dart';

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

class _MyHomePageState extends State<MyHomePage>{
  Future<Database> database;
  bool userExists = false;
  String name, email, userID;
  @override
  void initState() {
    super.initState();
    checkUserIsLoggedInOrNot();
  }


  GlobalKey<ScaffoldState> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: Image.network(
                            "http://192.168.1.100:3000/profile_pics/$userID.jpg",
                            width: 33,
                            height: 33))
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
          child: Text(userExists ? "User Logged In" : "User Not Logged In")),
    );
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
    setState(() {
      userExists = false;
      name = "";
      email = "";
      userID = "";
    });
    int changes = await db.delete("user");
    print(changes);
    if (changes > 0) {
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
          "CREATE TABLE user(userID TEXT, name TEXT, email TEXT)",
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
          email: maps[i]['email']);
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
    }
  }
}

class User {
  String userID;
  String name;
  String email;
  User({this.userID, this.name, this.email});
}
