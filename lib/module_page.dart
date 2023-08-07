import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rkt/main.dart';

import 'content.dart';
import 'package:flutter_html/flutter_html.dart';

class ModulePageParent extends StatefulWidget{
  late final id;

  ModulePageParent({
    required this.id,
  });
  @override
  State<StatefulWidget> createState() {
    return _ModulePageParent(id: id);
  }

}
class _ModulePageParent extends State<ModulePageParent> {

  late final id;
  var _data;
  _ModulePageParent({
    required this.id,
  });

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<dynamic>(
        future: getContentByID(id),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {

            _data = snapshot.data[0];
            print(_data.runtimeType);
            print(_data);
            return WillPopScope(
              child: Scaffold(
                  body: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Html(data: _data),
                      ],
                    ),
                  )
              ),
              onWillPop: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                      return ContentPage(isTeacher: teacherAccount);
                    }));
                return Future.value(true); //this line will help
              },
            );

          } else {
            return const CircularProgressIndicator();
          }
        });

  }

}