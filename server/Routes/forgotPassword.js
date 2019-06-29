module.exports = function(app, db) {
  app.post("/api/forgotPassword", (req, res) => {
    var otp = req.body.otp;
    var email = req.body.email;
    var newPassword = req.body.newPassword;
    var bcrypt = require("bcrypt");
    db.collection("users")
      .find({ email: email })
      .count()
      .then(value => {
        if (value == 1) {
          db.collection("users")
            .find({ email: email })
            .forEach(doc => {
              if (doc.verificationCode == otp) {
                console.log("WOOHO");
                bcrypt.hash(newPassword, 10, (err, encryptedPassword) => {
                  console.log(err);
                  db.collection("users")
                    .updateOne(
                      { email: email },
                      { $set: { password: encryptedPassword } }
                    )
                    .then(value => {
                      console.log(value);
                      db.collection("users")
                        .updateOne(
                          { email: email },
                          {
                            $set: {
                              verificationCode: 0
                            }
                          }
                        )
                        .then(val => {
                          res.send("Password changed successfully");
                          res.end();
                        })
                        .catch(err => console.log(err));
                    })
                    .catch(err => {
                      console.log(err);
                      res.send("An error occured while changing password");
                      res.end();
                    });
                });
              } else {
                res.send("Please enter correct otp");
                res.end();
              }
            });
        } else {
          res.send("Invalid Email Adress");
          res.end();
        }
      });
  });
};
