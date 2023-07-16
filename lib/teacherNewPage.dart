import 'dart:convert';

import 'package:flutter/material.dart';


import 'main.dart';



var _title = TextEditingController();
var _body = TextEditingController();
int _id = -1;
class TeacherNewPage extends StatefulWidget {
  TeacherNewPage.edit(index){
    _id = index;
  }
  TeacherNewPage();




  @override
  State<StatefulWidget> createState() {

    return _TeacherNewPage();
  }
}

class _TeacherNewPage extends State<TeacherNewPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getContentByID(_id),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var _data = jsonDecode(snapshot.data);
            if(_id!=-1){
              _title.text = _data[0]["Title"];
              _body.text = _data[0]["Body"];
            }

            print(_data.toString());

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
                  WriteButton()
                ],
              ),
            );

          } else {
            return CircularProgressIndicator();
          }
        });

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

class WriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          if(_id==-1){
            await addContent(_title,_body);
            print("add content done");
          }
          else{
            await editContent(_id,_title,_body);
            print("edit content done");
          }
        },
        child: _id == -1? const Text("Add content"): const Text("Edit content"));
  }





}
