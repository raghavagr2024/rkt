import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:rkt/login_user.dart';
import 'package:flutter_html/flutter_html.dart';

import 'main.dart';
import 'package:rkt/module_page.dart';
import 'package:rkt/teacherNewPage.dart';

double _currentSliderValue = minAge as double;
bool semester1 = false;
bool semester2 = false;
List<bool> checks = List.filled(categories.length, false);
List activeFilters = [];
List activeModules = [];

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

  void _logOut() {
    _logoutFromSupabase();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
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

  void updateDisplayModules(List activeFilters) {
    setState(() {
      activeModules = [];
      for (int i = 0; i < _data.length; i++) {
        List c = _data[i]["categories"];
        bool contains = true;
        if (_data[i]["age"] == _currentSliderValue.toInt()) {
          for (int j = 0; j < activeFilters.length; j++) {
            if (!c.contains(activeFilters[j])) {
              contains = false;
              break;
            }
          }
          if (contains) {
            setState(() {
              activeModules.add(_data[i]);
            });
          }
        }
      }
        print("active module");
        print(activeModules.length);

    });


    
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _data.clear();
      updateDisplayModules(activeFilters);
    });

    return FutureBuilder<dynamic>(
        future: getContent(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            _data = jsonDecode(snapshot.data);
            activeModules = _data;

            return Scaffold(
              floatingActionButton: _getButton(),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Modules", style: TextStyle(fontSize: 40)),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Age',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      width: 550,
                      child: Slider(
                        value: _currentSliderValue,
                        min: 5,
                        max: 13,
                        divisions: 8,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                            updateDisplayModules(activeFilters);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      width: 2000,
                      child: CheckboxListWidget(
                        checkboxItems: categories,
                        updateDisplayModules: updateDisplayModules,
                      ),
                    ),
                    ModuleList(isTeacher: isTeacher),
                    ElevatedButton(
                      onPressed: _logOut,
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
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
      itemCount: activeModules.length,
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
        const SizedBox(
            height: 50,
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
              width: 20,
            ),
            Text(
              "${activeModules[index]['inserted_at'].toString().substring(0, 10)}: ",
              style: const TextStyle(
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
                              builder: (context) => ModulePageParent(
                                  id: activeModules[index]['id'])));
                    },
                    child: Text(
                      activeModules[index]['Title'],
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
                              builder: (context) => TeacherNewPage.edit(
                                  activeModules[index]['id'])));
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
            title: Text('Delete module ${activeModules[index]["Title"]}?'),
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
                  await deleteContent(activeModules[index]['id']);
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

class CheckboxListWidget extends StatefulWidget {
  final HashSet<dynamic> checkboxItems;
  final ValueChanged<List> updateDisplayModules;

  CheckboxListWidget(
      {required this.checkboxItems, required this.updateDisplayModules});

  @override
  _CheckboxListWidgetState createState() =>
      _CheckboxListWidgetState(updateDisplayModules: updateDisplayModules);
}

class _CheckboxListWidgetState extends State<CheckboxListWidget> {
  late List<dynamic> _checkboxList;
  final ValueChanged<List> updateDisplayModules;

  _CheckboxListWidgetState({required this.updateDisplayModules});

  @override
  void initState() {
    super.initState();
    _checkboxList = widget.checkboxItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _checkboxList.length,
      itemBuilder: (context, index) {
        dynamic item = _checkboxList[index];
        return SizedBox(
            width: 200,
            child: CheckboxListTile(
              title: Text(item.toString()),
              value: checks[index],
              onChanged: (newValue) {
                setState(() {
                  checks[index] = !checks[index];
                  if (checks[index]) {
                    activeFilters.add(_checkboxList[index]);
                  } else {
                    activeFilters.remove(_checkboxList[index]);
                  }
                  updateDisplayModules(activeFilters);
                });
              },
            ));
      },
    );
  }
}
