import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rkt/main.dart';

import 'content.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rkt/login_user.dart';
import 'package:http/http.dart' as http;

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

    void _logOut() {
    _logoutFromSupabase();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
 
  void _logoutFromSupabase() async {
    final response = await http.post(
      Uri.parse('https://rkt-backend-production.vercel.app/api/auth/signout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$access_token',
      },
    );

    if (response.statusCode == 200) {
      print('Logged out successfully.');
    } else {
      print('Logout failed. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<dynamic>(
        future: getContentByID(id),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {

            _data = snapshot.data;
            print(_data.runtimeType);
            print(_data);
            return WillPopScope(
              child: Scaffold(
                  body: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Html(data: _data),
                        ElevatedButton(
                          onPressed: _logOut,
                          child: const Text('Log Out'),
                        ),
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
