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

            _data = jsonDecode(snapshot.data);
            String temp = _data[0]['Body'];
            print(temp);

            while(temp.contains("image-")){
              RegExp exp = RegExp(r'image-(.*?)"');
              RegExpMatch? match = exp.firstMatch(temp);
              String s = match![0].toString();
              print(s);
              temp = temp.replaceAll(s, getFileURL(s) as String);
              print(temp);
            }
            return WillPopScope(
              child: Scaffold(
                  body: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Html(data: _data[0]['Body']),

                      ],
                    ),
                  )
              ),
              onWillPop: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                      return ContentPage(isTeacher: false);
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