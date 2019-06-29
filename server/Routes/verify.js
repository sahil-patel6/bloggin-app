module.exports = function(app, db) {
  app.post("/api/verify", (req, res) => {
    var email = req.body.email;
    var verificationCode = req.body.code;
    db.collection("users")
      .find({ email: email })
      .forEach(doc => {
        if (doc.verificationCode == verificationCode) {
          db.collection("users")
            .updateOne({ email: email }, { $set: { isVerified: true } })
            .then(value => {
              console.log(value.modifiedCount);
              db.collection("users")
                .updateOne({ email: email }, { $set: { verificationCode: 0 } })
                .then(val => {
                  res.send({
                    message: "Verified Succesffully",
                    isVerified: true
                  });
                  res.end();
                })
                .catch(err => console.log(err));
            })
            .catch(err => {
              console.log(err);
              res.send({ message: "An error Occured", isVerified: false });
              res.end();
            });
        } else {
          res.send({ message: "Please enter correct otp", isVerified: false });
          res.end();
        }
      });
  });
};
