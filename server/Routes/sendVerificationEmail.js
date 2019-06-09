module.exports = function(app, db) {
  var nodemailer = require("nodemailer");
  var config = require("../config");
  var transporter = nodemailer.createTransport({
    service: "gmail",
    requireTLS: true,
    auth: {
      user: config.email,
      pass: config.pass
    }
  });

  app.post("/api/sendVerificationEmail", (req, res) => {
    var email = req.body.email;
    console.log(email);

    var chars =
      "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var code = "";
    for (var i = 6; i > 0; --i) {
      code += chars[Math.round(Math.random() * (chars.length - 1))];
    }
    db.collection("users")
      .updateOne({ email: email }, { $set: { verificationCode: code } })
      .then(value => console.log(value.modifiedCount))
      .catch(err => console.log(err));
    var mailOptions = {
      from: '"Blogging_App" <no-reply@blogging_app.com>',
      to: email,
      subject: "Please Verify Your account For Blogging_App",
      html: `<h1>${code}</h1>`
    };

    transporter.sendMail(mailOptions, function(error, info) {
      if (error) {
        console.log(error);
        res.send(
          "An error occured while sending email, please try again later"
        );
        res.end();
      } else {
        console.log("Email sent: " + info.response);
        res.send("Verfication Email Sent");
        res.end();
      }
    });
  });
};
