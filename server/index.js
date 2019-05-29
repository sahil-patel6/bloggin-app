var express = require("express");
var bodyParser = require("body-parser");
var fs = require("fs");
var app = express();
var port = process.env.port || 3000;

ObjectId = require("mongodb").ObjectID;
const MongoClient = require("mongodb").MongoClient;
const url = "mongodb://localhost:27017";
const dbName = "myproject";
const client = new MongoClient(url, { useNewUrlParser: true });

app.use(express.static("public"));

var db;

client.connect(function (err) {
  console.log("Connected successfully to server");

  db = client.db(dbName);
  // db.collection("users").deleteMany({});
  var result = db
    .collection("users")
    .find({})
    .count()
    .then(value => console.log(value));
  db.collection("users").find({}).forEach(doc => {
    console.log(doc);
  })
});

app.use(bodyParser.urlencoded({ extended: true, limit: "50mb" }));
app.post("/api/signup", function (req, res) {
  var name = req.body.userName;
  var img = req.body.profilePic;
  var email = req.body.email;
  var password = req.body.password;
  var realFile = Buffer.from(img, "base64");

  db.collection("users")
    .find({ email: email })
    .count()
    .then(value => {
      if (value === 0) {
        db.collection("users")
          .insertOne({
            userName: name,
            email: email,
            password: password,
            totalNumberOfPosts: 0,
            listOfBookmarkedPosts: [],
            totalPostViewed: 0,
            totalPostLiked: 0,
            listOfLikedPosts: [],
            listOfPosts: []
          })
          .then(value => {
            fs.writeFile(
              "./public/profile_pics/" + value.insertedId + ".jpg",
              realFile,
              function (err) {
                if (err) {
                  console.log(err);
                  res.send({ message: "An error occured while adding your profile picture" });
                }
              }
            );
            res.send({ message: "Account Created Successfully", userID: value.insertedId });
            res.end();
          }).catch(err => {
            console.log(err);
            res.send({ message: "An error occurred while counting, please try again later" });
            res.end();
          });
        console.log("Account is not created");
      } else {
        console.log("Account is Created");
        res.send({ message: "Account is created" });
        res.end();
      }
    }).catch(err => {
      console.log(err);
    });
});
app.get("/api", function (req, res) {
  res.send("Welcome To Blogging App API");
});
app.listen(3000, () => {
  console.log(`Listening from ${port}`);
});
