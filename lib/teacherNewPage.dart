import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



var _title = TextEditingController();
var _body = TextEditingController();

class TeacherNewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeacherNewPage();
  }
}

class _TeacherNewPage extends State<TeacherNewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Text("Title"),
              )),
          TitleField(),
          SizedBox(
            height: 50,
          ),
          const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Text("Body"),
              )),
          BodyField(),
          AddButton()
        ],
      ),
    );
  }
}

class TitleField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TitleField();
  }
}

class _TitleField extends State<TitleField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 5, 500, 16),
      child: TextField(
        controller: _title,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class BodyField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyField();
  }
}

class _BodyField extends State<BodyField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 5, 500, 16),
      child: TextField(
        controller: _body,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        maxLines: 7,
        minLines: 1,
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await addContent();
        },
        child: Text("Add content"));
  }

  Future<http.Response> addContent() {
    print("in addContent");
    return http.post(
      Uri.parse('https://rkt-backend-production.vercel.app/api/db/content'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'title': _title.text, 'body': _body.text}),
    );
  }
}
