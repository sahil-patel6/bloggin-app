var express = require("express");
var fs = require("fs");
var bcrypt = require("bcrypt");

module.exports = function(app, db) {
  app.post("/api/signup", function(req, res) {
    var name = req.body.userName;
    var img = req.body.profilePic;
    var email = req.body.email;
    var password = req.body.password;
    var realFile = Buffer.from(img, "base64");
    bcrypt.hash(password, 10, (err, encryptedPassword) => {
      db.collection("users")
        .find({ email: email })
        .count()
        .then(value => {
          if (value === 0) {
            db.collection("users")
              .insertOne({
                userName: name,
                email: email,
                password: encryptedPassword,
                totalNumberOfPosts: 0,
                listOfBookmarkedPosts: [],
                listOfLikedPosts: [],
                listOfPosts: [],
                isVerified: false,
                verificationCode: ""
              })
              .then(value => {
                fs.writeFile(
                  "./public/profile_pics/" + value.insertedId + ".jpg",
                  realFile,
                  function(err) {
                    if (err) {
                      console.log(err);
                      res.send({
                        message:
                          "An error occured while adding your profile picture"
                      });
                    }
                  }
                );
                res.send({
                  message: "Account Created Successfully",
                  userID: value.insertedId
                });
                res.end();
              })
              .catch(err => {
                console.log(err);
                res.send({
                  message:
                    "An error occurred while counting, please try again later"
                });
                res.end();
              });
            console.log("Account is not created");
          } else {
            console.log("Account is Created");
            res.send({ message: "Account is created" });
            res.end();
          }
        })
        .catch(err => {
          console.log(err);
        });
    });
  });
};
