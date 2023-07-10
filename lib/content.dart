import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:rkt/module_page.dart';

class ContentPage extends StatefulWidget {
  late bool isTeacher;

  ContentPage({required this.isTeacher});

  @override
  State<ContentPage> createState() => _ContentPage(isTeacher: isTeacher);
}

var data;

class _ContentPage extends State<ContentPage> {
  late bool isTeacher;

  _ContentPage({required this.isTeacher});

  @override
  Widget build(BuildContext context) {


    return FutureBuilder<dynamic>(
        future: getDB(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {


            data = jsonDecode(snapshot.data);

            return Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  ModuleList()
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  //Method for the API call

  Future<dynamic> getDB() async {
    print("in get db");
    var ans=  await http.get(Uri.https("rkt-backend-production.vercel.app","api/db/content"));
    print(ans.body.runtimeType);
    return ans.body;

  }


  //Method for the Supabase call
  /*
  Future<dynamic> getDB() async {
    return await supabase.from('content').select();
  }
  */
}

class ModuleList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ModuleList();
  }
}

class _ModuleList extends State<ModuleList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _getModules,
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );
  }

  Widget _getModules(context, index) {
    return Module(
      context: context,
      index: index,
    );
  }
}

class Module extends StatelessWidget {
  late int index;
  late BuildContext context;

  Module({required this.context, required this.index});

  @override
  Widget build(context) {
    return Row(
      children: [
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModulePageParent(data:data[index]))
                  );
            },
            child: Text(data[index]['Title'], style: TextStyle(fontSize: 30),))
      ],
    );
  }
}
