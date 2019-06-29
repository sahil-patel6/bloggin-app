import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  final String name, email, userID;
  AddPost(this.name, this.email, this.userID);
  @override
  _AddPostState createState() => _AddPostState();
}

TextStyle textStyleForBold =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
TextStyle textStyleForNormal = TextStyle(fontSize: 20);
TextStyle textStyleForItalics =
    TextStyle(fontSize: 20, fontStyle: FontStyle.italic);
TextStyle textStyleForItalicsAndBold = TextStyle(
    fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold);

class _AddPostState extends State<AddPost> {
  String inputValue = '';
  TextEditingController controller = new TextEditingController(text: "");
  @override
  void initState() {
    super.initState();
    controller.addListener(updateText);
  }

  void updateText() {
    setState(() {
      inputValue = controller.value.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: <Widget>[
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(child: Text("Add Post")),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: TextFormField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: "Enter formatted values"),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Output:",
            style: textStyleForNormal,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          textFormattor(),
        ],
      ),
    ]);
  }

  Widget textFormattor() {
    List<TextSpan> texts = new List();
    inputValue.splitMapJoin(new RegExp(r'\*\*[A-Za-z0-9 ]*\*\*'),
        onMatch: (bold) {
      texts.add(TextSpan(
          text: bold.group(bold.groupCount).replaceAll(r'**', ""),
          style: textStyleForBold));
    }, onNonMatch: (text) {
      text.splitMapJoin(
        new RegExp(r'\!\![A-Za-z0-9 ]*\!\!'),
        onMatch: (italics) {
          texts.add(TextSpan(
              text: italics.group(italics.groupCount).replaceAll(r'!!', ""),
              style: textStyleForItalics));
        },
        onNonMatch: (text) {
          text.splitMapJoin(new RegExp(r'\*\![A-Za-z0-9 ]*\*\!'),
              onMatch: (boldAndItalics) {
            texts.add(TextSpan(
                text: boldAndItalics
                    .group(boldAndItalics.groupCount)
                    .replaceAll(r'*!', ""),
                style: textStyleForItalicsAndBold));
          }, onNonMatch: (normal) {
            texts.add(
                TextSpan(text: normal.toString(), style: textStyleForNormal));
          });
        },
      );
    });
    return RichText(
      text: TextSpan(children: texts),
    );
  }
}
