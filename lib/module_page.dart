import 'package:flutter/material.dart';

import 'content.dart';

class ModulePageParent extends StatelessWidget {

  late final data;

  ModulePageParent({required this.data});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(data["Title"]),
                  SizedBox(height: 40,),
                  Text(data['Body']),
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
  }

}