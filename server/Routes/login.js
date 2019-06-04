module.exports = function(app, db) {
  var bcrypt = require("bcrypt");
  app.post("/api/login", function(req, res) {
    var email = req.body.email;
    var password = req.body.password;
    console.log(email);
    console.log(password);
    db.collection("users")
      .find({ email: email })
      .count()
      .then(value => {
        if (value == 1) {
          db.collection("users")
            .find({ email: email })
            .forEach(doc => {
              bcrypt.compare(password, doc.password, (err, result) => {
                if (result) {
                  console.log("WOW");
                  res.send({
                    message: "Logged in successfully",
                    userID: doc._id.toString(),
                    name: doc.userName
                  });
                  res.end();
                } else {
                  res.send({ message: "Invalid Login Credentials" });
                  res.end();
                }
              });
            });
        } else {
          res.send({
            message: "There is no account associated with this email address"
          });
          res.end();
        }
      });
  });
};
