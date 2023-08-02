import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'main.dart';
import 'package:rkt/module_page.dart';
import 'package:rkt/teacherNewPage.dart';

class ContentPage extends StatefulWidget {
  late bool isTeacher;
  Widget build(BuildContext context) {
    return Text("Modules");
  }

  ContentPage({required this.isTeacher});

  @override
  State<ContentPage> createState() => _ContentPage(isTeacher: isTeacher);
}

var _data = [];

class _ContentPage extends State<ContentPage> {
  late bool isTeacher;

  _ContentPage({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    setState(() {
      _data.clear();
    });

    return FutureBuilder<dynamic>(
        future: getContent(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            _data = jsonDecode(snapshot.data);

            return Scaffold(
              floatingActionButton: _getButton(),
              body: Column(
                children: [
                  const Text("Modules", style: TextStyle(fontSize: 40)),
                  const SizedBox(
                    height: 40,
                  ),
                  ModuleList(isTeacher: isTeacher),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  //Method for the API call

  Widget _getButton() {
    if (isTeacher) {
      return FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TeacherNewPage()));
            });
          });
    } else {
      return Container();
    }
  }

  //Method for the Supabase call
  /*
  Future<dynamic> getDB() async {
    return await supabase.from('content').select();
  }
  */
}

class ModuleList extends StatefulWidget {
  late final isTeacher;
  ModuleList({required this.isTeacher});
  @override
  State<StatefulWidget> createState() {
    return _ModuleList(isTeacher: isTeacher);
  }
}

class _ModuleList extends State<ModuleList> {
  late final isTeacher;
  _ModuleList({required this.isTeacher});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _getModules,
      itemCount: _data.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );
  }

  Widget _getModules(context, index) {
    return Module(
      context: context,
      index: index,
      isTeacher: isTeacher,
    );
  }
}

class Module extends StatefulWidget {
  late int index;
  late BuildContext context;
  late final isTeacher;
  Module({required this.context, required this.index, required this.isTeacher});
  @override
  State<StatefulWidget> createState() {
    return _Module(
      context: context,
      index: index,
      isTeacher: isTeacher,
    );
  }
}

class _Module extends State<Module> {
  late int index;
  late BuildContext context;
  late final isTeacher;

  _Module(
      {required this.context, required this.index, required this.isTeacher});

  @override
  Widget build(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: (2 / 5) * MediaQuery.of(context).size.width,
        ),
        SizedBox(
            height: 50,
            width: 10,
            child: const DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              width: 20,
            ),
            Text(
              _data[index]['inserted_at'].toString().substring(0, 10) + ": ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(
                height: 30,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ModulePageParent(id: _data[index]['id'])));
                    },
                    child: Text(
                      _data[index]['Title'],
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ))),
            if (isTeacher) ...[
              IconButton(
                  onPressed: () {
                    _confirmDialog();
                  },
                  icon: const Icon(Icons.remove_circle)),
              IconButton(
                  onPressed: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TeacherNewPage.edit(_data[index]['id'])));
                    });
                  },
                  icon: const Icon(Icons.edit))
            ],
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Delete module ${_data[index]["Title"]}?'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Deny'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () async {
                  print("in confirm");
                  await deleteContent(_data[index]['id']);
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContentPage(isTeacher: true)));
                },
              ),
            ],
          );
        });
      },
    );
  }
}
