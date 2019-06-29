module.exports = function(app, db) {
  var ObjectId = require("mongodb").ObjectID;
  app.post("/api/addPost", (req, res) => {
    var userID = req.userID;
    var email = req.email;
    var name = req.name;
    var postTitle = req.postTitle;
    var postHeaderImage = req.postHeaderImage;
    var postDescription = req.postDescription;
    var postContent = req.postContent;
    db.collection("users")
      .find({
        _id: ObjectId(userID)
      })
      .count()
      .then(value => {
        if (value == 1) {
          db.collection("posts")
            .insertOne({
              authorID: userID,
              authorEmail: email,
              authorName: name,
              title: postTitle,
              headerImage: postHeaderImage,
              description: postDescription,
              content: postContent,
              totalNumberOfLikes: 0
            })
            .then(result => {
              console.log(result);
              db.collection("users")
                .updateOne(
                  { email: email },
                  {
                    $push: {
                      listOfPosts: result.insertedId
                    }
                  }
                )
                .then(res => {
                  res.send({ message: "Successfully added!!" });
                })
                .catch(err => {
                  console.log(err);
                  res.send({
                    message: "An error occured, please try again later"
                  });
                });
            })
            .catch(err => {
              console.log(err);
              res.send({ message: "An error occured, please try again later" });
            });
        } else {
          res.send({ message: "You are not authorized to add post!!" });
        }
      });
  });
};
